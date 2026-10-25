"""Aggregates results/<run_id>/ into report.md, summary.csv and attempts.jsonl.

run.py calls it automatically when config.REPORT_ENABLED is set.
How to read the report: docs/03-report.md.

Example:
    python harness/report.py                  # run from config.RUN_ID
    python harness/report.py --run-id other
"""

from __future__ import annotations

import argparse
import csv
import sys
from collections import Counter, defaultdict
from pathlib import Path
from statistics import mean

import config
import store
from evaluator import COMPILED
from tasks import LANGUAGES, PARADIGMS

CRITERIA = ["paradigm_idiomaticity", "language_idiomaticity", "readability", "design"]
CRITERIA_LABELS = {"paradigm_idiomaticity": "Paradigm idioms", "language_idiomaticity": "Language idioms",
                   "readability": "Readability", "design": "Design"}
PARADIGM_ORDER = list(dict.fromkeys(PARADIGMS.values()))
CATEGORIES = ["pass", "test_failures", "memory_error", "compile_error", "runtime_crash",
              "timeout", "truncated", "refusal", "empty_output"]


def cost(row: dict, model: str) -> float | None:
    """USD from config.PRICES; cache writes cost 1.25x and cache reads 0.1x the input price."""
    if model not in config.PRICES:
        return None
    pin, pout = config.PRICES[model]
    return (row["input_tokens"] * pin + row["output_tokens"] * pout
            + row.get("cache_creation_input_tokens", 0) * pin * 1.25
            + row.get("cache_read_input_tokens", 0) * pin * 0.1) / 1e6


def table(headers: list[str], rows: list[list]) -> str:
    out = ["| " + " | ".join(headers) + " |", "|" + "---|" * len(headers)]
    out += ["| " + " | ".join(str(c) for c in row) + " |" for row in rows]
    return "\n".join(out)


def pct(part: float, whole: float) -> str:
    return f"{100 * part / whole:.0f}%" if whole else "–"


def fmt(x: float | None, digits: int = 2) -> str:
    return "–" if x is None else f"{x:.{digits}f}"


