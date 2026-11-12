#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <math.h>
#include <setjmp.h>
#include "order_stats.h"

#define COUNT(arr) ((int)(sizeof(arr) / sizeof((arr)[0])))
#define EPS 1e-9

/* ---------------------------------------------------------------------------
 * Algorithm A helpers
 * ------------------------------------------------------------------------- */

static bool mom_is(const int* xs, int n, int expected) {
    int v = expected + 12345;
    return median_of_medians(xs, n, &v) && v == expected;
}

static bool mom_absent(const int* xs, int n) {
    int v = 0;
    return !median_of_medians(xs, n, &v);
}

/* select_kth(xs, n, k) must give exactly (value, pivots[0..np-1]). */
static bool sel_is(const int* xs, int n, int k, int value, const int* pivots, int np) {
    SelectResult* r = select_kth(xs, n, k);
    if (!r) return false;
    bool ok = r->value == value && r->num_pivots == np
        && (np == 0 || (r->pivots && memcmp(r->pivots, pivots, (size_t)np * sizeof(int)) == 0));
    free_select_result(r);
    return ok;
}

static bool sel_absent(const int* xs, int n, int k) {
    SelectResult* r = select_kth(xs, n, k);
    if (r) {
        free_select_result(r);
        return false;
    }
    return true;
}

/* xs[i] = (r mod 20001) - 10000 for the LCG outputs r (seed 42). */
static void gen_stress(int* out, int n) {
    long long x = 42;
    for (int i = 0; i < n; i++) {
        x = (x * 1103515245LL + 12345LL) % 2147483648LL;
        out[i] = (int)((x / 65536) % 20001) - 10000;
    }
}

/* ---------------------------------------------------------------------------
 * Algorithm B probe: counts reads over both sources and aborts the call with
 * longjmp when the budget is exceeded or an index is out of range.
 * ------------------------------------------------------------------------- */

typedef struct {
    const int* data;    /* literal array, or NULL for a formula source */
    long long mul;      /* formula: f(i) = (i * mul) / div + add */
    long long div;
    long long add;
} ProbeCtx;

static jmp_buf g_abort;
static long long g_reads;
static long long g_budget;

static int probe_get(const SortedSource* src, int index) {
    g_reads++;
    if (!src || g_reads > g_budget || index < 0 || index >= src->length) longjmp(g_abort, 1);
    const ProbeCtx* c = (const ProbeCtx*)src->ctx;
    if (c->data) return c->data[index];
    return (int)(((long long)index * c->mul) / c->div + c->add);
}

static SortedSource array_source(ProbeCtx* ctx, const int* data, int len) {
    ctx->data = data;
    ctx->mul = 0; ctx->div = 1; ctx->add = 0;
    SortedSource s = { len, probe_get, ctx };
    return s;
}

static SortedSource formula_source(ProbeCtx* ctx, int len, long long mul, long long div, long long add) {
    ctx->data = NULL;
    ctx->mul = mul; ctx->div = div; ctx->add = add;
    SortedSource s = { len, probe_get, ctx };
    return s;
}

/* Runs median_two_sorted under the probe. *present receives its return value. Returns
   false if the call was aborted (budget exceeded / out-of-range read). */
static bool probed_median(const SortedSource* a, const SortedSource* b, long long budget,
                          bool* present, double* value) {
    g_reads = 0;
    g_budget = budget;
    if (setjmp(g_abort) != 0) return false;
    *present = median_two_sorted(a, b, value);
    return true;
}

static bool median_is(const SortedSource* a, const SortedSource* b, long long budget, double expected) {
    bool present = false;
    double v = NAN;
    if (!probed_median(a, b, budget, &present, &v)) return false;
    return present && fabs(v - expected) < EPS;
}

static bool median_absent(const SortedSource* a, const SortedSource* b, long long budget) {
    bool present = true;
    double v = 0.0;
    if (!probed_median(a, b, budget, &present, &v)) return false;
    return !present;
}

// ============================================================================
// TESTY Algorytmu A: median_of_medians / select_kth
// ============================================================================

bool test_algo_a_01_empty(void) {
    return mom_absent(NULL, 0) && sel_absent(NULL, 0, 0);
}

bool test_algo_a_02_single(void) {
    const int xs[] = { 7 };
    return mom_is(xs, 1, 7)
        && sel_is(xs, 1, 0, 7, NULL, 0)
        && sel_absent(xs, 1, 1);
}

bool test_algo_a_03_out_of_range(void) {
    const int xs[] = { 3, 1, 2 };
    return sel_absent(xs, 3, 3)
        && sel_absent(xs, 3, -1)
        && sel_is(xs, 3, 2, 3, NULL, 0)
        && mom_is(xs, 3, 2);
}

