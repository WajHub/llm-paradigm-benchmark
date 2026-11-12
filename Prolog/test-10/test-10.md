# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order-statistics algorithms in SWI-Prolog in the module order_stats (file
order_stats.pl): deterministic selection (median of medians / BFPRT) that reports
its pivot trace, and the median of two sorted sequences under a logarithmic read
budget. Implement median_of_medians/2, select_kth/3 and median_two_sorted/3.

Part A - Median of medians (Xs is a list of integers, duplicates allowed).

  Lower median of a non-empty group G: the element at 0-based index
  (length(G) - 1) // 2 of G sorted ascending (duplicates kept, e.g. msort/2).

- Implement `median_of_medians(+Xs, -M)`: split Xs IN ITS CURRENT ORDER into
  consecutive groups of 5 (elements 0..4, 5..9, ...; the last group may have 1-4
  elements), take the lower median of every group, and let M be the lower median of
  the list of these group medians. M = none if Xs = []. (How the median of the
  medians is computed does not matter, only its value.)

- Implement `select_kth(+Xs, +K, -Result)`: K is 0-based. Result = none if K < 0
  or K >= length(Xs). Otherwise Result = select(Value, Pivots) computed by exactly
  this procedure, starting with Cur = Xs and an empty pivot list:
    1. If length(Cur) =< 5: Value = the element at index K of Cur sorted ascending
       (duplicates kept); stop. No pivot is recorded at this level.
    2. P = median_of_medians(Cur); append P to the pivot list.
    3. Stable three-way partition: L = the elements of Cur that are < P, in their
       order in Cur; E = the number of elements equal to P; G = the elements > P,
       in their order in Cur.
    4. If K < length(L): Cur = L, go to 1.
       Else if K < length(L) + E: Value = P; stop.
       Else K = K - length(L) - E, Cur = G, go to 1.
  Value is the K-th smallest element of Xs and Pivots is the list of the pivots in
  the order they were chosen (top level first). Only these pivots are recorded, not
  any pivot used internally while computing a median of medians. The Pivots list is
  checked exactly: an in-place / Dutch-flag partition that reorders elements, or
  sorting the whole input, produces a different (wrong) trace.
  * Example: select_kth([7,2,9,4,1,8,3,6,5,10,0], 8, R) gives R = select(8, [4,7])
    (pivot 4 splits off [2,1,3,0], then K = 3 in [7,9,8,6,5,10], pivot 7 leaves
    K = 0 in [9,8,10], which has at most 5 elements, so Value = 8).

Part B - Median of two sorted sources.

  A source is a term source(Length, Getter): a read-only non-decreasing sequence of
  32-bit integers of length Length >= 0 (Length can be up to 2000000000). Its
  element with 0-based index I (0 =< I < Length) is read with
  call(Getter, I, Value). Reading Length is free.

- Implement `median_two_sorted(+A, +B, -Median)`: Median is the median of the
  merged multiset of both sequences: for an odd total the middle element, for an
  even total the arithmetic mean of the two middle elements (e.g. 1 and 2 give 1.5;
  2147483647 and 2147483647 give 2147483647). Median is a number (integer or float;
  compared with a tolerance of 1e-9). Median = none if both sources are empty.
  * Read budget: every call of a Getter counts as one read (reading the same index
    again counts again). The total number of reads over both sources must be at
    most 16 * (bitlen(LenA + LenB) + 1), where bitlen(X) is the number of binary
    digits of X (bitlen(0) = 0, bitlen(7) = 3, bitlen(2000000000) = 31, giving a
    budget of 512 reads). Reading an index outside 0..Length-1 is an error.
  * When the budget is exceeded or an index is out of range, the Getter throws an
    exception and the test fails. Do not catch or suppress exceptions thrown by a
    Getter, do not copy the sources into lists, and do not access the data in any
    other way.
  * Use binary search: a partition search on the shorter source (O(log min(m, n))
    reads) or the k-th element by halving k (O(log(m + n)) reads). A linear merge
    needs about 10^9 reads on the large tests and will be aborted.

Constraints:
  - All predicates are deterministic (a single answer).
  - Results of Part A are compared with ==: M and Value are integers, Pivots is a
    proper list of integers, and absence is the atom none.
```
