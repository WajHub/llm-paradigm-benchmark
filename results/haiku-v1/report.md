# Run report: `haiku-v1`

Model **claude-haiku-5-5**, effort `medium`, up to 3 repair rounds, 1 sample(s) per task. Commit `072ea49`, started 2026-10-25T11:15:40+00:00.
Finished samples: **70**, solved (all tests pass, clean exit): **65**.

How to read this report: [docs/03-report.md](../../docs/03-report.md).

## 1. Results: language × test

Cell: tests passed in the first attempt → in the final attempt / tests of the task. ✔ = solved; the number in brackets is the attempt that solved it (0 = first answer, 1–3 = repair round). With several samples: means and the number of solved samples.

| Language | test-1 | test-2 | test-3 | test-4 | test-5 | test-6 | test-7 | test-8 | test-9 | test-10 | Solved |
|---|---|---|---|---|---|---|---|---|---|---|---|
| C (imperative) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 10/10 |
| Pascal (imperative) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 0 → 16/20 | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 9/10 |
| Java (object-oriented) | 19 → 20/20 ✔ (2) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 2 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 0 → 20/20 ✔ (2) | 0 → 20/20 ✔ (1) | 10/10 |
| Smalltalk (object-oriented) | 20 → 20/20 ✔ (0) | 0 → 12/20 | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 11 → 20/20 ✔ (2) | 20 → 20/20 ✔ (0) | 9/10 |
| Haskell (functional) | 16 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 0 → 19/20 | 0 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 9/10 |
| Scala (functional) | 18 → 20/20 ✔ (2) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 10/10 |
| Prolog (logic) | 10 → 11/20 | 17 → 17/20 | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 16 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 8/10 |

## 2. Paradigms

Tests passed as a share of all tests of the paradigm's samples; "solved" counts whole tasks. Algorithm columns: the tests of one algorithm (A01, A02, … for A), first attempt → final attempt.

| Paradigm | Languages | Samples | Tests passed (first) | Tests passed (final) | Solved (first) | Solved (final) | Algorithm A | Algorithm B |
|---|---|---|---|---|---|---|---|---|
| imperative | C, Pascal | 20 | 95% | 99% | 19/20 | 19/20 | 95% → 100% | 95% → 98% |
| object-oriented | Java, Smalltalk | 20 | 78% | 98% | 14/20 | 19/20 | 80% → 96% | 76% → 100% |
| functional | Haskell, Scala | 20 | 88% | 100% | 16/20 | 19/20 | 87% → 100% | 90% → 100% |
| logic | Prolog | 10 | 92% | 94% | 7/10 | 8/10 | 98% → 98% | 85% → 90% |

## 3. Outcome categories

Every attempt (repair rounds included) by outcome. pass = all tests pass and clean exit; test_failures = some tests fail; memory_error = all tests pass but the run exits with an error (valgrind found leaks or invalid memory access); compile_error = the code did not build, no test ran; runtime_crash = the test program died before the summary; timeout = over the time limit; truncated / refusal / empty_output = the answer contained no usable code.

| Language | pass | test_failures | memory_error | compile_error | runtime_crash | timeout | truncated | refusal | empty_output |
|---|---|---|---|---|---|---|---|---|---|
| C | 10 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Pascal | 9 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Java | 10 | 2 | 0 | 4 | 0 | 0 | 0 | 0 | 0 |
| Smalltalk | 9 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 |
| Haskell | 9 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 |
| Scala | 10 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Prolog | 8 | 9 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

## 4. Self-repair

Attempt 0 is the first answer; in each repair round the model gets the test log and the names of the failing tests. "Repaired" = tasks failed in attempt 0 and solved later.

| Language | Samples | Solved at attempt 0 | Solved at attempt 1 | Solved at attempt 2 | Solved at attempt 3 | Unsolved | Repaired / failed at attempt 0 | Mean repair round |
|---|---|---|---|---|---|---|---|---|
| C | 10 | 10 | 0 | 0 | 0 | 0 | 0/0 (–) | – |
| Pascal | 10 | 9 | 0 | 0 | 0 | 1 | 0/1 (0%) | – |
| Java | 10 | 6 | 2 | 2 | 0 | 0 | 4/4 (100%) | 1.5 |
| Smalltalk | 10 | 8 | 0 | 1 | 0 | 1 | 1/2 (50%) | 2.0 |
| Haskell | 10 | 7 | 2 | 0 | 0 | 1 | 2/3 (67%) | 1.0 |
| Scala | 10 | 9 | 0 | 1 | 0 | 0 | 1/1 (100%) | 2.0 |
| Prolog | 10 | 7 | 1 | 0 | 0 | 2 | 1/3 (33%) | 1.0 |
| Total | 70 | 56 | 5 | 4 | 0 | 5 | 9/14 (64%) | 1.4 |

## 5. Idiomaticity (LLM-as-judge)

