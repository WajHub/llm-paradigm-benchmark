# Per-language conventions

The canonical style models are **`<Language>/test-4/`** (Knapsack: arrays, result records, invariants)
and **`<Language>/test-5/`** (Expression: strings, enums/status codes, absence, floats).
Before writing a language, open both and copy their structure. This file lists what is not
obvious from reading them: toolchain versions, build quirks, and pitfalls that broke things before.

Naming: `<snake>` = snake_case base name (e.g. `shortest_path`), `<Pascal>` = PascalCase (`ShortestPath`).
Use the same base name for all languages of one benchmark.

Every test file must:
- print `=== START ===`, the section headers `--- Algorithm A: <title> ---` / `--- Algorithm B: <title> ---`,
  one `[PASS] <name>` / `[FAIL] <name>` line per test, then `=== BENCHMARK RESULTS ===`,
  `Completed 20 tests.`, and either `All tests passed!` or the list of failed tests;
- exit `0` when everything passed, `1` otherwise;
- treat any exception/error raised by the implementation as a FAIL of that single test and keep going;
- **never crash on stub output** (NULL/nil/none/exception) — otherwise the whole run dies with no output.

---

## C

| | |
|---|---|
| Files | `<snake>.h` (contract), `<snake>.c` (stub), `tests.c` |
| Toolchain | Debian bookworm `gcc` (`-Wall -Wextra -g`, `-lm`), `valgrind --leak-check=full --error-exitcode=1` |
| Build | every `*.c` in the folder is compiled together (Makefile wildcard) |

- Header: include guard `<SNAKE>_H`, typedefs (structs, enums), prototypes, short comments on
  ownership (`/* length n; caller frees with free_x */`). Opaque types are fine (`typedef struct AstNode AstNode;`).
- Stub: `#include "<snake>.h"`, every function silences params with `(void)p;` and returns a sentinel
  (`-1`, `NULL`, zeroed struct with error status). `free_*` stubs are `(void)p;` no-ops.
  Pick sentinels that are *not* the expected answer of most tests.
- Every heap-returning API needs a matching `free_*` that accepts NULL. Say so in `test-N.md`.
- Tests run under valgrind: **the test code itself must free everything it allocates, on every path**
  (including early `return false`). A leak in the harness fails the whole benchmark with exit 1.
- Guard every dereference: `if (!r) return false;` before `r->field`.
- Harness: `bool test_algo_a_01_<snake_title>(void)`, `RUN_TEST(func, "Test A01 (Title)")` macro,
  `const char* failed_tests[50];` — copy from `C/test-4/tests.c`.
- Only libc + `<math.h>`; no other libraries.

## Haskell

| | |
|---|---|
| Files | `<Pascal>.hs` (module = contract + stubs), `Tests.hs` (`module Main`) |
| Toolchain | Docker: Debian bookworm `ghc` (9.0.x); local may be newer. `ghc -Wall -Wextra -g -i<dir> -o test_runner <dir>/Tests.hs`, then run under valgrind |

- No cabal/stack — only libraries shipped with GHC. Stick to `base`, `containers`, `array`.
  No HUnit/QuickCheck/hspec.
- Module exports types with constructors (`Result (..)`) and functions. Data types `deriving (Eq, Show)`.
- Stub bodies: `f _ _ = error "<Pascal>.f not implemented"` (underscored args → no warnings).
- Absence → `Maybe`; error categories → an ADT (`data Status = Ok | DivByZero ...`).
- Tests are plain `Bool` values: `testAlgoA01Title :: Bool`. `check` wraps them in
  `try (evaluate passed)` — this catches `error` from stubs because evaluating the Bool forces the result.
  Make sure the Bool really depends on the result (don't compare only `length` of a lazily built list
  of errors unless that is intended).
- `tests :: [TestCase]`, `main` prints section A with `take 10`, section B with `drop 10`, then
  `Passed:` / `Failed:` counts and exits via `exitWith`. Copy from `Haskell/test-4/Tests.hs`.
- Float comparison: `abs (x - e) < 1e-9`.

## Java

