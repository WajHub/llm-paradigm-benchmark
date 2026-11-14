# Harness overview

The harness is a Python program that runs the benchmark. It gives programming tasks to a Claude model through the API, tests the generated code in Docker, and sends failures back for repair. A second model then scores how idiomatic the code is, and the harness writes a report.

The benchmark has 7 languages grouped by paradigm: C and Pascal (imperative), Java and Smalltalk (object-oriented), Haskell and Scala (functional), and Prolog (logic). Each language has `test-N/` task folders.

## Modules

| File | Role |
|---|---|
| [config.py](config.py) | All settings: `RUN_ID`, model, effort, `MAX_REPAIRS`, workers, timeout, judge settings, prices. CLI flags override them for one run. |
| [run.py](run.py) | Entry point. It has three modes (dry-run, baseline, model run) and owns the generate → evaluate → repair loop. |
| [tasks.py](tasks.py) | Finds `test-*` folders and builds `Task` objects. It also holds the language, paradigm and file-extension tables and the reference solutions. |
| [prompts.py](prompts.py) | Renders the initial and follow-up prompts. |
| [llm.py](llm.py) | API key loading, the Anthropic client, the generation call, code extraction, and the cost estimate and confirmation. |
| [evaluator.py](evaluator.py) | Builds Docker images, prepares work copies, runs tests, parses output and classifies the result. |
| [judge.py](judge.py) and [rubrics.md](rubrics.md) | LLM-as-judge for idiomaticity. |
| [report.py](report.py) | Aggregates a run into `report.md`, `summary.csv` and `attempts.jsonl`. |
| [store.py](store.py) | Paths for `results/` and `.work/`, JSON helpers, git state. |

## How one task flows

```
tasks.load_task ─► prompts.render_initial ─► llm.generate ─► evaluator.prepare_workdir
                                                                     │
      prompts.render_followup ◄── evaluator.log_excerpt ◄── evaluator.run_tests / parse_output
              │                                                      │
              └──► llm.generate (same conversation) ...      attempt-K/*.json, final.json
```

1. **Discovery** (`tasks.load_task`).
   - Each language has its own rule for which file is the contract (shown to the model) and which is the target (the file the model writes). For C the contract is `*.h` and the target is `*.c`. For Java and Smalltalk the contract is `Foo.java` and the target is `FooImpl.java`. For Haskell, Scala, Prolog and Pascal one stub module is both.
   - Test IDs such as `A01` and `B05` are read from the `Test A01 (Title)` strings in the test runner file. The letter is the algorithm, so each task has two algorithms. Nothing about the benchmark's size is hardcoded.
2. **Prompt** (`prompts.render_initial`). The templates live in each `<Language>/README.md`, under the headings "Initial prompt" and "Follow-up prompt". The harness fills in the task requirements (the `## Prompt` block of `test-N.md`) and the contract. It raises an error if any placeholder is left unfilled.
3. **Generation** (`llm.generate`).
   - It streams from `client.messages.stream` with adaptive thinking and an effort level.
   - `extract_code` strips Markdown fences if the model used them, even though the prompt asks for raw code. That is recorded as a `format_violation` and does not fail the task.
4. **Evaluation** (`evaluator`).
   - `prepare_workdir` copies the language's `Makefile` and `run-tests.sh` and a clean copy of `test-N` into `.work/`. Line endings are normalised to LF and build artefacts are dropped. The model's code overwrites the target file.
   - `run_tests` runs `run-tests.sh` in a throwaway container with a timeout. On timeout it kills the container.
   - `parse_output` reads lines like `[PASS] Test A01 ...` and `[FAIL] ...`. A test missing from the output counts as failed.
5. **Outcome category.** The category is decided by markers in the output:
   - `timeout`: the run hit the time limit.
   - `compile_error`: there is no `=== START ===` marker.
   - `runtime_crash`: there is no `=== BENCHMARK RESULTS ===` marker.
   - `pass`: all tests passed and the exit code is 0.
   - `memory_error`: all tests passed but the exit code is non-zero, which means valgrind found problems.
   - `test_failures`: some tests failed.
   - Three further categories mean no code was evaluated: `refusal`, `empty_output` and `truncated`.
