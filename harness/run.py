"""Benchmark pipeline: generate code with the model, evaluate it in Docker, repair on failure,
then (per config.py) judge idiomaticity and write the report.

Settings live in harness/config.py; flags below override them for one run.

Examples:
    python harness/run.py --dry-run                     # prompts only, no API, no Docker
    python harness/run.py --baseline                    # evaluator check, no API
    python harness/run.py --langs C,Haskell --tests 4   # pilot
    python harness/run.py                               # full run + judge + report
"""

from __future__ import annotations

import argparse
import shutil
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone
from pathlib import Path

import config
import evaluator
import prompts
import store
import tasks
from tasks import Task

# Outcomes without code to evaluate.
NO_EVAL_MESSAGES = {
    "truncated": "Your previous response was cut off at the output token limit before the code was "
                 "complete. Return the complete file in full.",
    "empty_output": "Your previous response did not contain any code.",
}

_print_lock = threading.Lock()


def log(msg: str) -> None:
    with _print_lock:
        print(msg, flush=True)


# --------------------------------------------------------------------------- dry run

def dry_run(task_list: list[Task]) -> int:
    out = store.WORK / "dry-run"
    if out.exists():
        shutil.rmtree(out)
    sizes = []
    for task in task_list:
        initial = prompts.render_initial(task)
        followup = prompts.render_followup(task, "<test output excerpt>", [f"Test {task.test_ids[0]} (Example)"])
        d = out / task.lang / task.test
        d.mkdir(parents=True)
        (d / "prompt-initial.md").write_text(initial, encoding="utf-8")
        (d / "prompt-followup-example.md").write_text(followup, encoding="utf-8")
        sizes.append((len(initial), task.id))
    log(f"Rendered {len(task_list)} initial + follow-up prompts into {out}")
    log(f"Prompt size: min {min(sizes)[0]} chars ({min(sizes)[1]}), max {max(sizes)[0]} chars ({max(sizes)[1]})")
    return 0


# --------------------------------------------------------------------------- baseline

def baseline(task_list: list[Task], run_dir: Path, args) -> int:
    evaluator.build_images([t.lang for t in task_list])
    jobs = [(task, "stub", None) for task in task_list]
    for task in task_list:
        source = tasks.reference_source(task)
        if source is not None:
            jobs.append((task, "reference", {task.target: source}))

    def run_job(task: Task, kind: str, files: dict | None) -> tuple[Task, str, dict]:
        work = store.WORK / run_dir.name / "baseline" / f"{task.lang}-{task.test}-{kind}"
        mount = evaluator.prepare_workdir(task, work, files)
        result, output = evaluator.run_tests(task, mount, args.timeout)
        (run_dir / "baseline").mkdir(parents=True, exist_ok=True)
        (run_dir / "baseline" / f"{task.lang}-{task.test}-{kind}.log").write_text(output, encoding="utf-8")
        if not args.keep_work:
            shutil.rmtree(work, ignore_errors=True)
        return task, kind, result.to_dict() | {"parsed_results": len(result.names)}

    report: dict[str, dict] = {}
    with ThreadPoolExecutor(args.workers) as pool:
        futures = [pool.submit(run_job, *job) for job in jobs]
        for fut in as_completed(futures):
            task, kind, res = fut.result()
            report.setdefault(task.id, {})[kind] = res
            log(f"[baseline] {task.id:<18} {kind:<9} {res['category']:<14} "
                f"{res['n_pass']:>2}/{res['n_tests']} parsed={res['parsed_results']} exit={res['exit_code']} "
                f"({res['duration_s']}s)")
    path = run_dir / "baseline.json"
    merged = (store.read_json(path) if path.exists() else {}) | report  # a subset run updates its tasks only
    store.write_json(path, dict(sorted(merged.items())))

    problems = []
    for task in task_list:
        entry = report[task.id]
        stub = entry["stub"]
        if (stub["parsed_results"] != len(task.test_ids)
                or stub["category"] not in ("test_failures", "memory_error")):
            problems.append(f"{task.id}: stub run {stub['category']}, "
                            f"{stub['parsed_results']}/{len(task.test_ids)} parsed results")
        if (task.lang, task.test) in tasks.REFERENCE_EXPECTED_PASS and entry["reference"]["category"] != "pass":
            problems.append(f"{task.id}: reference expected to pass, got {entry['reference']['category']}")
    stub_passes = {tid: e["stub"]["passed"] for tid, e in report.items() if e["stub"]["passed"]}
    log(f"\nBaseline written to {run_dir / 'baseline.json'}")
    log(f"Tests passing on the stub: " + (", ".join(f"{k} ({len(v)})" for k, v in stub_passes.items()) or "none"))
    if problems:
        log("PROBLEMS:\n  " + "\n  ".join(problems))
        return 1
    log("All checks OK: every stub prints a result for each of its tests and fails; "
        "references pass where expected.")
    return 0


