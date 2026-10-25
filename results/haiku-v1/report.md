# Raport z przebiegu `haiku-v1`

Model **claude-haiku-5-5**, effort `medium`, maks. 3 rundy naprawcze, 1 próba/y na zadanie. Commit `072ea49`, start 2026-10-25T11:15:40+00:00.
Ukończone próbki: **42**, rozwiązane (20/20, exit 0): **37**.

## 1. Wyniki: język × test

Komórka: testy zaliczone w 1. próbie → po naprawach; ✔ = rozwiązane (w nawiasie runda, w której to nastąpiło). Przy kilku próbkach: średnie i liczba rozwiązanych próbek.

| Język | test-1 | test-2 | test-3 | test-4 | test-5 | test-6 | Rozwiązane |
|---|---|---|---|---|---|---|---|
| C (imperatywny) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 6/6 |
| Pascal (imperatywny) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 0 → 16 | 20 → 20 ✔ (0) | 5/6 |
| Java (obiektowy) | 19 → 20 ✔ (2) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 6/6 |
| Smalltalk (obiektowy) | 20 → 20 ✔ (0) | 0 → 12 | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 5/6 |
| Haskell (funkcyjny) | 16 → 20 ✔ (1) | 20 → 20 ✔ (0) | 0 → 19 | 0 → 20 ✔ (1) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 5/6 |
| Scala (funkcyjny) | 18 → 20 ✔ (2) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 6/6 |
| Prolog (logiczny) | 10 → 11 | 17 → 17 | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 20 → 20 ✔ (0) | 4/6 |

## 2. Paradygmaty

| Paradygmat | Języki | Próbki | % testów (1. próba) | % testów (final) | Rozwiązane (1. próba) | Rozwiązane (final) | Algorytm A | Algorytm B |
|---|---|---|---|---|---|---|---|---|
| imperatywny | C, Pascal | 12 | 92% | 98% | 11/12 | 11/12 | 92% → 99% | 92% → 98% |
| obiektowy | Java, Smalltalk | 12 | 91% | 97% | 10/12 | 11/12 | 91% → 93% | 92% → 100% |
| funkcyjny | Haskell, Scala | 12 | 81% | 100% | 8/12 | 11/12 | 78% → 100% | 83% → 99% |
| logiczny | Prolog | 6 | 89% | 90% | 4/6 | 4/6 | 97% → 97% | 82% → 83% |

## 3. Kategorie wyników

Wszystkie próby (łącznie z rundami naprawczymi) według kategorii wyniku ewaluacji.

| Język | pass | test_failures | memory_error | compile_error | runtime_crash | timeout | truncated | refusal | empty_output |
|---|---|---|---|---|---|---|---|---|---|
| C | 6 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| Pascal | 5 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Java | 6 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Smalltalk | 5 | 3 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Haskell | 5 | 4 | 0 | 2 | 0 | 0 | 0 | 0 | 0 |
| Scala | 6 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| Prolog | 4 | 8 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

## 4. Samonaprawa

| Język | Próbki | rozw. w rundzie 0 | rozw. w rundzie 1 | rozw. w rundzie 2 | rozw. w rundzie 3 | nierozw. | naprawione / oblane w 1. próbie | śr. runda naprawy |
|---|---|---|---|---|---|---|---|---|
| C | 6 | 6 | 0 | 0 | 0 | 0 | 0/0 (–) | – |
| Pascal | 6 | 5 | 0 | 0 | 0 | 1 | 0/1 (0%) | – |
| Java | 6 | 5 | 0 | 1 | 0 | 0 | 1/1 (100%) | 2.0 |
| Smalltalk | 6 | 5 | 0 | 0 | 0 | 1 | 0/1 (0%) | – |
| Haskell | 6 | 3 | 2 | 0 | 0 | 1 | 2/3 (67%) | 1.0 |
| Scala | 6 | 5 | 0 | 1 | 0 | 0 | 1/1 (100%) | 2.0 |
| Prolog | 6 | 4 | 0 | 0 | 0 | 2 | 0/2 (0%) | – |
| Razem | 42 | 33 | 2 | 2 | 0 | 5 | 4/9 (44%) | 1.5 |

## 5. Idiomatyczność (LLM-as-judge)

Sędzia: `claude-sonnet-5-5`, ocena ślepa (bez wyników testów) kodu z ostatniej próby, skala 1–5. Kod, który się nie skompilował, nie jest oceniany.

| Język / paradygmat | n | paradygmat | język | czytelność | projekt | średnia |
|---|---|---|---|---|---|---|
| C | 5 | 4.00 | 4.00 | 3.80 | 3.40 | 3.80 |
| Pascal | 6 | 4.00 | 3.67 | 4.00 | 3.50 | 3.79 |
| Java | 6 | 3.67 | 4.00 | 4.17 | 3.83 | 3.92 |
| Smalltalk | 6 | 3.33 | 3.33 | 3.67 | 3.50 | 3.46 |
| Haskell | 6 | 4.17 | 3.67 | 3.83 | 3.67 | 3.83 |
| Scala | 6 | 4.50 | 4.00 | 4.00 | 4.00 | 4.12 |
| Prolog | 6 | 3.33 | 3.33 | 3.67 | 3.33 | 3.42 |
| imperatywny | 11 | 4.00 | 3.82 | 3.91 | 3.45 | 3.80 |
| obiektowy | 12 | 3.50 | 3.67 | 3.92 | 3.67 | 3.69 |
| funkcyjny | 12 | 4.33 | 3.83 | 3.92 | 3.83 | 3.98 |
| logiczny | 6 | 3.33 | 3.33 | 3.67 | 3.33 | 3.42 |