| | |
|---|---|
| Files | `<Pascal>.java` (abstract class), `<Pascal>Impl.java` (stub), `Tests.java` |
| Toolchain | `eclipse-temurin:17` → Java 17. `javac -g -d <dir> <dir>/*.java`, `java -cp <dir> Tests`. Default package |

- Contract: `public abstract class <Pascal> { protected <Pascal>() {} ... }` with nested
  `public static final class Result {...}` (public final fields + constructor) and nested `enum`s;
  methods are `public abstract`.
- Stub: `public class <Pascal>Impl extends <Pascal>` — every method
  `throw new UnsupportedOperationException("<method> not implemented");`.
- `test-N.md` must say: "Keep the contract in `<Pascal>.java`; put the solution in `<Pascal>Impl.java`."
- Absence → `null` (document it); errors → enum status.
- Tests: `private static final <Pascal> X = new <Pascal>Impl();`, each test
  `private static boolean testAlgoA01Title() { try { ... } catch (Exception e) { return false; } }`,
  `runTest(name, result, failed)`, `System.exit(0/1)`. Copy from `Java/test-4/Tests.java`.
- One top-level public class per file. No external libraries (no JUnit).
- Usually no local `javac` → verify via Docker.

## Pascal

| | |
|---|---|
| Files | `<snake>.pas` (unit: `interface` = contract, `implementation` = stubs), `tests.pas` (program) |
| Toolchain | Debian bookworm `fpc` 3.2.2, `-Mobjfpc -Sh -O1 -g -Fu<dir>`; binary is placed in `<dir>/test_runner`; run under valgrind |

- Use the single-unit layout of tests 2–5. **Do not** copy `Pascal/test-1` (legacy extra `_impl.pas`).
- Every file starts with `{$mode objfpc}{$H+}`; unit name = file name; `uses Math, SysUtils;`.
- Declare array types in the unit (`TIntArray = array of LongInt;`), records, pointer types
  (`PFooResult = ^TFooResult;`), enums with prefixes (`esOk, esDivByZero`).
- Stubs: `raise Exception.Create('<Func> not implemented');` followed by a dummy `Result := ...;`
  (avoids "result not set" warnings). `Free*` procedures take `var` pointer, handle `nil`, `Dispose` and set to `nil`.
- Pascal is case-insensitive: a parameter or field named `Result`, `value`/`Value` clash, or a function
  named like an RTL routine (`Max`, `Min`, `Power`, `Exp`, `Trunc`) causes compile errors or silent
  shadowing. Tell the model in `test-N.md` when a name is reserved (e.g. "Do NOT name the parameter `Result`").
- Tests under valgrind: pattern
  `Result := False; R := nil; try R := Solve(...); if R = nil then Exit; Result := ...; except Result := False; end; FreeX(R);`
  (copy from `Pascal/test-4/tests.pas`). `Exit` inside `try..except` leaves the function and skips the
  `FreeX(R)` after `end` — only `Exit` while `R = nil`; once `R` is allocated, set `Result` and fall through.
- Helper `MakeInts(const Values: array of LongInt): TIntArray` to build dynamic arrays from literals.
- `TTestFunc = function: Boolean;` and `run_test(@test_algo_a_01_x, 'Test A01 (Title)')`; `Halt(0/1)`.

## Prolog

| | |
|---|---|
| Files | `<snake>.pl` (module = contract + stubs), `tests.pl` |
| Toolchain | Docker `swipl:9.2.9` (local may differ). Load check `swipl -q -g halt -s tests.pl`, run `swipl -q -g main -t halt tests.pl` from the test folder, under valgrind |

- Module header `:- module(<snake>, [pred/arity, ...]).`, then comments documenting modes
  (`% foo(+In, -Out)`) and **exact term shapes** of inputs/outputs (`result(MaxValue, Selected, TotalWeight)`).
- Stubs: `pred(_, _) :- throw(error(existence_error(procedure, pred/2), _)).`
- Absence: unify with the atom `none` (as in test-5) — keeps "no answer" distinguishable from
  "predicate failed". Error categories → atoms (`ok`, `div_by_zero`). State it in `test-N.md`.
- Text input: tests pass **atoms** (`'1 + 2'`); say in `test-N.md` that input is an atom (or "atom or string").
  Double-quoted literals are SWI strings, not code lists.