# --------------------------------------------------------------------------- model run

def _check_config(run_dir: Path, cfg: dict) -> None:
    path = run_dir / "config.json"
    if path.exists():
        old = store.read_json(path)
        for key in ("model", "effort", "max_repairs", "max_tokens"):
            if old.get(key) != cfg[key]:
                raise SystemExit(f"{path}: existing run used {key}={old.get(key)!r}, now {cfg[key]!r}. "
                                 f"Set a new RUN_ID in harness/config.py (or pass --run-id) to change settings.")
        cfg = old | {"samples": max(old.get("samples", 1), cfg["samples"])}
    store.write_json(path, cfg)


def run_sample(task: Task, sample: int, run_dir: Path, cfg: dict, client, args) -> dict | None:
    import llm  # imported lazily: dry-run and baseline need neither the SDK nor a key

    sdir = store.sample_dir(run_dir, task.lang, task.test, sample)
    if (sdir / "final.json").exists():
        return store.read_json(sdir / "final.json")
    if sdir.exists():
        shutil.rmtree(sdir)  # partial run from an interrupted session: start the sample over

    tag = f"[{task.id} s{sample}]"
    ext = tasks.EXTENSIONS[task.lang]
    common = {"run_id": run_dir.name, "lang": task.lang, "paradigm": task.paradigm,
              "test": task.test, "sample": sample, "model": cfg["model"], "effort": cfg["effort"]}
    messages: list[dict] = []
    attempts: list[dict] = []
    excerpt, failing = "", []

    for attempt in range(cfg["max_repairs"] + 1):
        adir = sdir / f"attempt-{attempt}"
        adir.mkdir(parents=True)
        prompt = (prompts.render_initial(task) if attempt == 0
                  else prompts.render_followup(task, excerpt, failing))
        (adir / "prompt.md").write_text(prompt, encoding="utf-8")
        messages.append({"role": "user", "content": prompt})

        gen = llm.generate(client, cfg["model"], cfg["effort"], messages, cfg["max_tokens"])
        messages.append({"role": "assistant", "content": gen.content})
        store.write_json(adir / "response.json", gen.raw)
        if gen.code:
            (adir / f"solution{ext}").write_text(gen.code, encoding="utf-8", newline="\n")

        result = None
        if gen.stop_reason == "refusal":
            category = "refusal"
        elif not gen.code.strip():
            category = "empty_output"
        elif gen.stop_reason == "max_tokens":
            category = "truncated"
        else:
            work = store.WORK / run_dir.name / f"{task.lang}-{task.test}-s{sample}-a{attempt}"
            mount = evaluator.prepare_workdir(task, work, {task.target: gen.code})
            result, output = evaluator.run_tests(task, mount, args.timeout)
            (adir / "eval.log").write_text(output, encoding="utf-8")
            store.write_json(adir / "eval.json", result.to_dict())
            if not args.keep_work:
                shutil.rmtree(work, ignore_errors=True)
            category = result.category
            excerpt = evaluator.log_excerpt(result, output, args.timeout)
            failing = result.failing_names() if result.names else []  # no results: nothing to list
        if result is None:
            excerpt, failing = NO_EVAL_MESSAGES.get(category, ""), []

        row = common | {
            "attempt": attempt,
            "category": category,
            "n_pass": result.n_pass if result else 0,
            "n_tests": result.n_tests if result else len(task.test_ids),
            "passed": result.passed if result else [],
            "failed": result.failed if result else list(task.test_ids),
            "exit_code": result.exit_code if result else None,
            "eval_s": result.duration_s if result else 0.0,
            "llm_s": gen.duration_s,
            "stop_reason": gen.stop_reason,
            "format_violation": gen.format_violation,
            "code_lines": gen.code.count("\n"),
            "code_chars": len(gen.code),
            **gen.usage,
        }
        store.write_json(adir / "attempt.json", row)
        attempts.append(row)
        log(f"{tag} attempt {attempt}: {category:<14} {row['n_pass']:>2}/{row['n_tests']}  "
            f"(llm {gen.duration_s}s, eval {row['eval_s']}s, out {gen.usage['output_tokens']} tok)")
        if category in ("pass", "refusal"):
            break

    first, last = attempts[0], attempts[-1]
    solved_at = next((a["attempt"] for a in attempts if a["category"] == "pass"), None)
    final = common | {
        "final_category": last["category"],
        "solved": solved_at is not None,
        "solved_at_attempt": solved_at,
        "attempts_used": len(attempts),
        "n_tests": max(a["n_tests"] for a in attempts),
        "first_category": first["category"],
        "first_n_pass": first["n_pass"],
        "first_passed": first["passed"],
        "final_n_pass": last["n_pass"],
        "final_passed": last["passed"],
        "best_n_pass": max(a["n_pass"] for a in attempts),
        "format_violations": sum(a["format_violation"] for a in attempts),
        **{k: sum(a[k] for a in attempts) for k in ("input_tokens", "output_tokens",
                                                    "cache_read_input_tokens", "cache_creation_input_tokens")},
    }
    store.write_json(sdir / "final.json", final)
    return final


