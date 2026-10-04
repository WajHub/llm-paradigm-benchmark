---
name: new-benchmark
description: Create a new benchmark task (test-N) for every language in the LLM paradigm benchmark repo (C, Pascal, Java, Smalltalk, Haskell, Scala, Prolog) from a plain description of an algorithm or problem. Designs a language-neutral spec with 2 algorithms x 10 tests, waits for approval, then generates contract, stub, tests and test-N.md per language and verifies them against a temporary reference solution. Use when the user asks to add/create a new benchmark, test case, task or algorithm ("dodaj nowy benchmark", "nowy test", "stwórz test-6 dla ...").
argument-hint: "<description of the algorithm / task>"
---

# New benchmark

Turns a description of an algorithm/task into `test-N/` folders for **every language** in the repo,
consistent with the existing tests and verified to be correct.

Talk to the user in their language (the team writes in Polish); all repo files are in English.

Bundled resources (read when the step says so):
- `references/languages.md` — per-language files, toolchain versions, harness, pitfalls
- `references/spec-template.md` — template of the language-neutral spec
- `scripts/verify.sh` — runs one language/test in an isolated copy (local toolchain or Docker)

## Non-negotiable rules

1. **Same benchmark in every language.** Identical test names (`Test A01 (Title)`), identical inputs and
   expected outputs, same semantics. Only representation differs (NULL / nil / `Nothing` / `None` / `none`).
2. **Structure is fixed:** Algorithm A (10 tests, A01–A10) + Algorithm B (10 tests, B01–B10), output format
   and exit codes as in `README.md` → "Test Output Format".
3. **Fair prompt:** every behaviour a test checks (edge-case returns, ordering, tie-breaking, error
   representation, ownership) must be stated in `test-N.md` and/or the contract. A correct model must
   never fail because of an unstated convention.
4. **Expected values come from code**, never from mental arithmetic: a Python reference in the scratch
   workspace computes them.
5. **Reference solutions never enter the repository.** They live only in the scratch workspace and are
   deleted at the end. The repo receives only: `test-N.md`, contract, stub, tests, README update.
6. Don't modify existing tests, the per-language `README.md` prompt templates, Dockerfiles, Makefiles or
   `run-tests.sh`. If the new task truly cannot work with the current build setup, stop and ask.
7. Don't commit. Leave the changes for the user to review.

## Workflow

### Step 0 — Orient

- Repo root = the directory containing `README.md` with the "Test Cases" table.
- Languages = top-level directories containing `run-tests.sh` (currently C, Haskell, Java, Pascal, Prolog,
  Scala, Smalltalk). Use whatever is present.
- `N` = highest existing `test-K` across all languages + 1, unless the user specified N.
- Scratch workspace `$WS`: your scratchpad directory if you have one, else `/tmp/new-benchmark-test-N`.
  Layout: `$WS/spec/` (spec + `reference.py`), `$WS/ref/<Language>/` (reference impls), `$WS/verify/` (runs).
- Read `README.md`, then `C/test-4/` and `C/test-5/` (all files) to see what a finished benchmark looks like.
  If the description is ambiguous in a way that changes the API or the tests (e.g. "graph algorithm"
  without saying which), ask the user before designing — one short round of questions max.

### Step 1 — Design the spec (language-neutral)

Fill `references/spec-template.md` → `$WS/spec/spec.md`.

Choosing A and B: two related operations on the same domain, B usually harder or building on A.
Existing pairs: Minkowski sum / collision check, distances / path reconstruction, distinct palindromes /
occurrence counts, max value / item selection, parse / evaluate.

API design:
- Small surface: 1–2 functions per algorithm (+ `free_*` in C/Pascal). Prefer inputs that are easy to
  write as literals in every language (ints, floats, lists, strings, list of pairs/triples for graphs).
- Result records with named fields when more than one value is returned.
- Map the API to all 7 languages now (spec §3) using the conventions in `references/languages.md`,
  so the user approves the concrete signatures.

Designing the 20 tests — per algorithm, roughly:
- 2–3 edge cases (empty, single element, zero/boundary, invalid input),
- 3–4 normal/textbook cases,
- 2 traps that fail typical wrong approaches (greedy instead of DP, off-by-one, wrong associativity,
  missing visited-set, integer instead of float division...),
- 1 invariant/property check (validates a structure without fixing a unique answer),
- 1 stress test (deterministic generator, checked against a value from `reference.py` or a reference
  computation embedded in the test file as in test-4; must stay fast under valgrind).

If a test compares an exact structure (selection vector, path, list order), verify in `reference.py`
that the expected answer is **unique** (brute force over small inputs) or define a tie-breaking rule in the
spec; otherwise test invariants instead.

Write `$WS/spec/reference.py` (straightforward, obviously-correct implementation; brute force is fine for
small cases), run it, and copy its printed results into the spec tables.

