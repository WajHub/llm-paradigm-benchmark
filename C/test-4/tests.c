#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "knapsack.h"

static int reference_dp(const int* weights, const int* values, int n, int capacity) {
    if (n <= 0 || capacity <= 0) return 0;
    int* dp = (int*)calloc((size_t)(capacity + 1), sizeof(int));
    if (!dp) return -1;
    for (int i = 0; i < n; i++) {
        for (int c = capacity; c >= weights[i]; c--) {
            int cand = dp[c - weights[i]] + values[i];
            if (cand > dp[c]) dp[c] = cand;
        }
    }
    int result = dp[capacity];
    free(dp);
    return result;
}

static bool selected_equals(const int* actual, const int* expected, int n) {
    if (!actual) return false;
    for (int i = 0; i < n; i++) {
        if (actual[i] != expected[i]) return false;
    }
    return true;
}

/* ============================================================================
 * ALGORITHM A: Maximum Value
 * ============================================================================ */

bool test_algo_a_01_empty(void) {
    return knapsack_max_value(NULL, NULL, 0, 10) == 0;
}

bool test_algo_a_02_single_fit(void) {
    int w[] = {5};
    int v[] = {10};
    return knapsack_max_value(w, v, 1, 10) == 10;
}

bool test_algo_a_03_too_heavy(void) {
    int w[] = {15};
    int v[] = {10};
    return knapsack_max_value(w, v, 1, 10) == 0;
}

bool test_algo_a_04_cap_zero(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    return knapsack_max_value(w, v, 3, 0) == 0;
}

bool test_algo_a_05_choose_better(void) {
    int w[] = {5, 6};
    int v[] = {10, 11};
    return knapsack_max_value(w, v, 2, 10) == 11;
}

bool test_algo_a_06_textbook(void) {
    int w[] = {2, 3, 4, 5};
    int v[] = {3, 4, 5, 6};
    return knapsack_max_value(w, v, 4, 5) == 7;
}

bool test_algo_a_07_greedy_trap(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    return knapsack_max_value(w, v, 3, 50) == 220;
}

bool test_algo_a_08_same_items(void) {
    int w[] = {3, 3, 3, 3};
    int v[] = {5, 5, 5, 5};
    return knapsack_max_value(w, v, 4, 10) == 15;
}

bool test_algo_a_09_tight_fit(void) {
    int w[] = {3, 4, 5, 6};
    int v[] = {2, 3, 4, 5};
    return knapsack_max_value(w, v, 4, 10) == 8;
}

bool test_algo_a_10_stress(void) {
    const int n = 50;
    int w[50], v[50];
    for (int i = 0; i < n; i++) {
        w[i] = i + 1;
        v[i] = (i + 1) * 2;
    }
    int expected = reference_dp(w, v, n, 100);
    if (expected < 0) return false;
    return knapsack_max_value(w, v, n, 100) == expected;
}

/* ============================================================================
 * ALGORITHM B: Item Selection
 * ============================================================================ */

