# 1. How the benchmark works

This repository asks one research question: **does the programming paradigm affect how well a large
language model (LLM) writes code?** The same tasks exist in several languages that represent different
paradigms. A program in [`harness/`](../harness/) gives every task to a Claude model through the API,
runs the generated code against unit tests in Docker, lets the model fix failures, scores how idiomatic
the code is and writes a report.

Next: [2. Running the evaluation](02-running.md) · [3. Reading the report](03-report.md)

## Languages, paradigms and tasks

The current languages with their paradigms and the current tasks are listed in the
[root README](../README.md#languages--paradigms). The harness knows the languages from the
`PARADIGMS` map in [`harness/tasks.py`](../harness/tasks.py), and a **task** is one
`<Language>/test-N/` folder. New task folders are picked up automatically.

Every task follows the same rules:

- The same task exists in every language, with **the same tests, inputs and expected outputs**. Only the
  representation differs (for example `NULL` in C, `Nothing` in Haskell, `none` in Prolog).
- The tests are grouped by **algorithm**: the task asks for algorithm A, B, …, and each test is named
  `Test <algorithm letter><number> (<title>)`, for example `Test A01 (Basic Squares Hull)`.
- How many tests a task has is decided by its test file. The harness reads the test names from that
  file instead of assuming a fixed number.

## What a task folder contains

| File | Role | Shown to the model? |
|---|---|---|
| `test-N.md` | task specification; the block under `## Prompt` goes into the prompt | yes |
| contract, e.g. `knapsack.h`, `Knapsack.java` | types and function signatures the solution must implement | yes |
| stub, e.g. `knapsack.c`, `KnapsackImpl.java` | "not implemented" bodies; the model's code replaces this file | see below |
| tests, e.g. `tests.c`, `Tests.java` | the unit tests | **never** |

How contract and stub map to files depends on the language:

| Language | Shown to the model | Replaced by the model's answer |
|---|---|---|
| C | `<name>.h` | `<name>.c` |
| Java | `<Name>.java` (abstract class) | `<Name>Impl.java` |
| Smalltalk | `<Name>.st` | `<Name>Impl.st` |
| Pascal, Haskell, Scala, Prolog | the module (type declarations + stub bodies) | the same module, returned in full |

In the single-file languages the model returns the whole module, type declarations included, so it can
also break the contract. That shows up as a compile error. The rules live in `load_task` in
[`harness/tasks.py`](../harness/tasks.py).

## Prompts

Each `<Language>/README.md` holds two prompt templates: the **initial prompt** and the **follow-up
(repair) prompt**. The harness takes the first code block under each heading and fills in the
placeholders:

| Placeholder | Filled with |
|---|---|
| `[TASK-SPECIFIC REQUIREMENTS]` | the `## Prompt` block of `test-N.md` |
| `[INSERT … HERE]` | the contract file |
| `[ERROR LOGS …]` | an excerpt of the test output (follow-up only) |
| `[FAILING TEST CASE …]` | the names of the failing tests (follow-up only) |
| `[TARGET FILE NAME]` | the file the model writes, e.g. `knapsack.c` |

The prompts ask for **raw code only, without Markdown fences or explanations**, because the answer is
saved straight into a source file. `python harness/run.py --dry-run` writes every rendered prompt to
`.work/dry-run/` so you can read exactly what the model receives. Editing a template changes what the
model sees, so results before and after the change belong in different runs.

## Test environments

Each language folder has a `Dockerfile` with its toolchain and a `run-tests.sh` that builds and runs one
test folder. Where a language's `run-tests.sh` runs the tests under **valgrind**, memory leaks and
invalid memory access fail the run even when every test passes. The test program prints:

```
=== START ===
[PASS] Test A01 (Title)
[FAIL] Test A02 (Title)
...
=== BENCHMARK RESULTS ===
```

and exits with `0` only when every test passes (and valgrind, if used, found nothing).

## The pipeline

```
harness/config.py + command-line flags
        │
        ▼
1. START     find the tasks, load the API key, show the cost estimate and ask [y/N],
             build the Docker images
        │
        ▼
2. GENERATE  for every task (WORKERS tasks in parallel):
             prompt ─► model ─► code ─► tests in Docker ─► solved? ── yes ─► done
                ▲                                              │ no
                └──── repair prompt: log + failing test names ◄┘   (up to MAX_REPAIRS rounds)
        │
        ▼
3. JUDGE     another model scores the idiomaticity of each final solution (optional)
        │
        ▼
4. REPORT    results/<RUN_ID>/report.md and summary.csv
```

`WORKERS`, `MAX_REPAIRS` and the other settings are in [`harness/config.py`](../harness/config.py),
described in [2. Running the evaluation](02-running.md#configuration-harnessconfigpy).

### 1. Start

[`run.py`](../harness/run.py) reads the settings, finds the task folders, checks the API key and prints
the maximum number of API calls with a cost estimate. Nothing is sent before you answer `y`. Then it
runs `docker build` for each language; with the images cached this takes seconds.

### 2. Generate, test, repair

For each task the program keeps one conversation with the model:

1. **Attempt 0.** The initial prompt goes to the model (adaptive thinking, effort from the config).
2. **Code extraction.** The answer should be plain code. If the model wrapped it in a ```` ``` ````
   block anyway, the code is still extracted and the attempt is flagged as a *format violation*.
3. **Evaluation.** The task folder is copied to `.work/`, the stub is replaced by the model's code and
   `run-tests.sh` runs in the language's container with a time limit (`TIMEOUT_S`). The output is
   parsed into passed and failed tests; a test that never printed a result counts as failed.
4. **Outcome category.** Each attempt gets one category:

   | Category | Meaning |
   |---|---|
   | `pass` | every test passes and the run exits cleanly: the task is **solved** |
   | `test_failures` | some tests fail |
   | `memory_error` | every test passes, but the run exits with an error (valgrind found a problem) |
   | `compile_error` | the code did not build or load: no test ran (`=== START ===` never printed) |
   | `runtime_crash` | the test program died before printing the summary |
   | `timeout` | the run exceeded the time limit |
   | `truncated` | the answer hit the output token limit before the code was complete |
   | `refusal` | the model declined to answer |
   | `empty_output` | the answer contained no code |

5. **Repair.** If the task is not solved and repair rounds are left, the follow-up prompt goes into the
   same conversation. It carries the part of the log that helps: the start of the compiler output for a
   build error, the `[FAIL]` lines and exception messages for failing tests, the valgrind report for a
   memory error. It also lists the names of the failing tests.

Every attempt is saved: prompt, raw response, extracted code, test log and outcome. A summary of the
whole task goes to `final.json`. A task with a `final.json` is skipped when the command runs again, so
an interrupted run resumes without paying twice.

### 3. Judge (optional)

[`judge.py`](../harness/judge.py) sends the code of each task's **final attempt** to a second model
(`JUDGE_MODEL`) with the task specification, the contract and the rubric for that language from
[`rubrics.md`](../harness/rubrics.md). The judge **does not see the test results or which model wrote
the code**. It returns scores on the rubric's scale for four criteria (paradigm idioms, language
idioms, readability, design), a list of anti-patterns and a short justification, as JSON with a fixed
schema. Code that did not compile is not judged.

### 4. Report

[`report.py`](../harness/report.py) aggregates everything into `report.md` and `summary.csv`.
[3. Reading the report](03-report.md) explains every table.

## Design decisions

These choices define what the numbers mean. Change them only on purpose and in a new run.

- **Tests stay hidden.** The model sees the specification and the contract, never the test code, so it
  cannot write code that only fits the tests. In a repair round it sees the failing test names and the
  log, like a developer reading CI output.
- **Repairs happen in one conversation.** The model sees its own earlier answers and the feedback.
  "Solved at attempt 0" measures one-shot correctness; later attempts measure self-repair.
- **Answers vary between runs.** Current Claude models don't accept a `temperature` setting, so the same
  prompt can produce different code. `SAMPLES` repeats each task to measure this; with a single sample
  the results are a snapshot.
- **The judge is blind and uses a fixed rubric.** It scores style, not correctness, and its structured
  JSON output gives every judgement the same shape.
- **Baseline before spending money.** `python harness/run.py --baseline` runs the tests on every stub
  (each must fail and print a result for every test) and on the reference solutions kept in git history
  (`REFERENCE_FILES` in [`harness/tasks.py`](../harness/tasks.py); they must pass where expected). This
  catches broken tests before any API call.

## Known limitations

- **Small samples are noisy.** With one sample per task, a single flipped task moves a language's result
  noticeably. Compare languages and paradigms with this in mind.
- **Claude judges Claude.** The judge belongs to the same model family as the author, which may bias the
  scores. `judge.py --calibrate` checks that the judge scores the same code consistently; spot checks by
  hand are still advisable.
- **Some tests pass on the stub.** When a test expects exactly what the stub returns (`NULL`, `false`),
  it passes without any implementation. The baseline records these tests and the report shows results
  with and without them.
- **Prolog runs under valgrind without leak checking**, because the interpreter's own allocations would
  fail every run.
- **The Smalltalk image depends on the Debian 11 (bullseye) archive.** When it disappears from
  `deb.debian.org`, `Smalltalk/Dockerfile` has to point at `archive.debian.org`.
