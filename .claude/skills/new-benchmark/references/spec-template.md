# Test N — <Title>

> Language-neutral specification. Single source of truth for all language versions.
> Every expected value below was produced by `reference.py` (same folder), not computed by hand.

## 1. Task

<2–5 sentences: what the benchmark exercises and why it is interesting across paradigms
(state, recursion, data structures, memory ownership, backtracking...).>

- **Algorithm A — <short title>** (section header `--- Algorithm A: <short title> ---`):
  <what operation A computes>
- **Algorithm B — <short title>** (section header `--- Algorithm B: <short title> ---`):
  <what operation B computes; usually builds on A: reconstruction, a second query, evaluation of A's output...>

## 2. Abstract API

| Operation | Inputs | Output | Absence / error behaviour |
|---|---|---|---|
| `opA` | `xs: list<int>`, `k: int` | `int` | `0` when `xs` empty or `k <= 0` |
| `opB` | ... | `Result{...}` | ... |
| `free` (C/Pascal only) | result | – | accepts NULL/nil |

Semantics (every rule a test depends on must be listed here):
- <edge cases: empty input, zero, negative, duplicates, out-of-range ids...>
- <ordering / tie-breaking rules — if the output is a structure, define the unique expected answer,
  or the tests must only check invariants>
- <numeric rules: integer vs float, rounding, float tolerance `1e-9`>
- <complexity requirement, if any, and the trap it prevents (e.g. "no greedy")>

## 3. Per-language mapping

| | C | Pascal | Java | Smalltalk | Haskell | Scala | Prolog |
|---|---|---|---|---|---|---|---|
| contract file | `x.h` | `x.pas` | `X.java` | `X.st` | `X.hs` | `X.scala` | `x.pl` |
| stub file | `x.c` | (same unit) | `XImpl.java` | `XImpl.st` | (same) | (same) | (same) |
| opA | `int op_a(const int* xs, int n, int k)` | `function OpA(const Xs: TIntArray; K: LongInt): LongInt` | `int opA(int[] xs, int k)` | `opA: xs k: k` | `opA :: [Int] -> Int -> Int` | `def opA(xs: Vector[Int], k: Int): Int` | `op_a(+Xs, +K, -R)` |
| opB | ... | | | | | | |
| result type | `struct` + `free_x` | record ptr + `FreeX` | nested final class | class w/ accessors | record ADT | case class | `result(A, B, C)` |
| absence | `NULL` | `nil` | `null` | `nil` | `Nothing` | `None` | atom `none` |
| status/enum | `X_OK, ...` | `xsOk, ...` | `enum` | `#ok` | ADT | case objects | atoms |

## 4. Test cases

Names are identical in every language. Inputs/expected values are given abstractly (0-based indices
unless stated; Smalltalk ports must translate to 1-based where indices are visible).

### Algorithm A

| ID | Name (exact) | Input | Expected | Catches |
|---|---|---|---|---|
| A01 | `Test A01 (Empty)` | `xs=[]`, `k=10` | `0` | missing empty-input guard |
| A02 | ... | | | |
| ... | | | | |
| A10 | `Test A10 (Stress ...)` | generator below | `<value>` | wrong complexity / overflow |

### Algorithm B

| ID | Name (exact) | Input | Expected | Catches |
|---|---|---|---|---|
| B01 | ... | | | |
| ... | | | | |
| B10 | `Test B10 (Stress ...)` | generator below | invariants + `<value>` | |

### Stress generator

Deterministic, no RNG library: e.g. `w[i] = i + 1, v[i] = 2 * (i + 1)` for `i in 0..49`,
or an explicit LCG `x = (x * 1103515245 + 12345) mod 2^31` seeded with `42`.
Expected values from `reference.py`. Must run in well under 1 s (valgrind slows C/Pascal/Haskell/Prolog ~20–50×).

## 5. Notes for `test-N.md`

<Language-independent bullet points that every `test-N.md` must contain (adapted to names/types per
language): each edge-case rule from §2, memory ownership for C/Pascal, where the solution goes for
Java/Smalltalk, forbidden approaches. Do not paste the test table into the prompt.>
