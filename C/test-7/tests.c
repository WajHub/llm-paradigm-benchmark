#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "sequence_alignment.h"

static const char* STRESS_A =
    "CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA";
static const char* STRESS_B =
    "GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC";

/* Score of an alignment by definition: per-column match/mismatch, every maximal
   run of '-' in one row of length L costs gap_open + L * gap_extend. */
static int recompute_score(const char* sa, const char* sb, int m, int x, int o, int e) {
    size_t len = strlen(sa);
    int s = 0;
    for (size_t k = 0; k < len; k++) {
        if (sa[k] != '-' && sb[k] != '-') s += (sa[k] == sb[k]) ? m : -x;
    }
    const char* rows[2] = { sa, sb };
    for (int r = 0; r < 2; r++) {
        size_t k = 0;
        while (k < len) {
            if (rows[r][k] == '-') {
                int L = 0;
                while (k < len && rows[r][k] == '-') { L++; k++; }
                s -= o + L * e;
            } else {
                k++;
            }
        }
    }
    return s;
}

/* true iff removing every '-' from gapped gives exactly orig. */
static bool ungapped_equals(const char* gapped, const char* orig) {
    const char* p = orig;
    for (; *gapped; gapped++) {
        if (*gapped == '-') continue;
        if (*p != *gapped) return false;
        p++;
    }
    return *p == '\0';
}

/* Runs alignment_align and checks every invariant; if exp_a/exp_b are non-NULL the
   aligned strings must equal them exactly. Frees the result. */
static bool check_align(const char* a, const char* b, int m, int x, int o, int e,
                        int expected, const char* exp_a, const char* exp_b) {
    AlignmentResult* r = alignment_align(a, b, m, x, o, e);
    if (!r) return false;
    bool ok = r->aligned_a != NULL && r->aligned_b != NULL && r->score == expected;
    if (ok) ok = strlen(r->aligned_a) == strlen(r->aligned_b);
    if (ok) ok = ungapped_equals(r->aligned_a, a) && ungapped_equals(r->aligned_b, b);
    if (ok) {
        for (size_t k = 0; r->aligned_a[k]; k++) {
            if (r->aligned_a[k] == '-' && r->aligned_b[k] == '-') { ok = false; break; }
        }
    }
    if (ok) ok = recompute_score(r->aligned_a, r->aligned_b, m, x, o, e) == expected;
    if (ok && exp_a) ok = strcmp(r->aligned_a, exp_a) == 0 && strcmp(r->aligned_b, exp_b) == 0;
    free_alignment_result(r);
    return ok;
}

// ============================================================================
// TESTY Algorytmu A: alignment_score
// ============================================================================

bool test_algo_a_01_both_empty(void) {
    return alignment_score("", "", 1, 1, 2, 1) == 0;
}

bool test_algo_a_02_one_empty(void) {
    return alignment_score("", "ACG", 1, 1, 2, 1) == -5;
}

bool test_algo_a_03_identical(void) {
    return alignment_score("GATTACA", "GATTACA", 2, 1, 3, 1) == 14;
}

bool test_algo_a_04_mismatch_beats_gaps(void) {
    return alignment_score("A", "C", 1, 1, 2, 1) == -1;
}

bool test_algo_a_05_textbook(void) {
    return alignment_score("GATTACA", "GCATGCU", 1, 1, 1, 1) == -1;
}

bool test_algo_a_06_one_long_gap(void) {
    return alignment_score("AAAGGGTTT", "AAATTT", 2, 2, 5, 1) == 4;
}

bool test_algo_a_07_zero_extend(void) {
    return alignment_score("TTACGGA", "ACG", 2, 2, 2, 0) == 2;
}

bool test_algo_a_08_adjacent_gaps_beat_mismatch(void) {
    return alignment_score("XAY", "XCY", 1, 10, 1, 1) == -2;
}

bool test_algo_a_09_terminal_gaps_penalized(void) {
    return alignment_score("AAAACCCC", "CCCC", 2, 1, 3, 1) == 1;
}

bool test_algo_a_10_stress(void) {
    return alignment_score(STRESS_A, STRESS_B, 2, 1, 3, 1) == 16;
}

// ============================================================================
// TESTY Algorytmu B: alignment_align
// ============================================================================