6. **Repair loop** (`run.run_sample`).
   - Up to `MAX_REPAIRS` (3) follow-up rounds. `log_excerpt` builds a trimmed log for the prompt, tailored per category, with a 6000-character limit. The follow-up prompt also lists the failing test names.
   - The conversation is append-only. The full `response.content`, thinking blocks included, is sent back unchanged.
   - It stops on `pass` or `refusal`.
   - Each attempt writes `prompt.md`, `response.json`, `solution.<ext>`, `eval.log`, `eval.json` and `attempt.json`. The sample then writes `final.json`.
7. **Judging** (`judge.py`).
   - The judge is `claude-sonnet-5-5`, run blind: it sees no test results and no model name. It gets the general rubric plus the section for that language, the task spec, the contract and the code.
   - It must return JSON matching a schema: four scores from 1 to 5 (paradigm idiomaticity, language idiomaticity, readability, design), a list of `anti_patterns` and a `justification`.
   - Only code that compiled is judged. `JUDGE_WHICH` picks the first attempt, the final attempt, or both.
   - `--calibrate` judges the reference solutions and some run solutions several times to check the judge is stable.
8. **Report** (`report.py`). It has seven sections:
   1. A language × test matrix.
   2. Paradigm comparison, split by algorithm A and B.
   3. Outcome categories.
   4. Self-repair statistics.
   5. Idiomaticity scores and the anti-patterns the judge named.
   6. Tokens and cost, with cache pricing.
   7. Tests that pass on the stub, which inflate scores.

## Result layout

```
results/<RUN_ID>/
  config.json            settings + git commit of the run
  baseline.json          stub/reference check (--baseline)
  <Language>/test-N/sample-K/
    attempt-0/ ...       prompt.md, response.json, solution.<ext>, eval.log, eval.json, attempt.json
    attempt-1/ ...       repair rounds
    final.json
  judge/                 one JSON per judged solution
  attempts.jsonl  judge.jsonl  summary.csv  report.md
```

## The three modes

```
python harness/run.py --dry-run     # prompts only, no API, no Docker
python harness/run.py --baseline    # evaluator check on stubs and references, no API
python harness/run.py               # generate -> evaluate -> repair -> judge -> report (asks first)
```

- `--dry-run` only renders prompts into `.work/dry-run/`. It uses no API and no Docker.
- `--baseline` runs the stubs and the reference solutions through the evaluator. It checks that every stub prints a result for each test and fails, and that the references pass where expected. The references are retrieved from commit `a9f0372` with `git show`. This validates the test infrastructure without spending money.
- A model run is the full pipeline. It shows an estimated cost and asks `[y/N]` first, unless you pass `--yes`.

## Design properties

- **Resumable.** A sample with `final.json` is skipped on rerun. A partial sample from an interrupted session is deleted and redone. Judge results are skipped the same way.
- **Config guard.** `_check_config` refuses to continue a run whose model, effort, `max_repairs` or `max_tokens` differ from the saved `config.json`. You need a new `RUN_ID` to change those. This stops mixed-setting results.
- **Parallel.** A `ThreadPoolExecutor` runs `WORKERS` (4) tasks at once, each in its own container.
- **Error handling.** Fatal API errors (auth, bad model ID, bad request) abort the run with exit code 2. Other errors, such as network or Docker problems, leave that sample unfinished so a rerun resumes it.
- **Lazy imports.** `llm` is imported only when needed, so dry-run and baseline work without the SDK or a key.
- **Reproducibility.** `config.json` records the git commit and whether the tree was dirty.
- **Windows support.** `docker_bin()` looks in `DOCKER_BIN`, then `PATH`, then the usual Docker Desktop install paths. `MSYS_NO_PATHCONV` keeps `/app` intact under Git Bash.

## Current configuration

`RUN_ID = "haiku-v1"`. The generator is `claude-haiku-5-5` at medium effort with 32k max tokens and up to 3 repairs. The judge is Sonnet 5.5 at high effort, judging the final attempt. 42 tasks is 7 languages × 6 tests.

## Extending

- **New task:** use the `/new-benchmark` skill, then run `--baseline --tests N`.
- **New language:** add the folder with its Docker files (`Dockerfile`, `Makefile`, `run-tests.sh`, and a `README.md` with the two prompt templates), then register it in `PARADIGMS`, `TEST_FILES` and `EXTENSIONS` in `tasks.py`, plus the judge's `FENCE_TAGS` and a `rubrics.md` section.
- **New model:** set it in `config.py` (or `--model`) with a new `RUN_ID` and add its price to `PRICES`.
- **New outcome category or metric:** `evaluator.parse_output` decides the category; `report.py` lists categories in `CATEGORIES`.
