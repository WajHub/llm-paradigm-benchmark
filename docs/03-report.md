# 3. Reading the report

Each run writes its results to `results/<RUN_ID>/`. This page explains the files there and every
section of `report.md`.

Previous: [2. Running the evaluation](02-running.md) · Start: [1. How the benchmark works](01-how-it-works.md)

## Terms

| Term | Meaning |
|---|---|
| **task** | one language × one test folder, e.g. `Haskell/test-4` |
| **sample** | one independent run of a task; there are `SAMPLES` per task |
| **attempt** | one answer of the model. Attempt 0 is the first answer; attempts 1, 2, … are repair rounds, at most `MAX_REPAIRS` |
| **first / final** | attempt 0 / the last attempt of a sample |
| **solved** | every test of the task passes and the run exits cleanly (no valgrind errors) |
| **stub** | the "not implemented" file in the repository that the model's code replaces |

## Files in `results/<RUN_ID>/`

| File | Contents |
|---|---|
| `report.md` | the human-readable summary described below |
| `summary.csv` | one row per sample, for a spreadsheet or pandas ([columns](#summarycsv-columns)) |
| `attempts.jsonl` | one JSON line per attempt: outcome, passed and failed tests, tokens, timing |
| `judge.jsonl`, `judge/` | the judge's scores; `judge/` has one file per judged solution with the justification |
| `judge_calibration.jsonl` | results of `judge.py --calibrate` |
| `config.json` | the run's settings and the git commit it ran on |
| `baseline.json`, `baseline/` | the evaluator check on stubs and reference solutions, with logs |
| `<Language>/test-N/sample-K/attempt-J/` | everything about one attempt (below) |
| `<Language>/test-N/sample-K/final.json` | summary of the sample: outcome, solved at which attempt, tokens |

One attempt folder contains:

| File | Contents |
|---|---|
| `prompt.md` | exactly what the model received in this attempt |
| `response.json` | the full API response |
| `solution.<ext>` | the code extracted from the answer |
| `eval.log` | the complete output of the test run (compiler, tests, valgrind) |
| `eval.json`, `attempt.json` | the parsed result and the attempt's summary |

To follow what happened in one task, read `attempt-0/prompt.md` → `attempt-0/solution.*` →
`attempt-0/eval.log` → `attempt-1/prompt.md` (what the model was told about its mistake) → and so on.

## Header

The first lines name the model, its effort, the maximum number of repair rounds, the samples per task,
the commit the run used (marked when there were uncommitted changes) and the start time. Then the
number of finished samples and how many were solved.

## 1. Results: language × test

One row per language, one column per test folder, and the number of solved tasks per language at the
end. A cell reads:

```
<tests passed in attempt 0> → <tests passed in the final attempt>/<tests of the task> [✔ (<attempt>)]
```

| Example cell | Meaning |
|---|---|
| `20 → 20/20 ✔ (0)` | solved by the first answer |
| `18 → 20/20 ✔ (2)` | 18 tests passed at first, solved in repair round 2 |
| `0 → 20/20 ✔ (1)` | the first answer did not compile (no test ran), repair round 1 fixed it |
| `0 → 16/20` | not solved: after the last repair round 16 tests pass |
| `17 → 17/20` | the repairs did not help |

"Final" is the last attempt, not the best one: a repair can also make things worse. The best result of a
sample is `best_n_pass` in its `final.json`. With several samples per task the cell shows means and how
many samples were solved, e.g. `15.5 → 19.0/20 (2/3)`.

## 2. Paradigms

The same results grouped by paradigm.

| Column | Meaning |
|---|---|
| Languages, Samples | languages of the paradigm and how many samples they contribute |
| Tests passed (first / final) | passed tests as a share of all tests of these samples, in attempt 0 / in the final attempt |
| Solved (first / final) | tasks solved by attempt 0 / by the end |
| Algorithm A, B, … | the same share counted separately for the tests of each algorithm (`A01`, `A02`, … belong to A), first → final |

The algorithm columns show whether one part of the tasks is harder: for example a parser (A) versus an
evaluator (B). A paradigm with fewer languages contributes fewer samples, so its percentages move more
with every single task.

## 3. Outcome categories

How many attempts (repair rounds included) ended in each category. A task solved at once contributes one
`pass`; a task that needed three repairs contributes four attempts.

| Category | Meaning | How it is detected |
|---|---|---|
| `pass` | solved | every test printed `[PASS]` and the exit code is 0 |
| `test_failures` | some tests fail | at least one `[FAIL]`, or a test never printed a result |
| `memory_error` | correct results, but memory problems | every test passed, but the exit code is not 0 (valgrind reports leaks or invalid access) |
| `compile_error` | the code did not build or load | `=== START ===` never appeared |
| `runtime_crash` | the test program died | `=== START ===` appeared, `=== BENCHMARK RESULTS ===` did not |
| `timeout` | too slow or an infinite loop | the run exceeded `TIMEOUT_S` and was killed |
| `truncated` | the answer was cut off | the model hit `GENERATOR_MAX_TOKENS` before finishing the code |
| `refusal` | the model declined | the API returned `stop_reason: refusal` |
| `empty_output` | no code in the answer | nothing to save as a source file |

The last three are never tested: there is no usable code.

## 4. Self-repair

How well the model fixes its own code when it sees the test log and the failing test names.

| Column | Meaning |
|---|---|
| Samples | samples of the language |
| Solved at attempt 0, 1, … | how many samples were solved by the first answer, in repair round 1, … |
| Unsolved | not solved after the last repair round |
| Repaired / failed at attempt 0 | of the samples whose first answer failed, how many were solved later (and the share) |
| Mean repair round | among the repaired samples, the average attempt that solved them |

The **Total** row adds up all languages.

## 5. Idiomaticity (LLM-as-judge)

A second model (the judge, `JUDGE_MODEL`) reads the code of each sample's final attempt and scores how
well it is written for its language and paradigm. The judge gets the task specification, the contract
and the rubric for the language; it **does not get the test results or the name of the model** that wrote
the code. Code that did not compile is not judged.

The scores use the scale defined in [`harness/rubrics.md`](../harness/rubrics.md): the lowest score
means the code fights the language, the highest means an experienced practitioner would write it this
way. **Higher is better.**

| Column | What the judge assesses |
|---|---|
| n | how many solutions were judged in this row |
| **Paradigm idioms** | whether the solution is expressed in the paradigm's way of thinking: the decomposition, data flow and control structures the paradigm favours. For example pure functions, pattern matching and no mutable state in Haskell; relations and backtracking instead of imperative steps in Prolog; behaviour on objects in Smalltalk |
| **Language idioms** | whether it uses this particular language's features, standard library and conventions: naming, how absence and errors are represented, collections, formatting |
| **Readability** | how easily a competent reader of the language follows the code: names, function size, structure, useful comments |
| **Design** | how the code is structured: decomposition into functions, types, classes or predicates, choice of data structures, separation of concerns, no duplication. Not about correctness |
| Mean | the average of the four scores |

The first rows are languages, the last rows paradigms (all judged solutions of the paradigm's languages).
"Paradigm idioms" and "language idioms" differ on purpose: Scala code can be idiomatic Scala while
being written imperatively rather than functionally.

Below the table:

- **Not judged** lists solutions without a score: either the final code did not compile, or the judge
  call failed and can be repeated with `python harness/judge.py`.
- **Anti-patterns** are short notes written by the judge, up to three per language. They are free text,
  so the same problem is rarely worded identically twice. The full justification of each score is in
  `judge/<Language>-test-N-sK-aJ.json`.

`judge_calibration.jsonl` (from `judge.py --calibrate`) holds several judgements of the same code
(`item`, `repeat`). If the scores of one item differ by more than a point, take the judge's numbers with
caution.

## 6. Tokens and cost

| Column | Meaning |
|---|---|
| API calls | number of attempts, each one call to the model |
| Input tokens | tokens sent to the model. They grow with every repair round, because each round resends the whole conversation |
| Output tokens (incl. thinking) | tokens the model produced, including its hidden reasoning, which is billed but not shown |
| Generation cost | cost of these tokens at the prices in `config.PRICES` |
| **Format violations** | answers in which the model wrapped the code in a Markdown code block (```` ``` ````) although the prompt says to return raw code only |

A format violation does not fail the task: the harness extracts the code from the block anyway. The
column measures how well the model follows formatting instructions, which matters when generated code is
saved straight to a file.

The line below the table gives the judge's cost.

## 7. Tests that pass on the stub

Some tests expect exactly what the stub returns (for example `NULL` or `false` for invalid input), so
they pass even though nothing is implemented. They inflate the pass counts in the sections above.

| Column | Meaning |
|---|---|
| Passing on the stub | IDs of the tests that pass without an implementation, from `baseline.json` |
| Final | tests passed in the final attempt |
| Final without stub-passing tests | the same, counting only the other tests |

If this section says `baseline.json` is missing, run `python harness/run.py --baseline --run-id <RUN_ID>`
(free) and rebuild the report with `python harness/report.py`.

## `summary.csv` columns

| Column | Meaning |
|---|---|
| `lang`, `paradigm`, `test`, `sample` | which sample |
| `n_tests` | number of tests of the task |
| `first_category`, `first_n_pass` | outcome and passed tests of attempt 0 |
| `final_category`, `final_n_pass` | outcome and passed tests of the final attempt |
| `solved`, `solved_at_attempt`, `attempts_used` | whether and when it was solved, how many attempts it took |
| `stub_pass`, `final_n_pass_excl_stub` | tests passing on the stub; final passed tests without them |
| `input_tokens`, `output_tokens`, `cost_usd` | totals over the sample's attempts |
| `format_violations` | attempts with Markdown-wrapped code |
| `paradigm_idiomaticity`, `language_idiomaticity`, `readability`, `design`, `judge_mean` | the judge's scores of the final attempt (empty when not judged) |

## Interpreting with care

- **Few samples:** with one sample per task the results are a snapshot. Run more samples before drawing
  conclusions about small differences.
- **Stub-passing tests:** compare languages on solved tasks or on section 7, not only on raw pass counts.
- **The judge's bias:** the judge comes from the same model family as the author; its scores are a
  consistent measure of style, not ground truth. Read a few justifications in `judge/`.
- **Final is not best:** section 1 shows the last attempt; a later repair can be worse than an earlier
  one.
