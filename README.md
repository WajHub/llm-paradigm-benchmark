# LLM Paradigm Benchmark

Benchmark for analyzing the impact of programming paradigms on the quality, correctness, and idiomaticity
of LLM-generated code. The same tasks, with the same unit tests, exist in languages of different
paradigms. An evaluation program gives them to a Claude model, tests the generated code in Docker, lets
the model repair failures, scores idiomaticity with a second model and reports the results.

## Documentation

1. [How the benchmark works](docs/01-how-it-works.md): tasks, prompts, the evaluation pipeline,
   design decisions and limitations
2. [Running the evaluation](docs/02-running.md): requirements, setup, configuration, commands,
   troubleshooting
3. [Reading the report](docs/03-report.md): every file and table of a run's results

Code map of the evaluation program: [harness/README.md](harness/README.md). Results of past runs:
[results/](results/), one folder per run with its `report.md`.

## Languages & Paradigms

| Paradigm | Languages |
|---|---|
| Imperative / Procedural | C, Pascal |
| Object-Oriented | Java, Smalltalk |
| Functional | Haskell, Scala |
| Logic | Prolog |

## Test Cases

| Folder | Algorithm | Description | Languages |
|---|---|---|---|
| `test-1/` | Spatial Logic | Minkowski sum + dynamic collision detection | All |
| `test-2/` | Dijkstra | Shortest path in a weighted graph + path reconstruction | All |
| `test-3/` | Eertree | Palindrome tree — distinct palindromic substrings + occurrence counting | All |
| `test-4/` | 0/1 Knapsack | Dynamic programming knapsack (max value + selection) | All |
| `test-5/` | Expression Parser | Recursive descent + AST evaluation (arithmetic, variables, functions) | All |
| `test-6/` | Sudoku Solver | Board validation + candidates, MRV backtracking solver + solution counting | All |

Each test case asks for algorithms A, B, …; every algorithm has its own unit tests (`Test A01`, `Test A02`,
…), identical in all languages.

## Quick Start

Requirements: **Docker** (running) and **Python 3.10+**; an Anthropic API key for the paid steps.

```bash
pip install -r harness/requirements.txt
cp harness/.env.example harness/.env    # then put your API key in harness/.env
python harness/run.py --dry-run          # free: render the prompts into .work/dry-run/
python harness/run.py --baseline         # free: check the tests on stubs and reference solutions
python harness/run.py                    # paid: full run; shows the cost estimate and asks first
```

Settings (models, judge on/off, repair rounds, subsets of languages and tests) are in
[`harness/config.py`](harness/config.py). See [Running the evaluation](docs/02-running.md) for the
recommended order and all options.

## Repository Layout

```
<Language>/
├── Dockerfile, docker-compose.yml   ← toolchain image and a manual test runner
├── Makefile, run-tests.sh           ← build + run one test folder (under valgrind where used)
├── README.md                        ← prompt templates sent to the model
└── test-N/
    ├── test-N.md                    ← task-specific requirements (inserted into the prompt)
    ├── <interface>                  ← contract / type definitions (shown to the model)
    ├── <implementation>             ← "not implemented" stub (replaced by the model's code)
    └── <tests>                      ← unit tests (never shown to the model)
harness/                             ← the evaluation program and its settings (config.py)
results/<run-id>/                    ← results of each evaluation run
docs/                                ← documentation
.claude/skills/new-benchmark/        ← Claude Code skill that adds a task to every language
```

## Running Tests Manually

Requirements: **Docker** + **Docker Compose**. From a language folder, run any test folder:

```bash
cd <Language>
docker compose run --rm evaluator test-N
```

This tests whatever is in the stub file, so on a clean checkout the tests fail. To try a solution, put it
in place of the stub and restore the stub afterwards with `git checkout`.

## Prompts

1. **`<Language>/README.md`**: prompt templates (initial + follow-up)
2. **`<Language>/test-N/test-N.md`**: task-specific requirements (`TASK-SPECIFIC REQUIREMENTS`)

The evaluation program fills the templates automatically: the `test-N.md` block and the contract go into
the initial prompt; the test log, the failing test names and the target file name go into the follow-up
prompt. `python harness/run.py --dry-run` shows the result. Details:
[How the benchmark works → Prompts](docs/01-how-it-works.md#prompts).

## Test Output Format

```
=== START ===
[PASS] Test A01 (name)
[FAIL] Test A02 (name)
...
=== BENCHMARK RESULTS ===
```

Exit code: `0` = all tests passed, `1` = failures present.

## Adding a Benchmark

In Claude Code, run the `/new-benchmark` skill with a description of the algorithm. It designs a
language-neutral spec, waits for approval, generates the contract, stub, tests and `test-N.md` for every
language and verifies them against a temporary reference solution. Afterwards run
`python harness/run.py --baseline --tests N` to confirm the evaluation program handles the new task.