bool test_algo_b_01_single_selection(void) {
    int w[] = {5};
    int v[] = {10};
    KnapsackResult* r = knapsack_solve(w, v, 1, 10);
    if (!r) return false;
    int expected[] = {1};
    bool passed = r->max_value == 10 && r->total_weight == 5
        && selected_equals(r->selected, expected, 1);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_02_choose_better_selection(void) {
    int w[] = {5, 6};
    int v[] = {10, 11};
    KnapsackResult* r = knapsack_solve(w, v, 2, 10);
    if (!r) return false;
    int expected[] = {0, 1};
    bool passed = r->max_value == 11 && r->total_weight == 6
        && selected_equals(r->selected, expected, 2);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_03_textbook_selection(void) {
    int w[] = {2, 3, 4, 5};
    int v[] = {3, 4, 5, 6};
    KnapsackResult* r = knapsack_solve(w, v, 4, 5);
    if (!r) return false;
    int expected[] = {1, 1, 0, 0};
    bool passed = r->max_value == 7 && r->total_weight == 5
        && selected_equals(r->selected, expected, 4);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_04_greedy_trap_selection(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    KnapsackResult* r = knapsack_solve(w, v, 3, 50);
    if (!r) return false;
    int expected[] = {0, 1, 1};
    bool passed = r->max_value == 220 && r->total_weight == 50
        && selected_equals(r->selected, expected, 3);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_05_cap_zero_selection(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    KnapsackResult* r = knapsack_solve(w, v, 3, 0);
    if (!r) return false;
    int expected[] = {0, 0, 0};
    bool passed = r->max_value == 0 && r->total_weight == 0
        && selected_equals(r->selected, expected, 3);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_06_too_heavy_selection(void) {
    int w[] = {15};
    int v[] = {10};
    KnapsackResult* r = knapsack_solve(w, v, 1, 10);
    if (!r) return false;
    int expected[] = {0};
    bool passed = r->max_value == 0 && r->total_weight == 0
        && selected_equals(r->selected, expected, 1);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_07_all_fit(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    KnapsackResult* r = knapsack_solve(w, v, 3, 10);
    if (!r) return false;
    int expected[] = {1, 1, 1};
    bool passed = r->max_value == 60 && r->total_weight == 6
        && selected_equals(r->selected, expected, 3);
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_08_weight_invariant(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    int capacity = 50;
    KnapsackResult* r = knapsack_solve(w, v, 3, capacity);
    if (!r || !r->selected) {
        free_knapsack_result(r);
        return false;
    }
    int sum_w = 0;
    for (int i = 0; i < 3; i++) sum_w += r->selected[i] * w[i];
    bool passed = sum_w <= capacity && sum_w == r->total_weight;
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_09_value_invariant(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    KnapsackResult* r = knapsack_solve(w, v, 3, 50);
    if (!r || !r->selected) {
        free_knapsack_result(r);
        return false;
    }
    int sum_v = 0;
    for (int i = 0; i < 3; i++) sum_v += r->selected[i] * v[i];
    bool passed = sum_v == r->max_value;
    free_knapsack_result(r);
    return passed;
}

bool test_algo_b_10_stress_invariants(void) {
    const int n = 50;
    const int capacity = 100;
    int w[50], v[50];
    for (int i = 0; i < n; i++) {
        w[i] = i + 1;
        v[i] = (i + 1) * 2;
    }
    int expected = reference_dp(w, v, n, capacity);
    if (expected < 0) return false;

    KnapsackResult* r = knapsack_solve(w, v, n, capacity);
    if (!r || !r->selected) {
        free_knapsack_result(r);
        return false;
    }

    int sum_w = 0, sum_v = 0;
    for (int i = 0; i < n; i++) {
        if (r->selected[i] != 0 && r->selected[i] != 1) {
            free_knapsack_result(r);
            return false;
        }
        sum_w += r->selected[i] * w[i];
        sum_v += r->selected[i] * v[i];
    }

    bool passed = (r->max_value == expected)
        && (sum_w <= capacity)
        && (sum_w == r->total_weight)
        && (sum_v == r->max_value);
    free_knapsack_result(r);
    return passed;
}

/* ============================================================================
 * MAIN RUNNER
 * ============================================================================ */

int main(void) {
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
    printf("\n--- Algorithm A: Maximum Value ---\n");
    RUN_TEST(test_algo_a_01_empty, "Test A01 (Empty)");
    RUN_TEST(test_algo_a_02_single_fit, "Test A02 (Single Fit)");
    RUN_TEST(test_algo_a_03_too_heavy, "Test A03 (Too Heavy)");
    RUN_TEST(test_algo_a_04_cap_zero, "Test A04 (Capacity Zero)");
    RUN_TEST(test_algo_a_05_choose_better, "Test A05 (Choose Better)");
    RUN_TEST(test_algo_a_06_textbook, "Test A06 (Textbook)");
    RUN_TEST(test_algo_a_07_greedy_trap, "Test A07 (Greedy Trap)");
    RUN_TEST(test_algo_a_08_same_items, "Test A08 (Same Items)");
    RUN_TEST(test_algo_a_09_tight_fit, "Test A09 (Tight Fit)");
    RUN_TEST(test_algo_a_10_stress, "Test A10 (Stress 50 Items)");

    printf("\n--- Algorithm B: Item Selection ---\n");
    RUN_TEST(test_algo_b_01_single_selection, "Test B01 (Single Selection)");
    RUN_TEST(test_algo_b_02_choose_better_selection, "Test B02 (Choose Better Selection)");
    RUN_TEST(test_algo_b_03_textbook_selection, "Test B03 (Textbook Selection)");
    RUN_TEST(test_algo_b_04_greedy_trap_selection, "Test B04 (Greedy Trap Selection)");
    RUN_TEST(test_algo_b_05_cap_zero_selection, "Test B05 (Capacity Zero Selection)");
    RUN_TEST(test_algo_b_06_too_heavy_selection, "Test B06 (Too Heavy Selection)");
    RUN_TEST(test_algo_b_07_all_fit, "Test B07 (All Fit)");
    RUN_TEST(test_algo_b_08_weight_invariant, "Test B08 (Weight Invariant)");
    RUN_TEST(test_algo_b_09_value_invariant, "Test B09 (Value Invariant)");
    RUN_TEST(test_algo_b_10_stress_invariants, "Test B10 (Stress Invariants)");

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