- `0` and `0.0` do not unify. Compare numbers with `=:=` or an `approx/2` helper, never by unification
  inside a result term when floats are involved.
- Tests: `test_algo_a_01_title :- Goal.`; lists `'Test A01 (Title)'-test_algo_a_01_title`;
  `run_test` uses `catch(call(Goal), _, fail)` inside `->` (first solution only). Copy `run_all_tests`,
  `print_failed_tests` and `main` from `Prolog/test-4/tests.pl`; `halt(0/1)`.

## Scala

| | |
|---|---|
| Files | `<Pascal>.scala` (`object` = contract + stubs), `Tests.scala` (`object Tests`) |
| Toolchain | Debian bookworm `scala` = **Scala 2.11.12**. `scalac -deprecation -feature -unchecked -d <dir>/test_runner <dir>/*.scala`; `cd <dir> && scala -cp test_runner Tests` |

- **Scala 2.11 only**: no Scala 3 syntax (`enum`, `given`, indentation-based blocks, `extension`),
  no 2.12/2.13 APIs (`LazyList`, `.to(List)`, `IterableOnce`, `scala.util.Using`, `Map.updatedWith`).
  Use `Vector`, `List`, `Map`, `Option`, `case class`, `sealed trait` + `case object`.
- Contract: `object <Pascal> { case class Result(...); sealed trait Status; case object Ok extends Status; ...
  def f(...): T = sys.error("<Pascal>.f not implemented") }`.
- Absence → `Option`; errors → sealed trait of case objects.
- Tests: `def testAlgoA01Title(): Boolean = try { ... } catch { case _: Throwable => false }`,
  `val tests: List[(String, () => Boolean)]`, `check(name)(body)`, `sys.exit(0/1)`. Copy from `Scala/test-4/Tests.scala`.
- Scala's `docker-compose.yml` mounts the parent dir (`..:/workspace`) — the verify script handles it.

## Smalltalk

| | |
|---|---|
| Files | `<Pascal>.st` (domain classes + abstract base), `<Pascal>Impl.st` (stub subclass), `Tests.st` |
| Toolchain | Debian bullseye `gnu-smalltalk` (gst 3.2.x). Loads all `*.st` except `Tests.st` in **alphabetical order**, then `Tests.st`: `gst -Q <deps> Tests.st` |

- Bracket class syntax: `Object subclass: Foo [ | ivars | Foo class >> a: x b: y [ ^self new initA: x b: y ] ... ]`.
- `<Pascal>.st` must sort before `<Pascal>Impl.st` (it does, keep this naming); put *all* domain classes
  (results, nodes, variables) in `<Pascal>.st`. Abstract methods: `^self subclassResponsibility`.
- Stub: `<Pascal> subclass: <Pascal>Impl [ method: x [ self error: 'Not implemented' ] ]`.
- `test-N.md` must say: "Put the solution in `<Pascal>Impl.st`."
- **Never redefine built-in classes** (`Point`, `Rectangle`, `Interval`, `Set`, `Bag`, `Association`,
  `Character`, `Date`, `Time`, `Graph`-like generic names are risky). Prefix generic names
  (test-5 uses `ExprVariable`).
- Collections are **1-based**. Literal arrays `#(1 2 3)`, nested `#(#(1 2) #(3 4))`. Absence → `nil`;
  enums/status → symbols (`#ok`, `#divByZero`).
- `7 / 2` is the Fraction `7/2`, not 3 or 3.5. If integer division matters, specify `//` semantics in `test-N.md`.
- `and:`/`or:` take blocks: `(a = 1) and: [b = 2]`.
- Tests: `Object subclass: Tests [ | impl | Tests class >> new [ ^super new init ] init [ impl := <Pascal>Impl new ] ... ]`,
  each test method returns a Boolean, `runAll` repeats the per-test block
  `([self testAlgoA01Title] on: Error do: [:e | false]) ifTrue: [...] ifFalse: [...]` for all 20 tests,
  ends with `ObjectMemory quit: 0/1`; file ends with `Tests new runAll.` Copy from `Smalltalk/test-4/Tests.st`.
- Usually no local `gst` → verify via Docker.