### Step 2 — Checkpoint: get approval

Show the user a compact summary: A/B description, the API table (spec §3), and both test tables
(name, input, expected). Mention anything you decided on your own (tie-breaking, error handling).
**Stop and wait.** Apply requested changes (re-run `reference.py`), and re-confirm if the changes were big.

### Step 3 — Generate all languages

Prefer parallel subagents: launch **one Agent per language in a single message** (general-purpose type),
each with the prompt below. If the Agent tool is unavailable, do the same steps yourself, language by language.

Subagent prompt (fill the placeholders):

```
You are adding benchmark test-<N> for <Language> in the repo at <REPO>.
Spec (source of truth, do not change it): <WS>/spec/spec.md
Language conventions and pitfalls: <SKILL_DIR>/references/languages.md, section "<Language>".
Style models: read ALL files in <REPO>/<Language>/test-4/ and <REPO>/<Language>/test-5/ first,
plus <REPO>/<Language>/README.md (the prompt template your test-<N>.md will be inserted into).

Create in <REPO>/<Language>/test-<N>/:
  1. test-<N>.md   — same format as test-5/test-5.md ("# Test <N>", "## Prompt - `TASK-SPECIFIC REQUIREMENTS`",
                     one fenced block). Precise semantics from the spec using this language's names and types,
                     every edge-case rule, ownership/free rules (C/Pascal), where the solution goes
                     (Java/Smalltalk Impl file). Do not list the test inputs.
  2. contract + stub files exactly as listed for <Language> in languages.md, with the signatures of spec §3.
  3. tests file with the 20 tests of spec §4: exact names, same inputs and expected values, same section titles.
Create the reference implementation ONLY in <WS>/ref/<Language>/ — full file(s) with the same name(s) as the
stub file(s), which verify.sh copies over the stub (never put it in the repo). Write it the way a strong
<Language> programmer would; it also tells you whether the contract is implementable idiomatically.

Verify (repeat until both pass):
  sh <SKILL_DIR>/scripts/verify.sh <REPO> <Language> test-<N> <WS>/verify/ref-<Language> <WS>/ref/<Language>
    → must end with exit=0, 20 [PASS] lines, and (C/Pascal/Haskell/Prolog) valgrind "ERROR SUMMARY: 0 errors".
  sh <SKILL_DIR>/scripts/verify.sh <REPO> <Language> test-<N> <WS>/verify/stub-<Language>
    → must compile, print "=== START ===", 20 result lines and "=== BENCHMARK RESULTS ===", exit=1, no crash.
If verify reports mode=none (no toolchain, no Docker) report it as UNVERIFIED — do not claim success.

When a test fails against the reference: the spec values come from a Python reference and are trusted.
Fix your reference or a porting mistake in the test. Never weaken or drop a test, never change expected
values; if you believe the spec itself is wrong, stop and report it.

Report back: created files, ref result (pass count, exit code, mode), stub result (how many PASS on the
stub and which), any deviation from the spec and why.
```

### Step 4 — Cross-check (you, after all subagents finish)

1. Gate per language: reference run 20/20 + exit 0 (+ clean valgrind); stub run completes with exit 1.
   Re-run `verify.sh` yourself for any language whose report looks doubtful.
2. Identical test names everywhere — each line must show `20` and the same hash:
   ```sh
   for L in <languages>; do printf "%-10s " $L; grep -ohE "Test [AB][0-9]{2} \([^)]*\)" $L/test-<N>/[Tt]ests.* | sort -u > "$WS/names-$L"; printf "%s " "$(wc -l < "$WS/names-$L")"; md5sum < "$WS/names-$L"; done
   ```
3. Read the 7 `test-N.md` files side by side: same rules, nothing missing in one language.
4. Spot-check 3–4 tests per language against the spec tables (inputs and expected values), especially
   Smalltalk index translation (1-based) and Prolog int/float comparisons.
5. Tests passing on the stub: acceptable only when the expected answer equals the stub's sentinel (e.g.
   "invalid input → NULL"). If more than ~3 pass on a stub, reconsider the sentinel or the tests.

### Step 5 — Finish

- Update root `README.md`: add a row to "Test Cases" (`` `test-N/` | <Algorithm> | <one-line description> | All 7 ``)
  and a `docker compose run --rm evaluator test-N` line under "Running Tests".
- Delete `$WS/ref/` and `$WS/verify/`. Check `git status`: only new `*/test-N/` files and `README.md`
  changed, no build artefacts (`test_runner`, `*.o`, `*.ppu`, `*.hi`, `*.class`), no reference code.
- Report to the user: table language × (ref result, stub result, verification mode), any UNVERIFIED
  languages with the command to run them in Docker (`cd <Language> && docker compose run --rm evaluator test-N`),
  and deviations/decisions worth reviewing. Offer to commit.
