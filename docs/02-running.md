# 2. Running the evaluation

Everything here is run from the repository root. Commands that call the Claude API cost money and ask
for confirmation first; the others are free.

Previous: [1. How the benchmark works](01-how-it-works.md) · Next: [3. Reading the report](03-report.md)

## What you need

| Requirement | Notes |
|---|---|
| **Docker** (Docker Desktop on Windows/macOS) | must be running while the program works. The language images take several gigabytes of disk and the first build takes a while; later runs reuse the cache. Docker fails in odd ways when the disk is full. |
| **Python 3.10+** | for the harness |
| **Anthropic API key** | create one at [console.anthropic.com](https://console.anthropic.com/) → API keys. Usage is billed per token. |

No compilers are needed on your machine: every language builds and runs inside its container.

## One-time setup

1. Install the SDK:
   ```
   pip install -r harness/requirements.txt
   ```
2. Add your API key:
   ```
   cp harness/.env.example harness/.env
   ```
   Then open `harness/.env` and replace the placeholder: `ANTHROPIC_API_KEY=sk-ant-...`.
   `harness/.env` is git-ignored, so the key never reaches the repository. An `ANTHROPIC_API_KEY`
   environment variable, if set, takes precedence.
3. Start Docker. The images are built automatically the first time the program needs them.
4. Check that everything works, for free:
   ```
   python harness/run.py --dry-run     # renders all prompts into .work/dry-run/
   python harness/run.py --baseline    # runs the tests on stubs and reference solutions
   ```
   The baseline must end with `All checks OK`.

## Configuration: `harness/config.py`

All settings live in [`harness/config.py`](../harness/config.py); its comments show the current values.

| Setting | Meaning |
|---|---|
| `RUN_ID` | name of the run; results go to `results/<RUN_ID>/` |
| `LANGUAGES`, `TESTS` | `None` for everything, or a subset, e.g. `["C", "Haskell"]`, `[4, 5]` |
| `SAMPLES` | independent repetitions of each task |
| `MAX_REPAIRS` | repair rounds after a failed attempt (`0` = one attempt only) |
| `WORKERS` | tasks processed in parallel |
| `TIMEOUT_S` | time limit of one test run, in seconds |
| `ASK_BEFORE_API_CALLS` | show the cost estimate and ask before paid calls |
| `GENERATOR_MODEL`, `GENERATOR_EFFORT`, `GENERATOR_MAX_TOKENS` | the model that writes the code, how much it thinks (`low` … `max`) and its output limit per answer, thinking included |
| `JUDGE_ENABLED` | run the idiomaticity judge after generation |
| `JUDGE_MODEL`, `JUDGE_EFFORT`, `JUDGE_MAX_TOKENS` | the judge model and its settings |
| `JUDGE_WHICH` | which attempt to judge: `final`, `first` or `both` |
| `JUDGE_FALLBACK` | retry a refused judge request on Anthropic's fallback model |
| `CALIBRATION_REPEAT`, `CALIBRATION_SAMPLES` | how `judge.py --calibrate` samples solutions |
| `REPORT_ENABLED` | write `report.md` at the end |
| `PRICES` | USD per million tokens of each model, for the estimate and the report |
| `ESTIMATE_TOKENS_GENERATION`, `ESTIMATE_TOKENS_JUDGE` | tokens per call assumed by the pre-run estimate |

**Models.** The harness uses adaptive thinking and the `effort` setting, so it needs Claude models that
support both (the 5.x generation). Add the price of a new model to `PRICES`, otherwise its cost shows
as `?`.

**Flags override the config for one command:**

| `run.py` flag | Overrides |
|---|---|
| `--run-id NAME` | `RUN_ID` |
| `--langs C,Haskell`, `--tests 4,5` | `LANGUAGES`, `TESTS` |
| `--samples N`, `--max-repairs N`, `--workers N`, `--timeout S` | the settings of the same name |
| `--model ID`, `--effort LEVEL`, `--max-tokens N` | `GENERATOR_*` |
| `--no-judge`, `--no-report` | `JUDGE_ENABLED`, `REPORT_ENABLED` |
| `--yes` | skips the confirmation question |
| `--keep-work` | keeps the `.work/` copies for debugging |

`judge.py` takes `--run-id`, `--which`, `--model`, `--effort`, `--workers`, `--calibrate` and `--yes`.
`python harness/run.py --help` lists everything.

### When to start a new `RUN_ID`

- **New `RUN_ID`** when you change `GENERATOR_MODEL`, `GENERATOR_EFFORT`, `GENERATOR_MAX_TOKENS` or
  `MAX_REPAIRS`. An existing run refuses to continue with different values, so results never mix.
- **New `RUN_ID`** after editing prompts, tests or the harness in a way that changes results.
- **Same `RUN_ID`** when you add languages, tasks, samples or the judge: finished work is skipped.
- **Don't change `JUDGE_MODEL`** in a run that already has judgements. Delete `results/<RUN_ID>/judge/`
  first, otherwise scores of two judges get mixed.
- A new run directory has no baseline. Run `python harness/run.py --baseline --run-id NAME` (free) so
  the report can flag the tests that pass on the stub.

## Commands

| Command | Calls the API? | What it does |
|---|---|---|
| `python harness/run.py --dry-run` | no | writes all prompts to `.work/dry-run/` |
| `python harness/run.py --baseline` | no | checks the evaluator on stubs and reference solutions |
| `python harness/run.py --no-judge --langs C,Java,Haskell,Prolog --tests 4` | yes | pilot, e.g. one language per paradigm and one task |
| `python harness/run.py --no-judge` | yes | every task, without the judge |
| `python harness/judge.py --calibrate` | yes | judges a few solutions several times to check the judge is consistent |
| `python harness/run.py` | yes | generation (finished tasks skipped) + judge + report |
| `python harness/judge.py` | yes | judge only, for an existing run |
| `python harness/report.py` | no | rebuilds `report.md` and `summary.csv` from saved results |

Before the first paid call the program prints what it is about to spend and waits. For example:

```
Run haiku-v1: 42 samples (4 already done), model claude-haiku-5-5, effort medium, max 3 repairs.
  generation: up to 152 API calls, estimated ~$0.91
  judge: disabled
  (pessimistic estimate; actual tokens and cost end up in the report)
Continue and make these API calls? [y/N]
```

The estimate assumes the worst case: every task uses every repair round and every call uses the tokens
set in `ESTIMATE_TOKENS_*`. The real tokens and cost of a run are in section 6 of its report.

## Recommended order for a new run

```
python harness/run.py --dry-run
python harness/run.py --baseline
python harness/run.py --no-judge --langs C,Java,Haskell,Prolog --tests 4
python harness/run.py --no-judge
python harness/judge.py --calibrate
python harness/run.py
```

1. **Dry-run and baseline** (free) confirm that prompts and tests are in order.
2. **Pilot.** A few tasks first. Open `results/<RUN_ID>/C/test-4/sample-1/` and check that
   `attempt-0/solution.c` is clean code, `attempt-0/eval.log` contains test results and, if there was a
   repair, `attempt-1/prompt.md` contains a sensible log and the failing test names.
3. **The rest.** The pilot tasks are skipped, the remaining ones run.
4. **Calibration** (optional). It judges a few reference and generated solutions repeatedly and saves
   the scores to `judge_calibration.jsonl`. If the scores of the same code differ by more than one point,
   the judge is not reliable enough.
5. **Judge.** `run.py` with the judge enabled makes no generation calls (every task is finished), scores
   the final solutions and rebuilds the report.

## Interrupting, resuming and redoing

- **Interrupted run** (Ctrl+C, network error, Docker restart): run the same command again. Tasks with a
  `final.json` and solutions with a judgement are skipped.
- **Redo one task:** delete `results/<RUN_ID>/<Language>/test-N/` and run the command again.
- **Redo the judge:** delete `results/<RUN_ID>/judge/` and run `python harness/judge.py`.
- **Missing judgement** (the report names it in section 5): run `python harness/judge.py`, then
  `python harness/report.py`.

## Running one test by hand (no API)

Each language folder can run a test folder directly with Docker Compose:

```
cd C
docker compose run --rm evaluator test-4
```

This tests whatever is currently in the stub file, so on a clean checkout the tests fail. To check a
solution by hand, put it in place of the stub (e.g. copy
`results/<RUN_ID>/C/test-4/sample-1/attempt-0/solution.c` to `C/test-4/knapsack.c`), run the command,
then restore the stub with `git checkout C/test-4/knapsack.c`.

## Troubleshooting

| Symptom | What to do |
|---|---|
| `ANTHROPIC_API_KEY is not set` | put your key in `harness/.env` |
| `Aborted: no API calls were made.` | you answered anything other than `y`; nothing was spent |
| `docker not found` | start Docker Desktop; if it is installed in an unusual place, set `DOCKER_BIN` to the path of `docker` |
| `docker build failed` | check that Docker runs and that there is free disk space; a full disk can corrupt images: remove the broken image (`docker image rm llmbench-<language>`) and run again |
| `FATAL API error` | wrong key, unknown model name or no credit; the run stops before making more calls |
| `existing run used model=...` | you changed generator settings; restore them or use a new `RUN_ID` |
| `ERROR ... (rerun the same command to resume)` | a temporary problem with one task; run the same command again |
| `PROBLEMS:` at the end of `--baseline` | a stub passes, a test runner prints too few results or a reference fails: fix the task before spending money |
| Smalltalk build fails with `404` from apt | Debian 11 moved to the archive; point `Smalltalk/Dockerfile` at `archive.debian.org` |
