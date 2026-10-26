"""LLM-as-judge: blind idiomaticity scores for the solutions of a run.

run.py calls it automatically when config.JUDGE_ENABLED is set; use this script to judge
separately or to check the judge's stability first.

Examples:
    python harness/judge.py --calibrate       # stability check: same code judged twice
    python harness/judge.py                   # attempts selected by config.JUDGE_WHICH
    python harness/judge.py --which both      # first and final attempt
"""

from __future__ import annotations

import argparse
import json
import sys
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

import config
import evaluator
import llm
import prompts
import store
import tasks
from tasks import LANGUAGES, Task

FALLBACK_BETA = "server-side-fallback-2026-07-01"
RUBRIC = Path(__file__).with_name("rubrics.md")

CRITERIA = ["paradigm_idiomaticity", "language_idiomaticity", "readability", "design"]
_SCORE = {"type": "integer", "enum": [1, 2, 3, 4, 5]}
SCHEMA = {
    "type": "object",
    "properties": {
        **{c: _SCORE for c in CRITERIA},
        "anti_patterns": {"type": "array", "items": {"type": "string"}},
        "justification": {"type": "string"},
    },
    "required": [*CRITERIA, "anti_patterns", "justification"],
    "additionalProperties": False,
}

FENCE_TAGS = {"C": "c", "Pascal": "pascal", "Java": "java", "Smalltalk": "smalltalk",
              "Haskell": "haskell", "Scala": "scala", "Prolog": "prolog"}

_print_lock = threading.Lock()


def log(msg: str) -> None:
    with _print_lock:
        print(msg, flush=True)


def rubric_for(lang: str) -> str:
    """General rubric sections plus the section of `lang`."""
    sections: list[tuple[str, list[str]]] = [("", [])]
    for line in RUBRIC.read_text(encoding="utf-8").splitlines():
        if line.startswith("## "):
            sections.append((line[3:].strip(), [line]))
        else:
            sections[-1][1].append(line)
    keep = [lines for name, lines in sections if name not in LANGUAGES or name == lang]
    return "\n".join("\n".join(lines) for lines in keep).strip()


def build_messages(task: Task, code: str, code_name: str) -> tuple[str, str]:
    system = (f"You are an expert reviewer of {task.lang} code and of the {task.paradigm} programming "
              f"paradigm. You assess how idiomatic a solution to a programming task is. Apply the rubric "
              f"below and answer only with the requested JSON.\n\n{rubric_for(task.lang)}")
    tag = FENCE_TAGS[task.lang]
    contract = task.contract.read_text(encoding="utf-8")
    if task.contract.name != task.target:
        given = (f"## Contract given to the author ({task.contract.name}, not written by the author)\n"
                 f"```{tag}\n{contract}\n```")
    else:
        given = (f"## Stub module given to the author ({task.contract.name})\n"
                 f"The author replaced the stub bodies; type declarations and signatures come from it.\n"
                 f"```{tag}\n{contract}\n```")
    user = (f"Language: {task.lang} ({task.paradigm} paradigm)\n\n"
            f"## Task specification given to the author\n{prompts.task_requirements(task)}\n\n"
            f"{given}\n\n"
            f"## Code to evaluate ({code_name})\n```{tag}\n{code}\n```")
    return system, user


def judge_code(client, model: str, effort: str, task: Task, code: str, code_name: str) -> dict:
    system, user = build_messages(task, code, code_name)
    request = dict(
        model=model,
        max_tokens=config.JUDGE_MAX_TOKENS,
        thinking={"type": "adaptive"},
        output_config={"effort": effort, "format": {"type": "json_schema", "schema": SCHEMA}},
        system=system,
        messages=[{"role": "user", "content": user}],
    )
    # Server-side fallback re-runs a refused request on another model; Haiku models do not support it.
    if config.JUDGE_FALLBACK and not model.startswith("claude-haiku"):
        stream = client.beta.messages.stream(betas=[FALLBACK_BETA], fallbacks="default", **request)
    else:
        stream = client.messages.stream(**request)
    with stream as s:
        response = s.get_final_message()
    if response.stop_reason in ("refusal", "max_tokens"):
        raise RuntimeError(f"judge stopped with {response.stop_reason}")
    data = json.loads(llm.response_text(response))
    for c in CRITERIA:
        if data.get(c) not in (1, 2, 3, 4, 5):
            raise ValueError(f"invalid score {c}={data.get(c)!r}")
    return data | {"judge_model": response.model, "judge_effort": effort, **llm.usage_dict(response.usage)}


def judge_items(run_dir: Path, which: str) -> list[dict]:
    """Attempts to judge: (task, sample, attempt, code path), deduplicated by attempt."""
    items = []
    for final in store.collect_finals(run_dir):
        task = tasks.load_task(final["lang"], final["test"])
        sdir = store.sample_dir(run_dir, final["lang"], final["test"], final["sample"])
        wanted = {"first": [0], "final": [final["attempts_used"] - 1],
                  "both": [0, final["attempts_used"] - 1]}[which]
        for attempt in sorted(set(wanted)):
            adir = sdir / f"attempt-{attempt}"
            row = store.read_json(adir / "attempt.json")
            code_path = adir / f"solution{tasks.EXTENSIONS[task.lang]}"
            if row["category"] in evaluator.COMPILED and code_path.exists():
                items.append({"task": task, "sample": final["sample"], "attempt": attempt,
                              "category": row["category"], "code_path": code_path})
    return items


def _name(it: dict) -> str:
    return f"{it['task'].lang}-{it['task'].test}-s{it['sample']}-a{it['attempt']}.json"