Najczęstsze antywzorce:

- minkowski sum via o(n·m) all-pairs point cloud plus hull instead of an edge-merge, which is more than the task needs (1×)
- temporary polygon allocated just to negate the robot, adding heap allocation where a plain array would do (1×)
- duplicate-removal pass compares x and y independently with epsilon, mixing in an extra tolerance check on top of an already sorted array (1×)
- return false on allocation failure in check_dynamic_collision conflates error with no collision (1×)
- redundant re-initialization of calloc'd adjacency fields in create_graph (1×)
- silent failure in heap_push when capacity is exceeded and in graph_add_edge on realloc failure (1×)
- mixed c89 declarations with c99 inline declarations (for int i, mid-block heapitem tmp) (1×)
- heap sized to total edges + 1 up front rather than growing dynamically (1×)
- knapsack_solve is one long function mixing allocation, dp fill and reconstruction instead of static helpers (1×)
- flattened 2d array index arithmetic repeated inline instead of a helper or macro (1×)

- **C**: minkowski sum via o(n·m) all-pairs point cloud plus hull instead of an edge-merge, which is more than the task needs (1×); temporary polygon allocated just to negate the robot, adding heap allocation where a plain array would do (1×); duplicate-removal pass compares x and y independently with epsilon, mixing in an extra tolerance check on top of an already sorted array (1×)
- **Pascal**: hand-written quicksort instead of a library sort routine (1×); redundant manual clearing of managed fields (vertices := nil, zonename := '') before dispose (1×); o(n*m) cartesian point cloud plus hull instead of merging edges for convex minkowski sum (1×)
- **Java**: all geometry logic in private static helpers rather than domain objects (1×); minkowski sum computed by o(n*m) pairwise sums plus hull instead of edge merging (1×); duplicate cross and orient methods with identical bodies (1×)
- **Smalltalk**: index-based to:do: loops with early returns in pointinside:convex: and segmentfrom:to:intersectsconvex: where a collection iteration (allsatisfy / anysatisfy / detect:ifnone:) would do (1×); geometry helpers placed on spatiallogicimpl instead of in a polygon/point-like domain object, so the objects stay passive data holders (1×); repeated nil-to-empty-string copying logic in createpolygon/createlayer instead of a shared helper (1×)
- **Haskell**: partial function `head` used in `map head . groupby` (safe here, but partial) (1×); `step` defined with a fall-through clause relying on guard fallthrough, which is subtle (1×); `length` used for size checks instead of pattern matching (1×)
- **Scala**: option for-comprehension mixes `=` bindings, which is slightly unusual and hurts clarity (1×); degenerate hulls (fewer than 3 points) are not handled explicitly in collision checks (1×); edge construction uses index-based access with modulo instead of zip/sliding (1×)
- **Prolog**: create_polygon accepts both argument orders via an is_list/cut dispatch, which makes the predicate's mode ambiguous (1×); cut in create_polygon and velocity_data used as if-then-else instead of -> (1×); polygon_data uses =.. with a generic term shape and a fallback clause that can leave a choicepoint (1×)

## 6. Tokeny i koszt

| Język | Wywołania | Tokeny wej. | Tokeny wyj. (z thinking) | Koszt generacji | Kod w bloku Markdown mimo zakazu |
|---|---|---|---|---|---|
| C | 6 | 6,999 | 28,160 | $0.015 | 3 |
| Pascal | 9 | 77,812 | 81,403 | $0.048 | 0 |
| Java | 8 | 25,129 | 30,261 | $0.018 | 6 |
| Smalltalk | 9 | 40,516 | 56,387 | $0.032 | 6 |
| Haskell | 11 | 57,482 | 43,031 | $0.027 | 1 |
| Scala | 8 | 23,293 | 28,710 | $0.017 | 5 |
| Prolog | 12 | 111,334 | 83,565 | $0.053 | 6 |
| Razem | 63 | 342,565 | 351,517 | $0.210 | 27 |

Koszt sędziego (41 ocen): $0.564

## 7. Testy zaliczane już na stubie

Te testy przechodzą bez żadnej implementacji (oczekiwana odpowiedź = wartość stuba, np. `NULL`/`false`), więc zawyżają liczbę zaliczonych testów. Ostatnia kolumna liczy tylko pozostałe testy.

| Zadanie | Próbka | Zaliczane na stubie | Final | Final bez testów ze stuba |
|---|---|---|---|---|
| C/test-1 | 1 | A08, B02, B04, B05, B09, B10 | 20/20 | 14/14 |
| C/test-2 | 1 | A07, B08 | 20/20 | 18/18 |
| C/test-3 | 1 | A06 | 20/20 | 19/19 |
| C/test-5 | 1 | A06, A07, A08, A09, A10 | 20/20 | 15/15 |
