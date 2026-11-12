# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order statistics in GNU Smalltalk in the class OrderStatsImpl (file
OrderStatsImpl.st), which subclasses the abstract class OrderStats: deterministic BFPRT
selection (median of medians) that also reports the trace of pivots, and the median of
two sorted sequences that may only be read through a counting probe with a logarithmic
read budget. The result class SelectResult (class-side constructor
`SelectResult value: anInteger pivots: anArray`, accessors value and pivots) is already
defined. Implement medianOfMedians:, selectKth:from: and medianOf:and:.
Put the solution in OrderStatsImpl.st.

Part A - median of medians (xs is an Array of Integers, duplicates allowed; do NOT
modify xs):
  * Lower median of a non-empty group g = the element at 1-based position
    ((g size - 1) // 2) + 1 of g sorted ascending (for an even size, the smaller of the
    two middle elements).

- Implement `medianOfMedians: xs`: answer nil if xs is empty. Otherwise split xs IN ITS
  CURRENT ORDER into consecutive groups of 5 (positions 1..5, 6..10, ...; the last group
  may have 1 to 4 elements), take the lower median of each group, and answer the lower
  median of the collection of group medians (in group order). How that final lower
  median is computed does not matter, only its value.

- Implement `selectKth: k from: xs`: k is 1-BASED (k = 1 is the minimum, k = xs size the
  maximum). Answer nil if k < 1 or k > xs size (in particular for an empty xs).
  Otherwise answer a SelectResult whose value is the k-th smallest element and whose
  pivots is an Array (empty Array if no pivot was recorded) produced by EXACTLY this
  procedure, starting with cur = xs, rank = k, pivots = empty:
    1. If cur size <= 5: value = the element at position rank of cur sorted ascending;
       stop (no pivot is recorded at this level).
    2. p := medianOfMedians: cur; append p to pivots.
    3. Stable three-way partition: L = the elements < p IN THEIR ORDER IN cur,
       E = the number of elements = p, G = the elements > p in their order in cur.
    4. If rank <= L size: cur := L, go to 1.
       Else if rank <= L size + E: value = p; stop.
       Else rank := rank - L size - E, cur := G, go to 1.
  pivots lists the pivots of the top-level steps in order (first step first) and is
  compared exactly. Pivots used internally while computing a median of medians are NOT
  recorded. An in-place / Dutch-flag partition that reorders elements produces a
  different trace and is wrong; sorting xs gives the right value but not the trace.

Part B - median of two sorted sources:
  * A source is a read-only object that answers ONLY two messages: `size` (its length,
    >= 0, up to 2000000000; reading the size is free) and `at: i` (1-BASED: at: 1 is the
    first element; i must be an Integer with 1 <= i <= size). Its elements are Integers
    in non-decreasing order. Do not send any other message to a source (no isEmpty,
    first, last, do:, asArray, copy...) - they are not understood.
  * Every `at:` call is counted, repeated reads of the same index count again. The total
    number of reads over BOTH sources must not exceed 16 * (bitlen(a size + b size) + 1),
    where bitlen(x) is the number of binary digits of x (bitlen(0) = 0, bitlen(7) = 3;
    for 2000000000 elements the budget is 512). Reading an index outside 1..size or
    exceeding the budget signals an Error that aborts the call: do NOT catch or suppress
    errors coming from a source (a swallowed violation is detected anyway), and do not
    copy a source into a collection. Index arithmetic must use Integers (use //, never /).

- Implement `medianOf: a and: b`: answer the median of the merged multiset of both
  sources as a Float: for an odd total, the middle element (as a Float, e.g. 3.0); for
  an even total, the arithmetic mean of the two middle elements (e.g. 1 and 2 -> 1.5).
  Answer nil if both sources are empty. Either source alone may be empty.
  Use binary search: a partition search on the shorter source (O(log min(m, n)) reads)
  or k-th element search by halving k (O(log(m + n)) reads). A linear merge exceeds the
  budget and fails.

Constraints:
  - Integer values fit in 32 bits, but sizes up to 2*10^9 are used, so never build
    collections of the sources' size.
  - Floating-point results are compared with a 1e-9 tolerance.
```