def pending_items(run_dir: Path, which: str) -> list[dict]:
    return [it for it in judge_items(run_dir, which) if not (run_dir / "judge" / _name(it)).exists()]


def run_judging(run_dir: Path, client, model: str, effort: str, which: str, workers: int) -> int:
    out_dir = run_dir / "judge"
    todo = pending_items(run_dir, which)
    log(f"Judging {len(todo)} solutions with {model} (effort {effort}, attempts: {which})")

    def work(it: dict) -> dict:
        task = it["task"]
        result = judge_code(client, model, effort, task, it["code_path"].read_text(encoding="utf-8"), task.target)
        row = {"run_id": run_dir.name, "lang": task.lang, "paradigm": task.paradigm, "test": task.test,
               "sample": it["sample"], "attempt": it["attempt"], "category": it["category"]} | result
        store.write_json(out_dir / _name(it), row)
        return row

    errors = 0
    with ThreadPoolExecutor(workers) as pool:
        futures = {pool.submit(work, it): it for it in todo}
        for fut in as_completed(futures):
            it = futures[fut]
            try:
                row = fut.result()
                log(f"[judge] {it['task'].id} s{it['sample']} a{it['attempt']}: "
                    + " ".join(f"{c.split('_')[0]}={row[c]}" for c in CRITERIA))
            except llm.FATAL_ERRORS as exc:
                pool.shutdown(wait=False, cancel_futures=True)
                log(f"FATAL API error: {exc}")
                return 2
            except Exception as exc:
                errors += 1
                log(f"[judge] {it['task'].id} s{it['sample']} a{it['attempt']}: ERROR {exc}")

    rows = [store.read_json(p) for p in sorted(out_dir.glob("*.json"))] if out_dir.exists() else []
    store.write_jsonl(run_dir / "judge.jsonl", rows)
    log(f"judge.jsonl: {len(rows)} rows, {errors} errors")
    return 1 if errors else 0


def calibration_items(run_dir: Path, samples: int) -> list[tuple[str, Task, str]]:
    items = []
    for (lang, test) in tasks.REFERENCE_FILES:
        task = tasks.load_task(lang, test)
        items.append((f"reference {task.id}", task, tasks.reference_source(task)))
    for it in judge_items(run_dir, "final")[:samples]:
        items.append((f"run {it['task'].id} s{it['sample']} a{it['attempt']}", it["task"],
                      it["code_path"].read_text(encoding="utf-8")))
    return items


def calibrate(run_dir: Path, client, model: str, effort: str, repeat: int, samples: int, workers: int) -> int:
    """Judges reference solutions and a few run solutions `repeat` times to check stability."""
    items = calibration_items(run_dir, samples)
    jobs = [(label, task, code) for label, task, code in items for _ in range(repeat)]
    results: dict[str, list[dict]] = {}
    with ThreadPoolExecutor(workers) as pool:
        futures = {pool.submit(judge_code, client, model, effort, task, code, task.target): label
                   for label, task, code in jobs}
        for fut in as_completed(futures):
            results.setdefault(futures[fut], []).append(fut.result())

    rows, within_one, pairs = [], 0, 0
    log(f"\n{'item':<34} " + " ".join(f"{c.split('_')[0]:>12}" for c in CRITERIA))
    for label, scores in sorted(results.items()):
        cells = []
        for c in CRITERIA:
            values = [s[c] for s in scores]
            pairs += 1
            within_one += max(values) - min(values) <= 1
            cells.append(f"{'/'.join(map(str, values)):>12}")
        log(f"{label:<34} " + " ".join(cells))
        rows += [{"item": label, "repeat": i} | s for i, s in enumerate(scores)]
    store.write_jsonl(run_dir / "judge_calibration.jsonl", rows)
    log(f"\nScore spread <= 1 for {within_one}/{pairs} item-criterion pairs. "
        f"Details: {run_dir / 'judge_calibration.jsonl'}")
    return 0


def main(argv: list[str] | None = None) -> int:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--run-id", default=config.RUN_ID)
    p.add_argument("--which", choices=["final", "first", "both"], default=config.JUDGE_WHICH)
    p.add_argument("--model", default=config.JUDGE_MODEL)
    p.add_argument("--effort", default=config.JUDGE_EFFORT, choices=["low", "medium", "high", "xhigh", "max"])
    p.add_argument("--workers", type=int, default=config.WORKERS)
    p.add_argument("--calibrate", action="store_true", help="stability check instead of judging the run")
    p.add_argument("--yes", action="store_true", help="do not ask before making API calls")
    args = p.parse_args(sys.argv[1:] if argv is None else argv)

    run_dir = store.RESULTS / args.run_id
    if not run_dir.exists():
        raise SystemExit(f"{run_dir} does not exist; run harness/run.py first")
    llm.load_api_key()
    if args.calibrate:
        calls = len(calibration_items(run_dir, config.CALIBRATION_SAMPLES)) * config.CALIBRATION_REPEAT
        what = f"Calibration of {args.model}"
    else:
        calls = len(pending_items(run_dir, args.which))
        what = f"Judging {run_dir.name} with {args.model}"
    estimate = llm.format_cost(llm.estimate_cost(args.model, calls, config.ESTIMATE_TOKENS_JUDGE))
    llm.confirm_api_use([f"{what}: {calls} API calls, estimated {estimate}"], assume_yes=args.yes)
    client = llm.make_client()
    if args.calibrate:
        return calibrate(run_dir, client, args.model, args.effort, config.CALIBRATION_REPEAT,
                         config.CALIBRATION_SAMPLES, args.workers)
    return run_judging(run_dir, client, args.model, args.effort, args.which, args.workers)


if __name__ == "__main__":
    sys.exit(main())
