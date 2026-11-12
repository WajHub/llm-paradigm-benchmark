# Run report: `haiku-v1`

Model **claude-haiku-5-5**, effort `medium`, up to 3 repair rounds, 1 sample(s) per task. Commit `072ea49`, started 2026-10-25T11:15:40+00:00.
Finished samples: **42**, solved (all tests pass, clean exit): **37**.

How to read this report: [docs/03-report.md](../../docs/03-report.md).

## 1. Results: language × test

Cell: tests passed in the first attempt → in the final attempt / tests of the task. ✔ = solved; the number in brackets is the attempt that solved it (0 = first answer, 1–3 = repair round). With several samples: means and the number of solved samples.

| Language | test-1 | test-2 | test-3 | test-4 | test-5 | test-6 | Solved |
|---|---|---|---|---|---|---|---|
| C (imperative) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 6/6 |
| Pascal (imperative) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 0 → 16/20 | 20 → 20/20 ✔ (0) | 5/6 |
| Java (object-oriented) | 19 → 20/20 ✔ (2) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 6/6 |
| Smalltalk (object-oriented) | 20 → 20/20 ✔ (0) | 0 → 12/20 | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 5/6 |
| Haskell (functional) | 16 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 0 → 19/20 | 0 → 20/20 ✔ (1) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 5/6 |
| Scala (functional) | 18 → 20/20 ✔ (2) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 6/6 |
| Prolog (logic) | 10 → 11/20 | 17 → 17/20 | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 20 → 20/20 ✔ (0) | 4/6 |

## 2. Paradigms

Tests passed as a share of all tests of the paradigm's samples; "solved" counts whole tasks. Algorithm columns: the tests of one algorithm (A01, A02, … for A), first attempt → final attempt.

| Paradigm | Languages | Samples | Tests passed (first) | Tests passed (final) | Solved (first) | Solved (final) | Algorithm A | Algorithm B |
|---|---|---|---|---|---|---|---|---|
| imperative | C, Pascal | 12 | 92% | 98% | 11/12 | 11/12 | 92% → 99% | 92% → 98% |
| object-oriented | Java, Smalltalk | 12 | 91% | 97% | 10/12 | 11/12 | 91% → 93% | 92% → 100% |
| functional | Haskell, Scala | 12 | 81% | 100% | 8/12 | 11/12 | 78% → 100% | 83% → 99% |
| logic | Prolog | 6 | 89% | 90% | 4/6 | 4/6 | 97% → 97% | 82% → 83% |

## 3. Outcome categories

Every attempt (repair rounds included) by outcome. pass = all tests pass and clean exit; test_failures = some tests fail; memory_error = all tests pass but the run exits with an error (valgrind found leaks or invalid memory access); compile_error = the code did not build, no test ran; runtime_crash = the test program died before the summary; timeout = over the time limit; truncated / refusal / empty_output = the answer contained no usable code.

| Language | pass | test_failures | memory_error | compile_error | runtime_crash | timeout | truncated | refusal | empty_output |
|---|---|---|---|---|---|---|---|---|---|
| C | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Pascal | 5 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Java | 6 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Smalltalk | 5 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Haskell | 5 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 |
| Scala | 6 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Prolog | 4 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

## 4. Self-repair

Attempt 0 is the first answer; in each repair round the model gets the test log and the names of the failing tests. "Repaired" = tasks failed in attempt 0 and solved later.

| Language | Samples | Solved at attempt 0 | Solved at attempt 1 | Solved at attempt 2 | Solved at attempt 3 | Unsolved | Repaired / failed at attempt 0 | Mean repair round |
|---|---|---|---|---|---|---|---|---|
| C | 6 | 6 | 0 | 0 | 0 | 0 | 0/0 (–) | – |
| Pascal | 6 | 5 | 0 | 0 | 0 | 1 | 0/1 (0%) | – |
| Java | 6 | 5 | 0 | 1 | 0 | 0 | 1/1 (100%) | 2.0 |
| Smalltalk | 6 | 5 | 0 | 0 | 0 | 1 | 0/1 (0%) | – |
| Haskell | 6 | 3 | 2 | 0 | 0 | 1 | 2/3 (67%) | 1.0 |
| Scala | 6 | 5 | 0 | 1 | 0 | 0 | 1/1 (100%) | 2.0 |
| Prolog | 6 | 4 | 0 | 0 | 0 | 2 | 0/2 (0%) | – |
| Total | 42 | 33 | 2 | 2 | 0 | 5 | 4/9 (44%) | 1.5 |

## 5. Idiomaticity (LLM-as-judge)

Judge `claude-sonnet-5-5` scores the code of the final attempt blind (no test results, no model name), 1 = poor, 5 = excellent. n = judged solutions. Paradigm idioms: written in the style of the paradigm (e.g. pure functions in Haskell, relations in Prolog, objects in Smalltalk). Language idioms: this language's conventions and standard library. Readability: naming, structure, clarity. Design: decomposition, data structures, error and memory handling. Rubric: [harness/rubrics.md](../../harness/rubrics.md).

