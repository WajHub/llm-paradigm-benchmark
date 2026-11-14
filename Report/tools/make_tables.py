#!/usr/bin/env python3
"""Generate the data-heavy LaTeX tables of the report from one run's results.

Usage (from the repository root):
    python Report/tools/make_tables.py                 # uses results/haiku-v1
    python Report/tools/make_tables.py results/<run>   # another run

Writes tabular bodies to Report/tables/*.tex. Captions and labels stay in the chapter files,
so re-running the script after a new run only refreshes the numbers. Assumes one sample per
task (SAMPLES = 1); with more samples the per-cell aggregation has to be extended.
"""

from __future__ import annotations

import csv
import json
import statistics as st
import sys
from pathlib import Path

REPORT = Path(__file__).resolve().parent.parent
REPO = REPORT.parent
RUN = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO / "results" / "haiku-v1"
OUT = REPORT / "tables"

LANGS = ["C", "Pascal", "Java", "Smalltalk", "Haskell", "Scala", "Prolog"]
PARADIGM = {"C": "Imp.", "Pascal": "Imp.", "Java": "Ob.", "Smalltalk": "Ob.",
            "Haskell": "Funk.", "Scala": "Funk.", "Prolog": "Log."}
TESTS = [f"test-{i}" for i in range(1, 11)]
CRIT = ["paradigm_idiomaticity", "language_idiomaticity", "readability", "design"]


def dec(value: float, digits: int = 2) -> str:
    """Polish number format: decimal comma."""
    return f"{value:.{digits}f}".replace(".", ",")


def load() -> tuple[dict, dict]:
    rows = list(csv.DictReader(open(RUN / "summary.csv", encoding="utf-8")))
    keys = [(r["lang"], r["test"]) for r in rows]
    if len(keys) != len(set(keys)):
        raise SystemExit("more than one sample per task: extend the aggregation first")
    summary = {(r["lang"], r["test"]): r for r in rows}
    judge = {}
    for line in open(RUN / "judge.jsonl", encoding="utf-8"):
        j = json.loads(line)
        judge[(j["lang"], j["test"])] = j
    return summary, judge


def matrix_cell(r: dict) -> str:
    first, final = int(r["first_n_pass"]), int(r["final_n_pass"])
    if r["solved"] == "True":
        at = int(r["solved_at_attempt"])
        return rf"\resfirst{{{final}}}" if at == 0 else rf"\resrep{{{first}}}{{{final}}}{{{at}}}"
    return rf"\resfail{{{first}}}{{{final}}}"


def write_matrix(summary: dict) -> None:
    lines = []
    for lang in LANGS:
        cells = [matrix_cell(summary[(lang, t)]) for t in TESTS]
        solved = sum(summary[(lang, t)]["solved"] == "True" for t in TESTS)
        lines.append(f"{lang} & " + " & ".join(cells) + rf" & {solved}/10 \\")
    (OUT / "matrix.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def heat(value: float) -> str:
    """Sequential blue ramp (light = lower score); white ink on the two darkest steps."""
    if value >= 4.0:
        return rf"\cellcolor{{seq600}}\textcolor{{white}}{{{dec(value)}}}"
    if value >= 3.75:
        return rf"\cellcolor{{seq500}}\textcolor{{white}}{{{dec(value)}}}"
    if value >= 3.5:
        return rf"\cellcolor{{seq300}}{dec(value)}"
    if value >= 3.25:
        return rf"\cellcolor{{seq150}}{dec(value)}"
    return rf"\cellcolor{{seq050}}{dec(value)}"


def write_judge_heatmap(judge: dict) -> None:
    lines = []
    for lang in LANGS:
        means = [st.mean(judge[(lang, t)][c] for c in CRIT) for t in TESTS]
        lines.append(f"{lang} & " + " & ".join(heat(m) for m in means)
                     + rf" & {dec(st.mean(means))} \\")
    col_means = [st.mean(st.mean(judge[(lang, t)][c] for c in CRIT) for lang in LANGS) for t in TESTS]
    lines.append(r"\midrule")
    lines.append(r"Średnia & " + " & ".join(dec(m) for m in col_means) + r" & \\")
    (OUT / "judge_heatmap.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_paradigm_scores(judge: dict) -> None:
    lines = []
    for lang in LANGS:
        cells = []
        for t in TESTS:
            s = judge[(lang, t)]["paradigm_idiomaticity"]
            cells.append({5: r"\cellcolor{seq600}\textcolor{white}{5}", 4: r"\cellcolor{seq300}4",
                          3: r"\cellcolor{seq050}3"}.get(s, str(s)))
        lines.append(f"{lang} & " + " & ".join(cells) + r" \\")
    (OUT / "paradigm_scores.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_full(summary: dict, judge: dict) -> None:
    lines = []
    for lang in LANGS:
        for t in TESTS:
            r, j = summary[(lang, t)], judge[(lang, t)]
            at = r["solved_at_attempt"] if r["solved"] == "True" else r"\textemdash"
            scores = " & ".join(str(j[c]) for c in CRIT)
            tokens = f"{int(r['output_tokens']):,}".replace(",", r"\,")  # thin-space thousands
            lines.append(
                f"{lang} & {t.split('-')[1]} & {r['first_category'].replace('_', ' ')} & "
                f"{r['first_n_pass']} & {r['final_n_pass']} & {at} & {r['attempts_used']} & "
                f"{tokens} & {scores} & {dec(float(r['judge_mean']))} \\\\")
        if lang != LANGS[-1]:
            lines.append(r"\addlinespace[3pt]")
    (OUT / "full_results.tex").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    OUT.mkdir(exist_ok=True)
    summary, judge = load()
    write_matrix(summary)
    write_judge_heatmap(judge)
    write_paradigm_scores(judge)
    write_full(summary, judge)
    print(f"tables written to {OUT} from {RUN}")


if __name__ == "__main__":
    main()
