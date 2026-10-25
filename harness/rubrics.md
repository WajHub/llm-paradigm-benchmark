# Idiomaticity rubric

Used by `judge.py`. The judge receives the general sections below plus the section of the
language being evaluated.

## Scale

- **5**: what an experienced practitioner of this language and paradigm would write; nothing to change.
- **4**: idiomatic overall, a few small departures from common practice.
- **3**: works in the language's style in places, but with clear non-idiomatic stretches.
- **2**: mostly written as if in another language or paradigm; idioms of this one are largely ignored.
- **1**: fights the language: constructs foreign to it throughout, or misuses its core features.

## Criteria

- **paradigm_idiomaticity**: how well the code expresses the solution in the language's paradigm
  (procedural, object-oriented, functional, logic): the decomposition, data flow and control structures
  that paradigm favours.
- **language_idiomaticity**: use of this particular language's features, standard library and conventions
  (naming, error/absence representation, collections, formatting).
- **readability**: how easily a competent reader of this language follows the code: names, function size,
  structure, comments where they help (not everywhere).
- **design**: decomposition into functions/types/classes/predicates, choice of data structures, separation
  of concerns, avoidance of duplication. This is about structure, not about whether the result is correct.

## Rules

- Do not judge correctness: you do not see test results, and a correct but non-idiomatic solution should
  score low, while an idiomatic solution with a bug can still score high.
- Judge only what the author wrote. Type declarations, signatures and data classes copied from the provided
  contract are given; evaluate how the author used them and what they added.
- Do not reward length or extra features beyond the task, and do not penalise a short solution for being short.
- Requirements that come from the task (fixed signatures, C-style result structs, status enums, `none` atoms,
  1-based Smalltalk collections) are not anti-patterns.
- `anti_patterns`: short concrete labels of non-idiomatic constructs actually present, e.g.
  "index-based loops instead of folds", "mutable var accumulators", "cut used to emulate if-else".
  Empty list when there are none. Do not list style nitpicks.
- `justification`: 2–4 sentences pointing at specific parts of the code.

## C

- Clear ownership: every allocation has an obvious owner and a matching `free_*`; no leaks on error paths.
- Checks `malloc`/`calloc` results and NULL arguments where the contract requires it.
- `static` helpers for internal functions, `const` on read-only pointer parameters, `size_t`/`int` used sensibly.
- Small functions with a single responsibility rather than one long function; no needless global state.
- Standard library where it fits (`qsort`, `memcpy`, `strncpy`/`snprintf`) instead of hand-rolled equivalents.

## Pascal

- Structured procedural style: procedures/functions with clear parameters (`const`/`var` used deliberately),
  records and dynamic arrays from the unit.
- Memory managed with `New`/`Dispose` or `SetLength` consistently; matching free procedures; no leaks.
- Uses Free Pascal RTL facilities (`SetLength`, `Length`, `High`, `Exit(value)`, `Math`/`SysUtils` routines)
  instead of reinventing them; helpers kept in the `implementation` section.
- Readable control flow (`for`/`while`/`repeat`, `case`), meaningful identifiers, no `goto`.

## Java

- Object-oriented decomposition: behaviour in well-named methods/classes, private helpers, encapsulated state.
- Uses the collections framework and standard APIs (`List`, `Map`, `Deque`, `PriorityQueue`, `Arrays`,
  `Collections`, streams where they read naturally) instead of manual array juggling.
- Proper use of `final`, generics, enums and immutability where sensible; no raw types.
- Absence/error handling as the contract defines (null or status enum); no swallowed exceptions.
- No static utility dumping ground replacing the object model; no C-style code transplanted into Java.

## Smalltalk

- Message passing and polymorphism; small methods with intention-revealing selectors.
- Collection protocols instead of index loops: `do:`, `collect:`, `select:`, `reject:`, `detect:ifNone:`,
  `inject:into:`, `with:collect:`; `to:do:` only where indices are really needed.
- Blocks used idiomatically (`ifTrue:ifFalse:`, `ifNil:`, `and:`/`or:` with blocks), early returns with `^`.
- Domain logic in objects rather than long procedural methods; no redefinition of built-in classes.
- GNU Smalltalk bracket syntax used cleanly; temporaries declared where used.

## Haskell

- Pure functions, total where practical; absence and errors modelled with `Maybe`/`Either`/ADTs,
  not `error` or partial functions (`head`, `fromJust`, `!!` on unchecked indices).
- Pattern matching, guards, `where`/`let`, higher-order functions and folds instead of manual recursion
  that re-implements library functions.
- Appropriate data structures (`Data.Map`, `Data.Set`, `Data.Array`) instead of association lists for
  lookups; strictness where it matters (e.g. `foldl'`).
- Small composable functions with type signatures; no imperative emulation (e.g. `IORef`/`State` where pure
  code suffices).

## Scala

- Immutable values (`val`, immutable collections) and expressions over statements; `var` and mutable
  collections only where clearly justified and local.
- `Option`/`Either`/sealed traits and case classes for absence, errors and data; pattern matching.
- Collection combinators (`map`, `flatMap`, `foldLeft`, `collect`, `groupBy`, for-comprehensions) instead of
  index loops; tail recursion (`@tailrec`) where recursion is needed.
- No Java-style null handling or `return` statements; code compatible with Scala 2.11 used naturally.

## Prolog

- Relational, declarative predicates; clause heads with pattern matching instead of explicit
  if-then-else chains; meaningful predicate names with modes respected.
- Recursion with accumulators, or library predicates (`foldl/4`, `maplist/N`, `aggregate_all/3`, `sum_list/2`,
  `nth0/3`, `assoc`/`pairs` libraries) instead of reimplementing them.
- Cuts only as green cuts or clearly justified red cuts; no `assert`/`retract` for ordinary state
  (tabling or explicit state passing instead).
- Failure vs. `none`/status atoms used as the task specifies; no exceptions for control flow.
- Arithmetic with `is`/comparison operators used correctly; no imperative simulation via global variables.