def _spend_summary(jobs: list[tuple[Task, int]], run_dir: Path, args) -> list[str]:
    """Upper bound of the API calls this command can make, with a rough cost estimate."""
    import llm

    todo = sum(not (store.sample_dir(run_dir, t.lang, t.test, s) / "final.json").exists() for t, s in jobs)
    gen_calls = todo * (args.max_repairs + 1)
    lines = [f"Run {run_dir.name}: {len(jobs)} samples ({len(jobs) - todo} already done), "
             f"model {args.model}, effort {args.effort}, max {args.max_repairs} repairs.",
             f"  generation: up to {gen_calls} API calls, estimated "
             f"{llm.format_cost(llm.estimate_cost(args.model, gen_calls, config.ESTIMATE_TOKENS_GENERATION))}"]
    if args.judge:
        judge_calls = len(jobs) * (2 if config.JUDGE_WHICH == "both" else 1)
        lines.append(f"  judge ({config.JUDGE_MODEL}): up to {judge_calls} API calls, estimated "
                     f"{llm.format_cost(llm.estimate_cost(config.JUDGE_MODEL, judge_calls, config.ESTIMATE_TOKENS_JUDGE))}")
    else:
        lines.append("  judge: disabled")
    lines.append("  (pessimistic estimate; actual tokens and cost end up in the report)")
    return lines