bool test_algo_a_04_one_group(void) {
    const int xs[] = { 9, 1, 8, 2, 7 };
    return mom_is(xs, 5, 7)
        && sel_is(xs, 5, 0, 1, NULL, 0)
        && sel_is(xs, 5, 2, 7, NULL, 0)
        && sel_is(xs, 5, 4, 9, NULL, 0);
}

bool test_algo_a_05_pivot_is_not_median(void) {
    const int xs[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const int p[] = { 3, 6 };
    return mom_is(xs, COUNT(xs), 3)
        && sel_is(xs, COUNT(xs), 4, 5, p, 2)
        && sel_is(xs, COUNT(xs), 5, 6, p, 2);
}

bool test_algo_a_06_partial_last_group(void) {
    const int xs[] = { 5, 3, 9, 1, 8, 2, 6 };
    const int p[] = { 2 };
    return mom_is(xs, COUNT(xs), 2)
        && sel_is(xs, COUNT(xs), 3, 5, p, 1)
        && sel_is(xs, COUNT(xs), 6, 9, p, 1);
}

bool test_algo_a_07_many_duplicates(void) {
    const int xs[] = { 5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5 };
    const int p[] = { 5 };
    return mom_is(xs, COUNT(xs), 5)
        && sel_is(xs, COUNT(xs), 0, 1, p, 1)
        && sel_is(xs, COUNT(xs), 5, 5, p, 1)
        && sel_is(xs, COUNT(xs), 10, 9, p, 1);
}

bool test_algo_a_08_stable_partition_order(void) {
    const int xs[] = { 40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27 };
    const int p[] = { 40, 41, 51 };
    return mom_is(xs, COUNT(xs), 40)
        && sel_is(xs, COUNT(xs), 6, 51, p, 3);
}

bool test_algo_a_09_all_ranks(void) {
    const int xs[] = { 12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14 };
    const int sorted[] = { -30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41 };
    const int p_low[] = { 3, -11 };
    const int p_mid[] = { 3 };
    const int p_high[] = { 3, 14 };
    int n = COUNT(xs);
    int copy[COUNT(xs)];
    memcpy(copy, xs, sizeof(copy));
    bool ok = mom_is(copy, n, 3);
    for (int k = 0; k < n && ok; k++) {
        if (k <= 6) ok = sel_is(copy, n, k, sorted[k], p_low, 2);
        else if (k <= 11) ok = sel_is(copy, n, k, sorted[k], p_mid, 1);
        else ok = sel_is(copy, n, k, sorted[k], p_high, 2);
    }
    return ok && memcmp(copy, xs, sizeof(copy)) == 0;
}

bool test_algo_a_10_stress(void) {
    enum { N = 5000 };
    static int xs[N];
    gen_stress(xs, N);
    const int p0[] = { -1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995 };
    const int p1[] = { -1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694 };
    const int p2[] = { -1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974 };
    return mom_is(xs, N, -1678)
        && sel_is(xs, N, 0, -9996, p0, COUNT(p0))
        && sel_is(xs, N, 2499, -1694, p1, COUNT(p1))
        && sel_is(xs, N, 4999, 9984, p2, COUNT(p2));
}

// ============================================================================
// TESTY Algorytmu B: median_two_sorted (probe with read budget)
// ============================================================================

bool test_algo_b_01_both_empty(void) {
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, NULL, 0);
    SortedSource b = array_source(&cb, NULL, 0);
    return median_absent(&a, &b, 16);
}

bool test_algo_b_02_one_empty(void) {
    static const int vb[] = { 1, 2, 3, 4 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, NULL, 0);
    SortedSource b = array_source(&cb, vb, COUNT(vb));
    return median_is(&a, &b, 64, 2.5);
}

bool test_algo_b_03_single_each(void) {
    static const int va[] = { 1 };
    static const int vb[] = { 2 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, va, 1);
    SortedSource b = array_source(&cb, vb, 1);
    return median_is(&a, &b, 48, 1.5);
}

bool test_algo_b_04_odd_total_interleaved(void) {
    static const int va[] = { 1, 3, 5 };
    static const int vb[] = { 2, 4 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, va, COUNT(va));
    SortedSource b = array_source(&cb, vb, COUNT(vb));
    return median_is(&a, &b, 64, 3.0);
}

bool test_algo_b_05_disjoint_ranges(void) {
    static const int va[] = { 10, 11, 12, 13 };
    static const int vb[] = { 1, 2, 3 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, va, COUNT(va));
    SortedSource b = array_source(&cb, vb, COUNT(vb));
    return median_is(&a, &b, 64, 10.0);
}

bool test_algo_b_06_duplicates(void) {
    static const int va[] = { 1, 1, 1, 1 };
    static const int vb[] = { 1, 1, 2 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, va, COUNT(va));
    SortedSource b = array_source(&cb, vb, COUNT(vb));
    return median_is(&a, &b, 64, 1.0);
}

