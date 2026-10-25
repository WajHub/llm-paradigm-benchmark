"""Aggregates results/<run_id>/ into report.md, summary.csv and attempts.jsonl.

run.py calls it automatically when config.REPORT_ENABLED is set.

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
from tasks import LANGUAGES, PARADIGMS

CRITERIA = ["paradigm_idiomaticity", "language_idiomaticity", "readability", "design"]
CRITERIA_PL = {"paradigm_idiomaticity": "paradygmat", "language_idiomaticity": "język",
               "readability": "czytelność", "design": "projekt"}
PARADIGM_ORDER = ["imperative", "object-oriented", "functional", "logic"]
PARADIGM_PL = {"imperative": "imperatywny", "object-oriented": "obiektowy",
               "functional": "funkcyjny", "logic": "logiczny"}
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
    by_cell = defaultdict(list)
    for f in finals:
        by_cell[(f["lang"], f["test"])].append(f)

    # ---- summary rows (one per sample)
    summary = []
    for f in finals:
        tid = f"{f['lang']}/{f['test']}"
        stub = stub_pass.get(tid, set())
        j = judge_by_attempt.get((f["lang"], f["test"], f["sample"], f["attempts_used"] - 1))
        summary.append({
            "lang": f["lang"], "paradigm": f["paradigm"], "test": f["test"], "sample": f["sample"],
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

    md = [f"# Raport z przebiegu `{run_dir.name}`", ""]
    git = cfg.get("git", {})
    md.append(f"Model **{model}**, effort `{cfg.get('effort', '?')}`, maks. {cfg.get('max_repairs', '?')} rundy "
              f"naprawcze, {cfg.get('samples', 1)} próba/y na zadanie. Commit `{git.get('commit', '?')[:7]}`"
              f"{' (z niezacommitowanymi zmianami)' if git.get('dirty') else ''}, start {cfg.get('started', '?')}.")
    md.append(f"Ukończone próbki: **{len(finals)}**, rozwiązane (20/20, exit 0): "
              f"**{sum(f['solved'] for f in finals)}**.")
    md.append("")

    # ---- 1. language x test matrix
    md += ["## 1. Wyniki: język × test", "",
           "Komórka: testy zaliczone w 1. próbie → po naprawach; ✔ = rozwiązane (w nawiasie runda, "
           "w której to nastąpiło). Przy kilku próbkach: średnie i liczba rozwiązanych próbek.", ""]
    rows = []
    for lang in langs:
        row = [f"{lang} ({PARADIGM_PL[PARADIGMS[lang]]})"]
        for test in tests:
            cell = by_cell.get((lang, test), [])
            if not cell:
                row.append("–")
            elif len(cell) == 1:
                f = cell[0]
                mark = f" ✔ ({f['solved_at_attempt']})" if f["solved"] else ""
                row.append(f"{f['first_n_pass']} → {f['final_n_pass']}{mark}")
            else:
                row.append(f"{mean(f['first_n_pass'] for f in cell):.1f} → "
                           f"{mean(f['final_n_pass'] for f in cell):.1f} "
                           f"({sum(f['solved'] for f in cell)}/{len(cell)})")
        lf = [f for f in finals if f["lang"] == lang]
        row.append(f"{sum(f['solved'] for f in lf)}/{len(lf)}")
        rows.append(row)
    md += [table(["Język", *tests, "Rozwiązane"], rows), ""]

    # ---- 2. paradigms, algorithm A vs B
    md += ["## 2. Paradygmaty", ""]
    rows = []
    for par in PARADIGM_ORDER:
        pf = [f for f in finals if f["paradigm"] == par]
        if not pf:
            continue
        n_tests = 20 * len(pf)
        first_a = sum(sum(t.startswith("A") for t in f["first_passed"]) for f in pf)
        final_a = sum(sum(t.startswith("A") for t in f["final_passed"]) for f in pf)
        first_b = sum(sum(t.startswith("B") for t in f["first_passed"]) for f in pf)
        final_b = sum(sum(t.startswith("B") for t in f["final_passed"]) for f in pf)
        rows.append([PARADIGM_PL[par], ", ".join(l for l in langs if PARADIGMS[l] == par), len(pf),
                     pct(sum(f["first_n_pass"] for f in pf), n_tests),
                     pct(sum(f["final_n_pass"] for f in pf), n_tests),
                     f"{sum(f['first_category'] == 'pass' for f in pf)}/{len(pf)}",
                     f"{sum(f['solved'] for f in pf)}/{len(pf)}",
                     f"{pct(first_a, n_tests / 2)} → {pct(final_a, n_tests / 2)}",
                     f"{pct(first_b, n_tests / 2)} → {pct(final_b, n_tests / 2)}"])
    md += [table(["Paradygmat", "Języki", "Próbki", "% testów (1. próba)", "% testów (final)",
                  "Rozwiązane (1. próba)", "Rozwiązane (final)", "Algorytm A", "Algorytm B"], rows), ""]

    # ---- 3. failure categories
    md += ["## 3. Kategorie wyników", "",
           "Wszystkie próby (łącznie z rundami naprawczymi) według kategorii wyniku ewaluacji.", ""]
    rows = []
    for lang in langs:
        counts = Counter(a["category"] for a in attempts if a["lang"] == lang)
        rows.append([lang, *[counts.get(c, 0) for c in CATEGORIES]])
    md += [table(["Język", *CATEGORIES], rows), ""]

    # ---- 4. self-repair
    md += ["## 4. Samonaprawa", ""]
    max_rep = cfg.get("max_repairs", 3)
    rows = []
    for lang in [*langs, "Razem"]:
        lf = finals if lang == "Razem" else [f for f in finals if f["lang"] == lang]
        failed_first = [f for f in lf if f["first_category"] != "pass"]
        repaired = [f for f in failed_first if f["solved"]]
        by_round = Counter(f["solved_at_attempt"] for f in lf if f["solved"])
        rows.append([lang, len(lf), *[by_round.get(r, 0) for r in range(max_rep + 1)],
                     sum(not f["solved"] for f in lf),
                     f"{len(repaired)}/{len(failed_first)} ({pct(len(repaired), len(failed_first))})",
                     fmt(mean(f["solved_at_attempt"] for f in repaired), 1) if repaired else "–"])
    md += [table(["Język", "Próbki", *[f"rozw. w rundzie {r}" for r in range(max_rep + 1)], "nierozw.",
                  "naprawione / oblane w 1. próbie", "śr. runda naprawy"], rows), ""]

    # ---- 5. idiomaticity
    md += ["## 5. Idiomatyczność (LLM-as-judge)", ""]
    final_judgements = [judge_by_attempt[k] for k in judge_by_attempt
                        if any(f["lang"] == k[0] and f["test"] == k[1] and f["sample"] == k[2]
                               and f["attempts_used"] - 1 == k[3] for f in finals)]
    if not final_judgements:
        md += ["Brak ocen: uruchom `python harness/judge.py --run-id " + run_dir.name + "`.", ""]
    else:
        judge_model = Counter(j["judge_model"] for j in final_judgements).most_common(1)[0][0]
        md += [f"Sędzia: `{judge_model}`, ocena ślepa (bez wyników testów) kodu z ostatniej próby, "
               f"skala 1–5. Kod, który się nie skompilował, nie jest oceniany.", ""]
        rows = []
        for group, members in ([(l, [j for j in final_judgements if j["lang"] == l]) for l in langs]
                               + [(PARADIGM_PL[p], [j for j in final_judgements if j["paradigm"] == p])
                                  for p in PARADIGM_ORDER]):
            if members:
                rows.append([group, len(members), *[fmt(mean(j[c] for j in members)) for c in CRITERIA],
                             fmt(mean(mean(j[c] for c in CRITERIA) for j in members))])
        md += [table(["Język / paradygmat", "n", *[CRITERIA_PL[c] for c in CRITERIA], "średnia"], rows), ""]
        anti = Counter(a.strip().lower() for j in final_judgements for a in j["anti_patterns"] if a.strip())
        if anti:
            md += ["Najczęstsze antywzorce:", ""]
            md += [f"- {name} ({n}×)" for name, n in anti.most_common(10)]
            md.append("")
            for lang in langs:
                la = Counter(a.strip().lower() for j in final_judgements if j["lang"] == lang
                             for a in j["anti_patterns"] if a.strip())
                if la:
                    md.append(f"- **{lang}**: " + "; ".join(f"{name} ({n}×)" for name, n in la.most_common(3)))
            md.append("")

    # ---- 6. tokens and cost
    md += ["## 6. Tokeny i koszt", ""]
    rows = []
    for lang in [*langs, "Razem"]:
        la = attempts if lang == "Razem" else [a for a in attempts if a["lang"] == lang]
        tin, tout = sum(a["input_tokens"] for a in la), sum(a["output_tokens"] for a in la)
        costs = [cost(a, model) for a in la]
        rows.append([lang, len(la), f"{tin:,}", f"{tout:,}",
                     "–" if None in costs else f"${sum(costs):.3f}",
                     sum(a["format_violation"] for a in la)])
    md += [table(["Język", "Wywołania", "Tokeny wej.", "Tokeny wyj. (z thinking)", "Koszt generacji",
                  "Kod w bloku Markdown mimo zakazu"], rows), ""]
    if judgements:
        jcost = [cost(j, j["judge_model"]) for j in judgements]
        md += [f"Koszt sędziego ({len(judgements)} ocen): "
               + ("–" if None in jcost else f"${sum(jcost):.3f}"), ""]

    # ---- 7. stub-passing tests
    md += ["## 7. Testy zaliczane już na stubie", ""]
    if not baseline:
        md += ["Brak `baseline.json`: uruchom `python harness/run.py --baseline --run-id " + run_dir.name + "`.", ""]
    else:
        md += ["Te testy przechodzą bez żadnej implementacji (oczekiwana odpowiedź = wartość stuba, "
               "np. `NULL`/`false`), więc zawyżają liczbę zaliczonych testów. Ostatnia kolumna liczy "
               "tylko pozostałe testy.", ""]
        rows = []
        for s in summary:
            tid = f"{s['lang']}/{s['test']}"
            if stub_pass.get(tid):
                rows.append([tid, s["sample"], ", ".join(sorted(stub_pass[tid])),
                             f"{s['final_n_pass']}/20",
                             f"{s['final_n_pass_excl_stub']}/{20 - s['stub_pass']}"])
        md += [table(["Zadanie", "Próbka", "Zaliczane na stubie", "Final", "Final bez testów ze stuba"], rows)
               if rows else "Żaden test nie przechodzi na stubie.", ""]
    return "\n".join(md), summary


def write_report(run_dir: Path) -> Path:
    markdown, summary = build(run_dir)
    (run_dir / "report.md").write_text(markdown, encoding="utf-8")
    store.write_jsonl(run_dir / "attempts.jsonl", store.collect_attempts(run_dir))
    with (run_dir / "summary.csv").open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(summary[0]))
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
