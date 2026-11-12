# Test 10

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement order statistics in Free Pascal in the unit order_stats (file order_stats.pas):
deterministic BFPRT selection that reports its pivot trace, and the median of two sorted
sequences that can only be read through a counting probe. The unit already declares the
types and the four routines; keep the interface unchanged and implement MedianOfMedians,
SelectKth, FreeSelectResult and MedianTwoSorted in the implementation section.

Part A - median of medians (values are LongInt, duplicates allowed):
  * Lower median of a non-empty group g = the element at 0-based index
    (Length(g) - 1) div 2 of g sorted ascending.
  * The input array Xs must NOT be modified. Note that `const` on a dynamic array
    parameter does not protect its elements and assigning one dynamic array variable to
    another shares storage: work on copies (Copy(Xs, 0, Length(Xs))).

- Implement `MedianOfMedians(const Xs: TIntArray; out Value: LongInt): Boolean`:
  return False if Xs is empty. Otherwise split Xs IN ITS CURRENT ORDER into consecutive
  groups of 5 (Xs[0..4], Xs[5..9], ...; the last group may have 1-4 elements), take the
  lower median of each group, set Value to the lower median of the list of group medians
  and return True. (How that last lower median is computed does not matter, only its
  value.)

- Implement `SelectKth(const Xs: TIntArray; K: LongInt): PSelectResult`: K is 0-based
  (K = 0 is the minimum). Return nil if K < 0 or K >= Length(Xs). Otherwise return a
  NEW record (New) whose Value is the K-th smallest element and whose Pivots is the trace
  produced by EXACTLY this procedure, starting with Cur = a copy of Xs and an empty
  pivot list:
    1. If Length(Cur) <= 5: Value = (Cur sorted ascending)[K]; stop (no pivot is recorded
       at this level).
    2. P = the median-of-medians pivot of Cur (as in MedianOfMedians); append P to Pivots.
    3. Stable three-way partition: L = the elements < P in their order in Cur,
       E = the number of elements = P, G = the elements > P in their order in Cur.
    4. If K < Length(L): Cur = L, go to 1.
       Else if K < Length(L) + E: Value = P; stop.
       Else K = K - Length(L) - E, Cur = G, go to 1.
  Pivots lists the pivots in order (top level first) and is compared exactly; it is an
  empty array when no pivot was recorded. Only these top-level pivots are recorded, not
  pivots used internally while computing a median of medians. An in-place / Dutch-flag
  partition that reorders elements produces a different trace and is wrong; sorting the
  whole input gives the right Value but not the trace.

- Implement `FreeSelectResult(var R: PSelectResult)`: free the record and set R to nil;
  FreeSelectResult(nil) is a no-op. The caller owns each returned record.

Part B - median of two sorted sources:
  * A source (PSortedSource) is a read-only sorted (non-decreasing) virtual sequence of
    LongInt values with Src^.Len elements (Len >= 0, up to 2 000 000 000; the sum of both
    lengths fits in LongInt). Element I, 0 <= I < Src^.Len, can ONLY be read by calling
    Src^.Get(Src, I). Reading Len is free. Ctx belongs to the caller - do not touch it.

- Implement `MedianTwoSorted(A, B: PSortedSource; out Value: Double): Boolean`:
  return False if both sources are empty (Len = 0). Otherwise set Value to the median of
  the merged multiset of both sequences and return True:
    * odd total length -> the middle element (as a Double);
    * even total length -> the arithmetic mean of the two middle elements as a Double,
      e.g. 1 and 2 -> 1.5. Compute it without LongInt overflow: 2147483647 and
      2147483647 -> 2147483647.0, -2147483648 and 2147483647 -> -0.5.
  * One source may be empty.
  * READ BUDGET: every Get call counts (reading the same index again counts again). The
    total number of reads over both sources must be at most 16 * (bitlen(A^.Len +
    B^.Len) + 1), where bitlen(x) is the number of binary digits of x (bitlen(0) = 0,
    bitlen(7) = 3, bitlen(2000000000) = 31 -> budget 512). Reading an index outside
    0..Len-1 is an error. The tests' probe raises an exception when the budget is
    exceeded or an index is out of range, and the test then fails.
  * Do NOT catch or suppress exceptions raised by Get, do not copy the sources into
    arrays, do not access the data in any other way.
  * Therefore use binary search: the partition search on the shorter source
    (O(log min(m, n)) reads) or the k-th element by halving k (O(log(m + n)) reads).
    A linear merge needs ~10^9 reads and is aborted.
  * Lengths reach 2*10^9: do index arithmetic in Int64 (i + j, (lo + hi) div 2, sums of
    lengths) so nothing overflows LongInt; pass indices to Get as LongInt.
  * Beware of single precision: FPC types a float literal such as 2.0 as Single, so
    (X + Y) / 2.0 with large integers can be computed in Single precision and turn
    2147483647 into 2147483648. Store the Int64 sum in a Double variable first and
    divide that (e.g. S := Int64Sum; Value := S / 2).

Pascal notes:
  - Pascal is case-insensitive: the out parameters are named Value, so do not declare
    another identifier Value; the source parameters are A and B, so do not declare
    locals named a or b. Do not name anything Result except the function result, and do
    not name variables Max, Min, Odd (RTL functions).
  - Call the getter exactly as Src^.Get(Src, I).
  - The program is run under valgrind and must not leak memory.
```