def build(run_dir: Path) -> tuple[str, list[dict]]:
    cfg = store.read_json(run_dir / "config.json") if (run_dir / "config.json").exists() else {}
    model = cfg.get("model", "?")
    finals = store.collect_finals(run_dir)
    attempts = store.collect_attempts(run_dir)
    baseline = store.read_json(run_dir / "baseline.json") if (run_dir / "baseline.json").exists() else {}
    judge_dir = run_dir / "judge"
    judgements = [store.read_json(p) for p in sorted(judge_dir.glob("*.json"))] if judge_dir.exists() else []
    if not finals:
        raise SystemExit(f"{run_dir}: no finished samples (final.json) found")

    stub_pass = {tid: set(e["stub"]["passed"]) for tid, e in baseline.items()}
    judge_by_attempt = {(j["lang"], j["test"], j["sample"], j["attempt"]): j for j in judgements}
    tests = sorted({f["test"] for f in finals}, key=lambda t: int(t.split("-")[1]))
    langs = [l for l in LANGUAGES if any(f["lang"] == l for f in finals)]
    max_rep = cfg.get("max_repairs", config.MAX_REPAIRS)
    by_cell = defaultdict(list)
    for f in finals:
        by_cell[(f["lang"], f["test"])].append(f)
    # Every attempt lists all tests of its task as passed or failed.
    test_ids = defaultdict(set)
    for a in attempts:
        test_ids[(a["lang"], a["test"], a["sample"])].update(a["passed"], a["failed"])

    def ids_of(f: dict) -> set[str]:
        return test_ids[(f["lang"], f["test"], f["sample"])]

    algorithms = sorted({i[0] for ids in test_ids.values() for i in ids})

    # ---- summary rows (one per sample)
    summary = []
    for f in finals:
        tid = f"{f['lang']}/{f['test']}"
        stub = stub_pass.get(tid, set())
        j = judge_by_attempt.get((f["lang"], f["test"], f["sample"], f["attempts_used"] - 1))
        summary.append({
            "lang": f["lang"], "paradigm": f["paradigm"], "test": f["test"], "sample": f["sample"],
            "n_tests": len(ids_of(f)),
            "first_category": f["first_category"], "first_n_pass": f["first_n_pass"],
            "final_category": f["final_category"], "final_n_pass": f["final_n_pass"],
            "solved": f["solved"], "solved_at_attempt": f["solved_at_attempt"],
            "attempts_used": f["attempts_used"],
            "stub_pass": len(stub),
            "final_n_pass_excl_stub": len(set(f["final_passed"]) - stub),
            "input_tokens": f["input_tokens"], "output_tokens": f["output_tokens"],
            "cost_usd": cost(f, model), "format_violations": f["format_violations"],
            **{c: (j[c] if j else None) for c in CRITERIA},
            "judge_mean": mean(j[c] for c in CRITERIA) if j else None,
        })

    md = [f"# Run report: `{run_dir.name}`", ""]
    git = cfg.get("git", {})
    md.append(f"Model **{model}**, effort `{cfg.get('effort', '?')}`, up to {cfg.get('max_repairs', '?')} repair "
              f"rounds, {cfg.get('samples', 1)} sample(s) per task. Commit `{git.get('commit', '?')[:7]}`"
              f"{' (with uncommitted changes)' if git.get('dirty') else ''}, started {cfg.get('started', '?')}.")
    md.append(f"Finished samples: **{len(finals)}**, solved (all tests pass, clean exit): "
              f"**{sum(f['solved'] for f in finals)}**.")
    md.append("")
    md.append("How to read this report: [docs/03-report.md](../../docs/03-report.md).")
    md.append("")

    # ---- 1. language x test matrix
    md += ["## 1. Results: language × test", "",
           "Cell: tests passed in the first attempt → in the final attempt / tests of the task. "
           "✔ = solved; the number in brackets is the attempt that solved it (0 = first answer"
           + (f", 1–{max_rep} = repair round" if max_rep else "") + "). "
           "With several samples: means and the number of solved samples.", ""]
    rows = []
    for lang in langs:
        row = [f"{lang} ({PARADIGMS[lang]})"]
        for test in tests:
            cell = by_cell.get((lang, test), [])
            if not cell:
                row.append("–")
            elif len(cell) == 1:
                f = cell[0]
                mark = f" ✔ ({f['solved_at_attempt']})" if f["solved"] else ""
                row.append(f"{f['first_n_pass']} → {f['final_n_pass']}/{len(ids_of(f))}{mark}")
            else:
                row.append(f"{mean(f['first_n_pass'] for f in cell):.1f} → "
                           f"{mean(f['final_n_pass'] for f in cell):.1f}/{len(ids_of(cell[0]))} "
                           f"({sum(f['solved'] for f in cell)}/{len(cell)})")
        lf = [f for f in finals if f["lang"] == lang]
        row.append(f"{sum(f['solved'] for f in lf)}/{len(lf)}")
        rows.append(row)
    md += [table(["Language", *tests, "Solved"], rows), ""]

    # ---- 2. paradigms, algorithm A vs B
    md += ["## 2. Paradigms", "",
           "Tests passed as a share of all tests of the paradigm's samples; \"solved\" counts whole tasks. "
           "Algorithm columns: the tests of one algorithm (A01, A02, … for A), first attempt → final attempt.", ""]
    rows = []
    for par in PARADIGM_ORDER:
        pf = [f for f in finals if f["paradigm"] == par]
        if not pf:
            continue
        n_tests = sum(len(ids_of(f)) for f in pf)
        per_algorithm = []
        for alg in algorithms:
            total = sum(sum(i.startswith(alg) for i in ids_of(f)) for f in pf)
            first = sum(sum(i.startswith(alg) for i in f["first_passed"]) for f in pf)
            final = sum(sum(i.startswith(alg) for i in f["final_passed"]) for f in pf)
            per_algorithm.append(f"{pct(first, total)} → {pct(final, total)}")
        rows.append([par, ", ".join(l for l in langs if PARADIGMS[l] == par), len(pf),
                     pct(sum(f["first_n_pass"] for f in pf), n_tests),
                     pct(sum(f["final_n_pass"] for f in pf), n_tests),
                     f"{sum(f['first_category'] == 'pass' for f in pf)}/{len(pf)}",
                     f"{sum(f['solved'] for f in pf)}/{len(pf)}",
                     *per_algorithm])
    md += [table(["Paradigm", "Languages", "Samples", "Tests passed (first)", "Tests passed (final)",
                  "Solved (first)", "Solved (final)", *[f"Algorithm {a}" for a in algorithms]], rows), ""]

    # ---- 3. outcome categories
    md += ["## 3. Outcome categories", "",
           "Every attempt (repair rounds included) by outcome. pass = all tests pass and clean exit; "
           "test_failures = some tests fail; memory_error = all tests pass but the run exits with an error "
           "(valgrind found leaks or invalid memory access); compile_error = the code did not build, no test "
           "ran; runtime_crash = the test program died before the summary; timeout = over the time limit; "
           "truncated / refusal / empty_output = the answer contained no usable code.", ""]
    rows = []
    for lang in langs:
        counts = Counter(a["category"] for a in attempts if a["lang"] == lang)
        rows.append([lang, *[counts.get(c, 0) for c in CATEGORIES]])
    md += [table(["Language", *CATEGORIES], rows), ""]

    # ---- 4. self-repair
    md += ["## 4. Self-repair", "",
           "Attempt 0 is the first answer; in each repair round the model gets the test log and the names "
           "of the failing tests. \"Repaired\" = tasks failed in attempt 0 and solved later.", ""]
    rows = []
    for lang in [*langs, "Total"]:
        lf = finals if lang == "Total" else [f for f in finals if f["lang"] == lang]
        failed_first = [f for f in lf if f["first_category"] != "pass"]
        repaired = [f for f in failed_first if f["solved"]]
        by_round = Counter(f["solved_at_attempt"] for f in lf if f["solved"])
        rows.append([lang, len(lf), *[by_round.get(r, 0) for r in range(max_rep + 1)],
                     sum(not f["solved"] for f in lf),
                     f"{len(repaired)}/{len(failed_first)} ({pct(len(repaired), len(failed_first))})",
                     fmt(mean(f["solved_at_attempt"] for f in repaired), 1) if repaired else "–"])
    md += [table(["Language", "Samples", *[f"Solved at attempt {r}" for r in range(max_rep + 1)], "Unsolved",
                  "Repaired / failed at attempt 0", "Mean repair round"], rows), ""]

    # ---- 5. idiomaticity
    md += ["## 5. Idiomaticity (LLM-as-judge)", ""]
    final_judgements = [judge_by_attempt[k] for k in judge_by_attempt
                        if any(f["lang"] == k[0] and f["test"] == k[1] and f["sample"] == k[2]
                               and f["attempts_used"] - 1 == k[3] for f in finals)]
    if not final_judgements:
        md += ["No judgements yet: run `python harness/judge.py --run-id " + run_dir.name + "`.", ""]
    else:
        judge_model = Counter(j["judge_model"] for j in final_judgements).most_common(1)[0][0]
        md += [f"Judge `{judge_model}` scores the code of the final attempt blind (no test results, no model "
               f"name), 1 = poor, 5 = excellent. n = judged solutions. Paradigm idioms: written in the style of "
               f"the paradigm (e.g. pure functions in Haskell, relations in Prolog, objects in Smalltalk). "
               f"Language idioms: this language's conventions and standard library. Readability: naming, "
               f"structure, clarity. Design: decomposition, data structures, error and memory handling. "
               f"Rubric: [harness/rubrics.md](../../harness/rubrics.md).", ""]
        rows = []
        for group, members in ([(l, [j for j in final_judgements if j["lang"] == l]) for l in langs]
                               + [(p, [j for j in final_judgements if j["paradigm"] == p])
                                  for p in PARADIGM_ORDER]):
            if members:
                rows.append([group, len(members), *[fmt(mean(j[c] for j in members)) for c in CRITERIA],
                             fmt(mean(mean(j[c] for c in CRITERIA) for j in members))])
        md += [table(["Language / paradigm", "n", *[CRITERIA_LABELS[c] for c in CRITERIA], "Mean"], rows), ""]
        not_compiled = [f for f in finals if f["final_category"] not in COMPILED]
        missing = [f for f in finals if f["final_category"] in COMPILED
                   and (f["lang"], f["test"], f["sample"], f["attempts_used"] - 1) not in judge_by_attempt]
        if not_compiled:
            md += ["Not judged, final code did not compile: "
                   + ", ".join(f"{f['lang']}/{f['test']}" for f in not_compiled) + ".", ""]
        if missing:
            md += ["Not judged yet (judge call failed or was skipped): "
                   + ", ".join(f"{f['lang']}/{f['test']}" for f in missing)
                   + f". Rerun `python harness/judge.py --run-id {run_dir.name}`, then `python harness/report.py`.", ""]
        md += ["Anti-patterns named by the judge (up to 3 per language):", ""]
        for lang in langs:
            la = Counter(a.strip() for j in final_judgements if j["lang"] == lang
                         for a in j["anti_patterns"] if a.strip())
            if la:
                md.append(f"- **{lang}**: " + "; ".join(name + (f" ({n}×)" if n > 1 else "")
                                                       for name, n in la.most_common(3)))
        md.append("")

    # ---- 6. tokens and cost
    md += ["## 6. Tokens and cost", "",
           "Format violations: answers in which the model wrapped the code in a Markdown ``` block although "
           "the prompt asks for raw code only. The harness still extracts the code, so this does not fail the "
           "task; it measures instruction following.", ""]
    rows = []
    for lang in [*langs, "Total"]:
        la = attempts if lang == "Total" else [a for a in attempts if a["lang"] == lang]
        tin, tout = sum(a["input_tokens"] for a in la), sum(a["output_tokens"] for a in la)
        costs = [cost(a, model) for a in la]
        rows.append([lang, len(la), f"{tin:,}", f"{tout:,}",
                     "–" if None in costs else f"${sum(costs):.3f}",
                     sum(a["format_violation"] for a in la)])
    md += [table(["Language", "API calls", "Input tokens", "Output tokens (incl. thinking)", "Generation cost",
                  "Format violations"], rows), ""]
    if judgements:
        jcost = [cost(j, j["judge_model"]) for j in judgements]
        md += [f"Judge cost ({len(judgements)} judgements): "
               + ("–" if None in jcost else f"${sum(jcost):.3f}"), ""]

    # ---- 7. stub-passing tests
    md += ["## 7. Tests that pass on the stub", ""]
    if not baseline:
        md += ["No `baseline.json`: run `python harness/run.py --baseline --run-id " + run_dir.name + "`.", ""]
    else:
        md += ["These tests pass without any implementation (the expected answer equals the stub's return "
               "value, e.g. `NULL`/`false`), so they inflate pass counts. The last column counts only the "
               "remaining tests.", ""]
        rows = []
        for s in summary:
            tid = f"{s['lang']}/{s['test']}"
            if stub_pass.get(tid):
                rows.append([tid, s["sample"], ", ".join(sorted(stub_pass[tid])),
                             f"{s['final_n_pass']}/{s['n_tests']}",
                             f"{s['final_n_pass_excl_stub']}/{s['n_tests'] - s['stub_pass']}"])
        md += [table(["Task", "Sample", "Passing on the stub", "Final", "Final without stub-passing tests"], rows)
               if rows else "No test passes on the stub.", ""]
    return "\n".join(md), summary


def write_report(run_dir: Path) -> Path:
    markdown, summary = build(run_dir)
    (run_dir / "report.md").write_text(markdown, encoding="utf-8", newline="\n")
    store.write_jsonl(run_dir / "attempts.jsonl", store.collect_attempts(run_dir))
    with (run_dir / "summary.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(summary[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(summary)
    return run_dir / "report.md"


def main(argv: list[str] | None = None) -> int:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--run-id", default=config.RUN_ID)
    args = p.parse_args(sys.argv[1:] if argv is None else argv)
    path = write_report(store.RESULTS / args.run_id)
    print(f"Wrote {path}, summary.csv and attempts.jsonl")
    return 0


if __name__ == "__main__":
    sys.exit(main())
