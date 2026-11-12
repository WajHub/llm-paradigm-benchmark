# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order-statistics algorithms in Java in the class OrderStatsImpl (file
OrderStatsImpl.java), which extends the abstract class OrderStats: deterministic BFPRT
selection (median of medians) that reports its pivot trace, and the median of two sorted
sequences that may only be read through a counting probe with a logarithmic read budget.
The base class already defines OrderStats.SelectResult and the interface
OrderStats.SortedSource; implement medianOfMedians, selectKth and medianTwoSorted.

Part A - median of medians (values are ints, duplicates allowed). The input array must
NOT be modified.

  * Lower median of a non-empty group g = the element at 0-based index (g.length - 1) / 2
    (integer division) of g sorted ascending. E.g. lower median of [4, 1, 3, 2] is 2.

- Implement `Integer medianOfMedians(int[] xs)`: split xs IN ITS CURRENT ORDER into
  consecutive groups of 5 (xs[0..4], xs[5..9], ...; the last group may have 1-4
  elements), take the lower median of each group, and return the lower median of the
  list of these group medians. Return null if xs is empty. (How you compute the median of
  the group medians does not matter, only its value.)

- Implement `SelectResult selectKth(int[] xs, int k)`: k is 0-based (k = 0 is the
  minimum). Return null if k < 0 or k >= xs.length. Otherwise run EXACTLY this procedure,
  starting with cur = xs (a copy) and an empty pivot list:
    1. If cur.length <= 5: the answer is sorted(cur)[k]; stop (no pivot is recorded at
       this level).
    2. p = medianOfMedians(cur); append p to the pivot list.
    3. Stable three-way partition: L = the elements of cur that are < p, in their order
       in cur; E = the number of elements == p; G = the elements > p, in their order in cur.
    4. If k < L.length: cur = L, go to 1.
       Else if k < L.length + E: the answer is p; stop.
       Else: k = k - L.length - E, cur = G, go to 1.
  Return new SelectResult(answer, pivots) where pivots holds the recorded pivots in order
  (top level first; an empty int[] when none). Only these top-level pivots are recorded,
  not pivots used internally while computing a median of medians. The pivot list is
  compared exactly: an in-place / Dutch-national-flag partition that reorders elements
  produces a different trace and is wrong; so is simply sorting the input.

Part B - median of two sorted sources.

  * A SortedSource is a read-only non-decreasing sequence of ints. length() (free to call)
    can be up to 2_000_000_000 and a.length() + b.length() <= Integer.MAX_VALUE.
    Elements are read only through get(index) with 0 <= index < length().

- Implement `Double medianTwoSorted(SortedSource a, SortedSource b)`: the median of the
  merged multiset of both sequences. Odd total -> the middle element; even total -> the
  arithmetic mean of the two middle elements as a double, e.g. (1 + 2) / 2 = 1.5.
  Compute the mean without int overflow (2147483647 and 2147483647 -> 2147483647.0).
  Return null if both sources are empty. The result is a Double even for odd totals.

  Read budget (enforced by the tests): every get call counts, including repeated reads of
  the same index. The total number of get calls on both sources must be at most
  16 * (bitlen(a.length() + b.length()) + 1), where bitlen(x) is the number of binary
  digits of x (bitlen(0) = 0, bitlen(7) = 3, bitlen(2_000_000_000) = 31 -> budget 512).
  Reading an index outside 0..length()-1 is an error. The tests' sources throw a
  RuntimeException when the budget is exceeded or an index is out of range, which fails
  the test. Do NOT catch or suppress exceptions thrown by get, do NOT copy the sources into
  arrays or collections, and do not access the data in any other way.
  Use a binary search: partition search on the shorter source (O(log min(m, n)) reads) or
  k-th element by halving k (O(log(m + n)) reads). A linear merge exceeds the budget.
  Lengths are close to 2^31, so do index arithmetic (sums, midpoints) in long or otherwise
  overflow-safe.

Keep the contract in OrderStats.java; put the solution in OrderStatsImpl.java.
```
