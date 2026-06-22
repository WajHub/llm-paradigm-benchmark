# LLM Paradigm Benchmark

Benchmark for analyzing the impact of programming paradigms on the quality, correctness, and idiomaticity of LLM-generated code.

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
| `test-1/` | Spatial Logic | Minkowski sum + dynamic collision detection | All 7 |
| `test-2/` | Dijkstra | Shortest path in a weighted graph + path reconstruction | All 7 |
| `palindrom-tree/` | Eertree | Palindrome tree — distinct palindromic substrings | C only |

Each test case contains **20 unit tests** (10 algorithm A + 10 algorithm B).

## Folder Structure

```
<Language>/
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── run-tests.sh
├── README.md              ← LLM prompt templates
└── test-N/
    ├── test-N.md           ← task-specific requirements (inserted into prompt)
    ├── <interface>         ← contract / type definitions
    ├── <implementation>    ← "not implemented" stub (LLM writes code here)
    └── <tests>             ← unit tests (read-only)
```

## Running Tests

Requirements: **Docker** + **Docker Compose**.

```bash
cd <Language>

# test-1 (Spatial Logic):
docker compose run --rm evaluator test-1

# test-2 (Dijkstra):
docker compose run --rm evaluator test-2
```

## Prompts

1. **`<Language>/README.md`** — prompt template (initial + follow-up)
2. **`<Language>/test-N/test-N.md`** — task-specific requirements (`TASK-SPECIFIC REQUIREMENTS`)

Insert the interface file contents and `test-N.md` body into the README template.

## Test Output Format

```
=== START ===
[PASS] Test A01 (name)
[FAIL] Test A02 (name)
...
=== BENCHMARK RESULTS ===
```

Exit code: `0` = all tests passed, `1` = failures present.
