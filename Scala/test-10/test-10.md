# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order-statistics algorithms in Scala 2.11 in the object OrderStats
(file OrderStats.scala): deterministic median-of-medians selection (BFPRT) that
also reports the pivots it used, and the median of two sorted sequences that
can only be read through a counting probe. The object already defines
SelectResult(value: Int, pivots: Vector[Int]) and the trait SortedSource;
implement medianOfMedians, selectKth and medianTwoSorted.

Part A - Median of medians (Ints, duplicates allowed):
  * Lower median of a non-empty group g: the element at 0-based index
    (g.length - 1) / 2 of g sorted ascending.

- Implement `medianOfMedians(xs: Vector[Int]): Option[Int]`:
  * None if xs is empty.
  * Otherwise split xs IN ITS CURRENT ORDER into consecutive groups of 5
    (xs(0..4), xs(5..9), ...; the last group may have 1-4 elements), take the
    lower median of every group, and return Some(lower median of the list of
    group medians). How that final median is computed does not matter, only
    its value.

- Implement `selectKth(xs: Vector[Int], k: Int): Option[SelectResult]`:
  * k is 0-based (k = 0 is the minimum). None if k < 0 or k >= xs.length.
  * Otherwise the result is defined by EXACTLY this procedure, starting with
    cur = xs, pivots = empty:
      1. If cur.length <= 5: value = (cur sorted ascending)(k); stop
         (no pivot is recorded at this level).
      2. p = medianOfMedians(cur); append p to pivots.
      3. Stable three-way partition: L = the elements < p IN THEIR ORDER in cur,
         E = the number of elements == p, G = the elements > p in their order
         in cur.
      4. If k < L.length: cur = L, go to 1.
         Else if k < L.length + E: value = p; stop.
         Else: k = k - L.length - E, cur = G, go to 1.
  * Return Some(SelectResult(value, pivots)) with pivots in the order they were
    chosen (top level first). value is the k-th smallest element of xs.
  * Only these top-level pivots are recorded, never pivots used internally
    while computing a median of medians.
  * The pivots Vector is compared exactly. An in-place / Dutch-national-flag
    partition that reorders elements changes the order of L and G and
    therefore later pivots: it is wrong. Sorting xs gives the right value but
    not the right pivots.

Part B - Median of two sorted sources:
  * trait SortedSource { def length: Int; def get(index: Int): Int }
    A source is a read-only, sorted (non-decreasing) sequence of Ints of
    length >= 0. Lengths can be up to 2 * 10^9 and
    a.length + b.length <= 2147483647. The sequences are virtual (computed
    on demand) and can only be read with get(index), 0 <= index < length.
    Reading length is free.

- Implement `medianTwoSorted(a: SortedSource, b: SortedSource): Option[Double]`:
  * None if both sources are empty.
  * Otherwise the median of the merged multiset of both sequences:
    odd total -> the middle element (as a Double);
    even total -> the arithmetic mean of the two middle elements as a Double,
    e.g. 1 and 2 -> 1.5, -2147483648 and 2147483647 -> -0.5. The mean must not
    overflow 32-bit arithmetic: 2147483647 and 2147483647 -> 2147483647.0.
  * READ BUDGET: every get call counts (reading the same index again counts
    again). The total number of get calls on both sources must be at most
    16 * (bitlen(a.length + b.length) + 1), where bitlen(x) is the number of
    binary digits of x (bitlen(0) = 0, bitlen(7) = 3, bitlen(2*10^9) = 31,
    i.e. a budget of 512 reads).
  * The test sources throw an exception when the budget is exceeded or when an
    index outside 0..length-1 is read; that aborts the call and fails the test.
    Do NOT catch or suppress exceptions thrown by get, do NOT copy the sources
    into collections, and do not access the data in any other way.
  * A linear merge is far too slow and exceeds the budget. Use binary search:
    a partition search on the shorter source (O(log min(m, n)) reads) or the
    k-th element by halving k (O(log(m + n)) reads).
  * Use Long arithmetic for index computations: lengths are close to 2^31 and
    sums like (m + n + 1) or lo + hi can overflow Int.

Notes:
  - Floating-point results are compared with a 1e-9 tolerance.
  - The input Vector of selectKth / medianOfMedians must not be modified.
  - Use Scala 2.11 syntax and standard library only (no Scala 3 syntax, no
    2.12/2.13-only APIs such as LazyList or .to(List)).
```
