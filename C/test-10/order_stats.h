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