def model_run(task_list: list[Task], run_dir: Path, args) -> int:
    import llm

    llm.load_api_key()
    jobs = [(task, s) for task in task_list for s in range(1, args.samples + 1)]
    llm.confirm_api_use(_spend_summary(jobs, run_dir, args), assume_yes=args.yes)
    client = llm.make_client()
    cfg = {"run_id": run_dir.name, "model": args.model, "effort": args.effort,
           "max_repairs": args.max_repairs, "max_tokens": args.max_tokens, "samples": args.samples,
           "timeout_s": args.timeout, "started": datetime.now(timezone.utc).isoformat(timespec="seconds"),
           "git": store.git_state()}
    _check_config(run_dir, cfg)
    evaluator.build_images([t.lang for t in task_list])

    log(f"Running {len(jobs)} samples with {args.workers} workers")
    failures = 0
    with ThreadPoolExecutor(args.workers) as pool:
        futures = {pool.submit(run_sample, task, s, run_dir, cfg, client, args): (task, s) for task, s in jobs}
        for fut in as_completed(futures):
            task, s = futures[fut]
            try:
                fut.result()
            except llm.FATAL_ERRORS as exc:
                pool.shutdown(wait=False, cancel_futures=True)
                log(f"FATAL API error on {task.id} s{s}: {exc}")
                return 2
            except Exception as exc:  # network trouble, Docker hiccup: leave the sample for a resume
                failures += 1
                log(f"[{task.id} s{s}] ERROR {type(exc).__name__}: {exc} (rerun the same command to resume)")

    store.write_jsonl(run_dir / "attempts.jsonl", store.collect_attempts(run_dir))
    finals = store.collect_finals(run_dir)
    log(f"\nGeneration done: {len(finals)} samples finished, {sum(f['solved'] for f in finals)} solved, "
        f"{failures} errors.")

    status = 1 if failures else 0
    if args.judge:
        import judge
        log("")
        status = max(status, judge.run_judging(run_dir, client, config.JUDGE_MODEL, config.JUDGE_EFFORT,
                                               config.JUDGE_WHICH, args.workers))
    if args.report:
        import report
        log(f"\nReport: {report.write_report(run_dir)}")
    if failures:
        log("Some samples failed; rerun the same command to resume them.")
    return status


# --------------------------------------------------------------------------- CLI

def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = p.add_mutually_exclusive_group()
    mode.add_argument("--dry-run", action="store_true", help="render prompts only (no API, no Docker)")
    mode.add_argument("--baseline", action="store_true", help="evaluate stubs and references (no API)")
    p.add_argument("--run-id", default=config.RUN_ID, help=f"results/<run-id>/ (config: {config.RUN_ID})")
    p.add_argument("--langs", help="comma-separated subset, e.g. C,Haskell (config: LANGUAGES)")
    p.add_argument("--tests", help="comma-separated test numbers, e.g. 4,5 (config: TESTS)")
    p.add_argument("--samples", type=int, default=config.SAMPLES)
    p.add_argument("--max-repairs", type=int, default=config.MAX_REPAIRS)
    p.add_argument("--workers", type=int, default=config.WORKERS)
    p.add_argument("--model", default=config.GENERATOR_MODEL)
    p.add_argument("--effort", default=config.GENERATOR_EFFORT, choices=["low", "medium", "high", "xhigh", "max"])
    p.add_argument("--max-tokens", type=int, default=config.GENERATOR_MAX_TOKENS)
    p.add_argument("--timeout", type=int, default=config.TIMEOUT_S, help="seconds per Docker test run")
    p.add_argument("--no-judge", dest="judge", action="store_false", default=config.JUDGE_ENABLED,
                   help="skip the idiomaticity judge (config: JUDGE_ENABLED)")
    p.add_argument("--no-report", dest="report", action="store_false", default=config.REPORT_ENABLED,
                   help="skip report.md (config: REPORT_ENABLED)")
    p.add_argument("--yes", action="store_true", help="do not ask before making API calls")
    p.add_argument("--keep-work", action="store_true", help="keep .work/ copies for debugging")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    args = parse_args(sys.argv[1:] if argv is None else argv)
    langs = args.langs.split(",") if args.langs else config.LANGUAGES
    numbers = [int(n) for n in args.tests.split(",")] if args.tests else config.TESTS
    task_list = tasks.discover(langs, numbers)
    if not task_list:
        raise SystemExit("no tasks match the selected languages/tests")
    if args.dry_run:
        return dry_run(task_list)
    run_dir = store.RESULTS / args.run_id  # created on first write, after the API key check
    if args.baseline:
        return baseline(task_list, run_dir, args)
    return model_run(task_list, run_dir, args)


if __name__ == "__main__":
    sys.exit(main())
