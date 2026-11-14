You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

Implement two order-statistics algorithms in C using the header file order_stats.h:
deterministic BFPRT selection that reports its pivot trace, and the median of two
sorted sequences that can only be read through a counting probe with a strict read
budget.

Algorithm A - median of medians / selection with trace
------------------------------------------------------
Values are 32-bit signed ints, duplicates allowed. The input array `xs` (n ints;
`xs` may be NULL when n == 0) must NOT be modified - work on copies.

  * Lower median of a non-empty group g: the element at 0-based index
    (len(g) - 1) / 2 (integer division) of g sorted ascending.

- Implement `median_of_medians(xs, n, out)`: Return false if n == 0 (leave *out
  alone). Otherwise split xs IN ITS CURRENT ORDER into consecutive groups of 5
  (xs[0..4], xs[5..9], ...; the last group may have 1-4 elements), take the lower
  median of each group, then write the lower median of the list of group medians to
  *out and return true. (How you compute that median of the medians does not
  matter, only its value.)

- Implement `select_kth(xs, n, k)`: Return NULL if k < 0 or k >= n. Otherwise
  return a freshly malloc'd SelectResult defined by this exact procedure, starting
  with cur = copy of xs, pivots = empty, k as given (0-based):
    1. If len(cur) <= 5: value = (cur sorted ascending)[k]; stop (no pivot is
       recorded at this level).
    2. p = median_of_medians(cur); append p to pivots.
    3. Stable three-way partition of cur: L = the elements < p IN THEIR ORDER in
       cur, E = the number of elements == p, G = the elements > p IN THEIR ORDER in
       cur.
    4. If k < len(L): cur = L, go to 1.
       Else if k < len(L) + E: value = p; stop.
       Else: k = k - len(L) - E, cur = G, go to 1.
  `value` is the k-th smallest element and `pivots` / `num_pivots` hold the pivots
  in the order they were chosen (top level first). Only these top-level pivots are
  recorded - not any pivots used internally while computing a median of medians.
  The pivot list is checked EXACTLY, so an in-place / Dutch-national-flag partition
  that reorders elements (and thus the groups of 5) gives a wrong trace, and so
  does sorting the input. `pivots` is a fresh heap array (it may be NULL when
  num_pivots == 0). The caller releases the result with `free_select_result`.

- Implement `free_select_result`: Free the result and its pivots array.
  `free_select_result(NULL)` is a no-op.

Algorithm B - median of two sorted sources under a read budget
--------------------------------------------------------------
A SortedSource is a read-only sorted (non-decreasing) sequence of 32-bit ints of
length `src->length` >= 0. Lengths can be up to 2*10^9 and
a->length + b->length <= 2147483647. Element i (0 <= i < length) can ONLY be read by
calling `src->get(src, i)`; reading `length` is free. Do not touch `ctx`.

- Implement `median_two_sorted(a, b, out)`: the median of the merged multiset of
  both sequences. Return false if both are empty. Otherwise write to *out:
    * odd total length: the middle element (as a double);
    * even total length: the arithmetic mean of the two middle elements as a
      double, e.g. (1 + 2) / 2 = 1.5. Compute it without 32-bit overflow:
      2147483647 and 2147483647 give 2147483647.0; -2147483648 and 2147483647 give
      -0.5.
  and return true.

  Read budget: every get call counts, including repeated reads of the same index.
  The total number of reads over both sources must be at most
      16 * (bitlen(len(a) + len(b)) + 1)
  where bitlen(x) is the number of binary digits of x (bitlen(0) = 0,
  bitlen(7) = 3, bitlen(2*10^9) = 31 -> budget 512). Reading an index outside
  0..length-1 is an error. When the budget is exceeded or an out-of-range index is
  read, the test's probe aborts your call immediately with longjmp (so do not
  allocate heap memory in this function - it would leak; none is needed). Do not
  copy the sources into arrays and do not access the data in any other way.

  Use binary search: partition search on the shorter source (O(log min(m, n))
  reads) or the k-th element by halving k (O(log(m + n)) reads). A linear merge
  exceeds the budget. Use 64-bit arithmetic (long long) for index computations -
  indices and sums of lengths come close to 2^31.

Constraints:
  - No memory leaks (verified by valgrind); free every temporary allocation.
  - All functions must handle their edge cases (empty inputs, one empty source,
    k out of range) without crashing.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

#ifndef ORDER_STATS_H
#define ORDER_STATS_H

#include <stdbool.h>

typedef struct {
    int value;      /* the k-th smallest element */
    int* pivots;    /* top-level BFPRT pivots, outermost first; heap; may be NULL if num_pivots == 0 */
    int num_pivots;
} SelectResult;

/*
 * Read-only sorted (non-decreasing) sequence of `length` ints (length >= 0, up to
 * 2*10^9). Element i (0 <= i < length) is read ONLY as src->get(src, i).
 * Every call counts against a read budget; reading past the budget or outside
 * 0..length-1 aborts the call (the probe longjmps out of it).
 */
typedef struct SortedSource {
    int length;
    int (*get)(const struct SortedSource* src, int index);
    void* ctx;      /* private data of the probe; do not touch */
} SortedSource;

/* Writes the BFPRT pivot (lower median of the lower medians of consecutive groups
   of 5) to *out and returns true; returns false if n == 0. xs is not modified. */
bool median_of_medians(const int* xs, int n, int* out);

/* k-th smallest (0-based) of xs with the trace of top-level pivots.
   NULL if k < 0 or k >= n. xs is not modified. Caller frees with free_select_result. */
SelectResult* select_kth(const int* xs, int n, int k);

/* Frees the result and its pivots array. Accepts NULL. */
void free_select_result(SelectResult* result);

/* Writes the median of the merged sequences a and b to *out and returns true;
   returns false if both are empty. */
bool median_two_sorted(const SortedSource* a, const SortedSource* b, double* out);

#endif