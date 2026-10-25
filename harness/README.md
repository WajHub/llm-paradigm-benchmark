# Harness

The evaluation program: it gives the benchmark tasks to a Claude model through the API, tests the
generated code in Docker, sends failures back for repair, has a second model judge idiomaticity and
writes a report.

**Using it:** [docs/02-running.md](../docs/02-running.md). **What it does and why:**
[docs/01-how-it-works.md](../docs/01-how-it-works.md). **Reading the results:**
[docs/03-report.md](../docs/03-report.md). This page is for people changing the code.

```
python harness/run.py --dry-run     # prompts only, no API, no Docker
python harness/run.py --baseline    # evaluator check on stubs and references, no API
python harness/run.py               # generate -> evaluate -> repair -> judge -> report (asks first)
```

## Modules

| File | Responsibility |
|---|---|
| [`config.py`](config.py) | every setting; flags of `run.py` / `judge.py` override it for one command |
| [`run.py`](run.py) | entry point: dry-run, baseline and the model run (generation loop, repairs, resume), then judge and report |
| [`tasks.py`](tasks.py) | languages and paradigms (`PARADIGMS`), discovery of `test-*` folders, which file is the contract and which the target, test IDs read from the test file, reference solutions in git history |
| [`prompts.py`](prompts.py) | fills the templates from `<Language>/README.md` with `test-N.md`, the contract, the log and the failing tests |
| [`llm.py`](llm.py) | API key, client, one generation call (streaming, adaptive thinking), code extraction from the answer, cost estimate and confirmation |
| [`evaluator.py`](evaluator.py) | Docker: image build, work copy in `.work/`, test run with timeout, output parsing, outcome category, log excerpt for the repair prompt |
| [`judge.py`](judge.py), [`rubrics.md`](rubrics.md) | LLM-as-judge with a JSON schema; the rubric has general sections plus one per language |
| [`report.py`](report.py) | aggregates a run into `report.md`, `summary.csv`, `attempts.jsonl` |
| [`store.py`](store.py) | paths of `results/` and `.work/`, JSON helpers, git state |

## Data flow of one task

```
tasks.load_task ─► prompts.render_initial ─► llm.generate ─► evaluator.prepare_workdir
                                                                     │
      prompts.render_followup ◄── evaluator.log_excerpt ◄── evaluator.run_tests / parse_output
              │                                                      │
              └──► llm.generate (same conversation) ...      attempt-K/*.json, final.json
```

`run.run_sample` owns this loop and writes every file of `results/<RUN_ID>/<Language>/test-N/sample-K/`.

## Conventions to keep

- **Nothing about the benchmark's size is hardcoded.** Languages come from `tasks.PARADIGMS`, tasks from
  the `test-*` folders, and each task's tests from the `Test <ID> (...)` names in its test file
  (`tasks.TEST_ID`). Reports derive totals and algorithm groups (`A`, `B`, …) from the saved results.
- **Results are append-only and resumable.** A sample with `final.json` and a solution with a judge file
  are never redone. `run.py` refuses to continue a run whose generator settings differ (`_check_config`).
- **The conversation is append-only.** The full `response.content` (thinking blocks included) is sent
  back unchanged in the next round.
- **No API without consent.** Every paid path calls `llm.confirm_api_use` first; dry-run and baseline
  never import the SDK.

## Extending

- **New task:** add `test-N/` folders (the `/new-benchmark` skill in `.claude/skills/` does it for every
  language), then run `python harness/run.py --baseline --tests N`.
- **New language:** a `<Language>/` folder with `Dockerfile`, `Makefile`, `run-tests.sh` and a
  `README.md` with the two prompt templates; then add the language to `PARADIGMS`, `TEST_FILES` and
  `EXTENSIONS` in `tasks.py` (and to `load_task` if its contract/target layout is new), a fence tag in
  `judge.FENCE_TAGS` and a section in `rubrics.md`.
- **New model:** set it in `config.py` (or `--model`) with a new `RUN_ID`, and add its price to `PRICES`.
- **New outcome category or metric:** `evaluator.parse_output` decides the category; `report.py`
  lists categories in `CATEGORIES`.