bool test_algo_b_01_both_empty(void) {
    return check_align("", "", 1, 1, 2, 1, 0, "", "");
}

bool test_algo_b_02_second_empty(void) {
    return check_align("ACG", "", 1, 1, 2, 1, -5, "ACG", "---");
}

bool test_algo_b_03_identical(void) {
    return check_align("GATTACA", "GATTACA", 2, 1, 3, 1, 14, "GATTACA", "GATTACA");
}

bool test_algo_b_04_unique_long_gap(void) {
    return check_align("AAAGGGTTT", "AAATTT", 2, 2, 5, 1, 4, "AAAGGGTTT", "AAA---TTT");
}

bool test_algo_b_05_adjacent_gaps(void) {
    /* two optima: X-AY / XC-Y and XA-Y / X-CY -> invariants only */
    return check_align("XAY", "XCY", 1, 10, 1, 1, -2, NULL, NULL);
}

bool test_algo_b_06_textbook_unique(void) {
    return check_align("GATTACA", "GCATGCU", 1, 1, 1, 1, -1, "GATTACA", "GCATGCU");
}

bool test_algo_b_07_gap_merging(void) {
    return check_align("ACCCGT", "AGT", 2, 3, 6, 1, -3, "ACCCGT", "A---GT");
}

bool test_algo_b_08_gaps_in_both_rows(void) {
    return check_align("CACGCA", "AGGCGC", 3, 2, 3, 1, -1, "CA--CGCA", "-AGGCGC-");
}

bool test_algo_b_09_tied_gap_positions(void) {
    /* three optima -> invariants only */
    return check_align("AAAA", "AA", 1, 1, 1, 1, -1, NULL, NULL);
}

bool test_algo_b_10_stress_invariants(void) {
    return check_align(STRESS_A, STRESS_B, 3, 2, 5, 1, 10, NULL, NULL);
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

    printf("\n--- Algorithm A: Alignment Score ---\n");
    RUN_TEST(test_algo_a_01_both_empty,                  "Test A01 (Both Empty)");
    RUN_TEST(test_algo_a_02_one_empty,                   "Test A02 (One Empty)");
    RUN_TEST(test_algo_a_03_identical,                   "Test A03 (Identical)");
    RUN_TEST(test_algo_a_04_mismatch_beats_gaps,         "Test A04 (Mismatch Beats Gaps)");
    RUN_TEST(test_algo_a_05_textbook,                    "Test A05 (Textbook)");
    RUN_TEST(test_algo_a_06_one_long_gap,                "Test A06 (One Long Gap)");
    RUN_TEST(test_algo_a_07_zero_extend,                 "Test A07 (Zero Extend)");
    RUN_TEST(test_algo_a_08_adjacent_gaps_beat_mismatch, "Test A08 (Adjacent Gaps Beat Mismatch)");
    RUN_TEST(test_algo_a_09_terminal_gaps_penalized,     "Test A09 (Terminal Gaps Penalized)");
    RUN_TEST(test_algo_a_10_stress,                      "Test A10 (Stress)");

    printf("\n--- Algorithm B: Alignment Reconstruction ---\n");
    RUN_TEST(test_algo_b_01_both_empty,                  "Test B01 (Both Empty)");
    RUN_TEST(test_algo_b_02_second_empty,                "Test B02 (Second Empty)");
    RUN_TEST(test_algo_b_03_identical,                   "Test B03 (Identical)");
    RUN_TEST(test_algo_b_04_unique_long_gap,             "Test B04 (Unique Long Gap)");
    RUN_TEST(test_algo_b_05_adjacent_gaps,               "Test B05 (Adjacent Gaps)");
    RUN_TEST(test_algo_b_06_textbook_unique,             "Test B06 (Textbook Unique)");
    RUN_TEST(test_algo_b_07_gap_merging,                 "Test B07 (Gap Merging)");
    RUN_TEST(test_algo_b_08_gaps_in_both_rows,           "Test B08 (Gaps In Both Rows)");
    RUN_TEST(test_algo_b_09_tied_gap_positions,          "Test B09 (Tied Gap Positions)");
    RUN_TEST(test_algo_b_10_stress_invariants,           "Test B10 (Stress Invariants)");

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