| Language / paradigm | n | Paradigm idioms | Language idioms | Readability | Design | Mean |
|---|---|---|---|---|---|---|
| C | 5 | 4.00 | 4.00 | 3.80 | 3.40 | 3.80 |
| Pascal | 6 | 4.00 | 3.67 | 4.00 | 3.50 | 3.79 |
| Java | 6 | 3.67 | 4.00 | 4.17 | 3.83 | 3.92 |
| Smalltalk | 6 | 3.33 | 3.33 | 3.67 | 3.50 | 3.46 |
| Haskell | 6 | 4.17 | 3.67 | 3.83 | 3.67 | 3.83 |
| Scala | 6 | 4.50 | 4.00 | 4.00 | 4.00 | 4.12 |
| Prolog | 6 | 3.33 | 3.33 | 3.67 | 3.33 | 3.42 |
| imperative | 11 | 4.00 | 3.82 | 3.91 | 3.45 | 3.80 |
| object-oriented | 12 | 3.50 | 3.67 | 3.92 | 3.67 | 3.69 |
| functional | 12 | 4.33 | 3.83 | 3.92 | 3.83 | 3.98 |
| logic | 6 | 3.33 | 3.33 | 3.67 | 3.33 | 3.42 |

Not judged yet (judge call failed or was skipped): C/test-3. Rerun `python harness/judge.py --run-id haiku-v1`, then `python harness/report.py`.

Anti-patterns named by the judge (up to 3 per language):

- **C**: Minkowski sum via O(n·m) all-pairs point cloud plus hull instead of an edge-merge, which is more than the task needs; Temporary Polygon allocated just to negate the robot, adding heap allocation where a plain array would do; Duplicate-removal pass compares x and y independently with epsilon, mixing in an extra tolerance check on top of an already sorted array
- **Pascal**: hand-written quicksort instead of a library sort routine; redundant manual clearing of managed fields (Vertices := nil, ZoneName := '') before Dispose; O(n*m) cartesian point cloud plus hull instead of merging edges for convex Minkowski sum
- **Java**: all geometry logic in private static helpers rather than domain objects; Minkowski sum computed by O(n*m) pairwise sums plus hull instead of edge merging; duplicate cross and orient methods with identical bodies
- **Smalltalk**: index-based to:do: loops with early returns in pointInside:convex: and segmentFrom:to:intersectsConvex: where a collection iteration (allSatisfy / anySatisfy / detect:ifNone:) would do; geometry helpers placed on SpatialLogicImpl instead of in a Polygon/Point-like domain object, so the objects stay passive data holders; repeated nil-to-empty-string copying logic in createPolygon/createLayer instead of a shared helper
- **Haskell**: partial function `head` used in `map head . groupBy` (safe here, but partial); `step` defined with a fall-through clause relying on guard fallthrough, which is subtle; `length` used for size checks instead of pattern matching
- **Scala**: Option for-comprehension mixes `=` bindings, which is slightly unusual and hurts clarity; Degenerate hulls (fewer than 3 points) are not handled explicitly in collision checks; Edge construction uses index-based access with modulo instead of zip/sliding
- **Prolog**: create_polygon accepts both argument orders via an is_list/cut dispatch, which makes the predicate's mode ambiguous; cut in create_polygon and velocity_data used as if-then-else instead of ->; polygon_data uses =.. with a generic term shape and a fallback clause that can leave a choicepoint

## 6. Tokens and cost

Format violations: answers in which the model wrapped the code in a Markdown ``` block although the prompt asks for raw code only. The harness still extracts the code, so this does not fail the task; it measures instruction following.

| Language | API calls | Input tokens | Output tokens (incl. thinking) | Generation cost | Format violations |
|---|---|---|---|---|---|
| C | 6 | 6,999 | 28,160 | $0.015 | 3 |
| Pascal | 9 | 77,812 | 81,403 | $0.048 | 0 |
| Java | 8 | 25,129 | 30,261 | $0.018 | 6 |
| Smalltalk | 9 | 40,516 | 56,387 | $0.032 | 6 |
| Haskell | 11 | 57,482 | 43,031 | $0.027 | 1 |
| Scala | 8 | 23,293 | 28,710 | $0.017 | 5 |
| Prolog | 12 | 111,334 | 83,565 | $0.053 | 6 |
| Total | 63 | 342,565 | 351,517 | $0.210 | 27 |

Judge cost (41 judgements): $0.564

## 7. Tests that pass on the stub

These tests pass without any implementation (the expected answer equals the stub's return value, e.g. `NULL`/`false`), so they inflate pass counts. The last column counts only the remaining tests.

| Task | Sample | Passing on the stub | Final | Final without stub-passing tests |
|---|---|---|---|---|
| C/test-1 | 1 | A08, B02, B04, B05, B09, B10 | 20/20 | 14/14 |
| C/test-2 | 1 | A07, B08 | 20/20 | 18/18 |
| C/test-3 | 1 | A06 | 20/20 | 19/19 |
| C/test-5 | 1 | A06, A07, A08, A09, A10 | 20/20 | 15/15 |