Judge `claude-sonnet-5-5` scores the code of the final attempt blind (no test results, no model name), 1 = poor, 5 = excellent. n = judged solutions. Paradigm idioms: written in the style of the paradigm (e.g. pure functions in Haskell, relations in Prolog, objects in Smalltalk). Language idioms: this language's conventions and standard library. Readability: naming, structure, clarity. Design: decomposition, data structures, error and memory handling. Rubric: [harness/rubrics.md](../../harness/rubrics.md).

| Language / paradigm | n | Paradigm idioms | Language idioms | Readability | Design | Mean |
|---|---|---|---|---|---|---|
| C | 10 | 4.10 | 3.50 | 3.60 | 3.40 | 3.65 |
| Pascal | 10 | 4.00 | 3.40 | 3.50 | 3.50 | 3.60 |
| Java | 10 | 3.50 | 3.80 | 3.70 | 3.60 | 3.65 |
| Smalltalk | 10 | 3.00 | 3.30 | 3.50 | 3.20 | 3.25 |
| Haskell | 10 | 4.20 | 3.70 | 3.70 | 3.70 | 3.83 |
| Scala | 10 | 4.30 | 4.00 | 3.90 | 3.70 | 3.98 |
| Prolog | 10 | 3.40 | 3.40 | 3.50 | 3.30 | 3.40 |
| imperative | 20 | 4.05 | 3.45 | 3.55 | 3.45 | 3.62 |
| object-oriented | 20 | 3.25 | 3.55 | 3.60 | 3.40 | 3.45 |
| functional | 20 | 4.25 | 3.85 | 3.80 | 3.70 | 3.90 |
| logic | 10 | 3.40 | 3.40 | 3.50 | 3.30 | 3.40 |

Anti-patterns named by the judge (up to 3 per language):

- **C**: reimplementing fabs (geo_abs) instead of using math.h; long function mixing point generation, dedupe, hull building and result copy; manual loop copy instead of memcpy for hull to result vertices
- **Pascal**: hand-rolled quicksort instead of an RTL or generic sort; redundant manual clearing of managed fields before Dispose; create_polygon allocates a vertex array that is immediately replaced in calculate_clean_minkowski_sum
- **Java**: static utility helpers instead of domain objects (no hull/segment types); duplicate geometry primitives (cross and orient are identical); C-style raw Point[] buffer with manual index juggling in convexHull
- **Smalltalk**: duplicated lower/upper hull chain construction; geometry helpers on the service class rather than in domain objects (Point/Polygon/Segment); manual nil check with isNil ifTrue:ifFalse: instead of ifNil:
- **Haskell**: partial `head` in `map head . groupBy`; `length xs < 3` instead of pattern matching; lazy `foldl` instead of `foldl'`
- **Scala**: edge construction via index/modulo arithmetic instead of zip with rotated vector; inconsistent epsilon use (hull uses exact `<= 0`, others use Eps); mutable var/while loop for binary search instead of tail recursion
- **Prolog**: cut after guard in push_pt/3 to emulate if-else; append(A0,[_],A) idiom to drop the last element instead of a helper; lenient argument-order guessing in create_polygon/3 using a cut

## 6. Tokens and cost

Format violations: answers in which the model wrapped the code in a Markdown ``` block although the prompt asks for raw code only. The harness still extracts the code, so this does not fail the task; it measures instruction following.

| Language | API calls | Input tokens | Output tokens (incl. thinking) | Generation cost | Format violations |
|---|---|---|---|---|---|
| C | 10 | 16,117 | 60,143 | $0.032 | 5 |
| Pascal | 13 | 88,468 | 121,164 | $0.069 | 0 |
| Java | 16 | 70,964 | 60,654 | $0.037 | 9 |
| Smalltalk | 15 | 84,936 | 107,489 | $0.062 | 6 |
| Haskell | 15 | 65,767 | 71,433 | $0.042 | 1 |
| Scala | 12 | 31,275 | 53,509 | $0.030 | 6 |
| Prolog | 17 | 143,704 | 160,877 | $0.095 | 10 |
| Total | 98 | 501,231 | 635,269 | $0.368 | 37 |

Judge cost (70 judgements): $1.532

## 7. Tests that pass on the stub

These tests pass without any implementation (the expected answer equals the stub's return value, e.g. `NULL`/`false`), so they inflate pass counts. The last column counts only the remaining tests.

| Task | Sample | Passing on the stub | Final | Final without stub-passing tests |
|---|---|---|---|---|
| C/test-1 | 1 | A08, B02, B04, B05, B09, B10 | 20/20 | 14/14 |
| C/test-10 | 1 | A01, B01 | 20/20 | 18/18 |
| C/test-2 | 1 | A07, B08 | 20/20 | 18/18 |
| C/test-3 | 1 | A06 | 20/20 | 19/19 |
| C/test-5 | 1 | A06, A07, A08, A09, A10 | 20/20 | 15/15 |
| C/test-9 | 1 | A02 | 20/20 | 19/19 |
