# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order-statistics algorithms in Haskell in the module OrderStats
(file OrderStats.hs): deterministic BFPRT selection that also reports its
pivot trace, and the median of two sorted sequences under a strict read
budget. The module already defines SelectResult and Source; implement
medianOfMedians, selectKth and medianTwoSorted.

Part A -- Median of Medians (values are Ints in the 32-bit range, duplicates
allowed).

  * Lower median of a non-empty group g: the element at 0-based index
    (length g - 1) `div` 2 of g sorted ascending.

- Implement `medianOfMedians :: [Int] -> Maybe Int`: Nothing for []. Otherwise
  split xs IN ITS CURRENT ORDER into consecutive groups of 5 (xs[0..4],
  xs[5..9], ...; the last group may have 1-4 elements), take the lower median
  of each group, and return the lower median of the list of these group
  medians. (How that last lower median is computed -- recursively with BFPRT or
  by sorting -- does not matter, only its value.)

- Implement `selectKth :: [Int] -> Int -> Maybe SelectResult`
  (`selectKth xs k`, k is 0-based): Nothing if k < 0 or k >= length xs.
  Otherwise the result is defined by EXACTLY this procedure, starting with
  cur = xs, pivots = []:
    1. If length cur <= 5: return selValue = (sort cur) !! k
       (no pivot is recorded at this level).
    2. p = medianOfMedians cur; append p to pivots.
    3. Stable three-way partition of cur: L = the elements < p in their order
       in cur, E = the number of elements == p, G = the elements > p in their
       order in cur.
    4. If k < length L: cur = L, go to 1.
       Else if k < length L + E: return selValue = p.
       Else: k = k - length L - E, cur = G, go to 1.
  selPivots is the list of pivots in the order they were chosen (top level
  first). Only these top-level pivots are recorded, not pivots used
  internally while computing a median of medians. The tests compare
  selPivots exactly; a partition that reorders elements (e.g. in-place /
  Dutch-flag partitioning) produces a different trace and is wrong. Sorting
  the whole input gives the right value but not the right trace.

Part B -- Median of two sorted sources.

  data Source m = Source { srcLength :: Int, srcGet :: Int -> m Int }

  A Source is a read-only sorted (non-decreasing) sequence of Ints in the
  32-bit range, of length srcLength >= 0 (up to 2*10^9; the sum of both
  lengths is <= 2147483647). Its elements can ONLY be read through the
  monadic probe `srcGet src i` with a 0-based index 0 <= i < srcLength.
  Reading srcLength is free.

- Implement `medianTwoSorted :: Monad m => Source m -> Source m -> m (Maybe Double)`:
  return the median of the merged multiset of both sequences:
  * odd total length: the middle element (as a Double);
  * even total length: the arithmetic mean of the two middle elements as a
    Double, e.g. 1 and 2 -> 1.5, 2147483647 and 2147483647 -> 2147483647.0,
    -2147483648 and 2147483647 -> -0.5;
  * both sources empty: Nothing.

  Read budget:
  * Every srcGet call counts (reading the same index again counts again).
    The total number of reads over both sources must be at most
      16 * (bitlen (len a + len b) + 1)
    where bitlen x = number of binary digits of x (bitlen 0 = 0,
    bitlen 7 = 3, bitlen (2*10^9) = 31 -> budget 512).
  * The tests run medianTwoSorted in IO with a probe that throws an exception
    as soon as the budget is exceeded or an index outside 0..len-1 is read;
    the test then fails. Do not catch or suppress such errors, do not copy
    the sources into lists/arrays, and do not access the data in any other
    way. The sources are virtual and can be huge, so a linear merge is far
    over budget.
  * Use binary search: a partition search on the shorter source
    (O(log (min m n)) reads) or the k-th element by halving k
    (O(log (m + n)) reads). Index arithmetic near 2^31 must not overflow.

Constraints:
  - Floating-point results are compared with a tolerance of 1e-9.
  - Only the libraries shipped with GHC (base, containers, array).
```