bool test_algo_b_07_no_overflow(void) {
    static const int max1[] = { 2147483647 };
    static const int ext[] = { -2147483647 - 1, 2147483647 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, max1, 1);
    SortedSource b = array_source(&cb, max1, 1);
    bool first = median_is(&a, &b, 48, 2147483647.0);
    ProbeCtx cc, cd;
    SortedSource c = array_source(&cc, ext, 2);
    SortedSource d = array_source(&cd, NULL, 0);
    bool second = median_is(&c, &d, 48, -0.5);
    return first && second;
}

bool test_algo_b_08_huge_interleaved(void) {
    ProbeCtx ca, cb;
    SortedSource a = formula_source(&ca, 1000000000, 2, 1, -1000000000LL);   /* 2i - 10^9 */
    SortedSource b = formula_source(&cb, 999999999, 2, 1, -999999999LL);     /* 2j - 999999999 */
    return median_is(&a, &b, 512, -1.0);
}

bool test_algo_b_09_huge_unbalanced(void) {
    static const int va[] = { -5, 0, 7 };
    ProbeCtx ca, cb;
    SortedSource a = array_source(&ca, va, COUNT(va));
    SortedSource b = formula_source(&cb, 2000000000, 1, 2, -500000000LL);    /* j div 2 - 5*10^8 */
    return median_is(&a, &b, 512, 0.0);
}

bool test_algo_b_10_huge_duplicates(void) {
    ProbeCtx ca, cb;
    SortedSource a = formula_source(&ca, 1500000000, 1, 1000000, 0);         /* i div 10^6 */
    SortedSource b = formula_source(&cb, 600000000, 1, 3000000, 700);        /* 700 + j div 3*10^6 */
    return median_is(&a, &b, 512, 787.0);
}

int main() {
    int failed_count = 0;
    const char* failed_tests[50];
    int total_tests = 0;

    #define RUN_TEST(func, name) \
        do { \
            total_tests++; \
            if (func()) { \
                printf("[PASS] %s\n", name); \
            } else { \
                printf("[FAIL] %s\n", name); \
                failed_tests[failed_count++] = name; \
            } \
        } while (0)

    printf("=== START ===\n");

    printf("\n--- Algorithm A: Median of Medians ---\n");
    RUN_TEST(test_algo_a_01_empty,                    "Test A01 (Empty)");
    RUN_TEST(test_algo_a_02_single,                   "Test A02 (Single)");
    RUN_TEST(test_algo_a_03_out_of_range,             "Test A03 (Out Of Range)");
    RUN_TEST(test_algo_a_04_one_group,                "Test A04 (One Group)");
    RUN_TEST(test_algo_a_05_pivot_is_not_median,      "Test A05 (Pivot Is Not Median)");
    RUN_TEST(test_algo_a_06_partial_last_group,       "Test A06 (Partial Last Group)");
    RUN_TEST(test_algo_a_07_many_duplicates,          "Test A07 (Many Duplicates)");
    RUN_TEST(test_algo_a_08_stable_partition_order,   "Test A08 (Stable Partition Order)");
    RUN_TEST(test_algo_a_09_all_ranks,                "Test A09 (All Ranks)");
    RUN_TEST(test_algo_a_10_stress,                   "Test A10 (Stress)");

    printf("\n--- Algorithm B: Median of Two Sorted Arrays ---\n");
    RUN_TEST(test_algo_b_01_both_empty,               "Test B01 (Both Empty)");
    RUN_TEST(test_algo_b_02_one_empty,                "Test B02 (One Empty)");
    RUN_TEST(test_algo_b_03_single_each,              "Test B03 (Single Each)");
    RUN_TEST(test_algo_b_04_odd_total_interleaved,    "Test B04 (Odd Total Interleaved)");
    RUN_TEST(test_algo_b_05_disjoint_ranges,          "Test B05 (Disjoint Ranges)");
    RUN_TEST(test_algo_b_06_duplicates,               "Test B06 (Duplicates)");
    RUN_TEST(test_algo_b_07_no_overflow,              "Test B07 (No Overflow)");
    RUN_TEST(test_algo_b_08_huge_interleaved,         "Test B08 (Huge Interleaved)");
    RUN_TEST(test_algo_b_09_huge_unbalanced,          "Test B09 (Huge Unbalanced)");
    RUN_TEST(test_algo_b_10_huge_duplicates,          "Test B10 (Huge Duplicates)");

    printf("\n=== BENCHMARK RESULTS ===\n");
    printf("Completed %d tests.\n", total_tests);

    if (failed_count == 0) {
        printf("All tests passed!\n");
        return 0;
    } else {
        printf("Tests that failed (%d):\n", failed_count);
        for (int i = 0; i < failed_count; i++) {
            printf(" - %s\n", failed_tests[i]);
        }
        return 1;
    }
}
