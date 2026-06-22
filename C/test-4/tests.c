#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "knapsack.h"

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

static int reference_max_value(const int* weights, const int* values, int n, int capacity) {
    if (n <= 0 || capacity <= 0) return 0;

    int* dp = (int*)calloc((size_t)(capacity + 1), sizeof(int));
    if (!dp) return -1;

    for (int i = 0; i < n; i++) {
        int w = weights[i];
        int v = values[i];
        for (int c = capacity; c >= w; c--) {
            int candidate = dp[c - w] + v;
            if (candidate > dp[c]) dp[c] = candidate;
        }
    }

    int answer = dp[capacity];
    free(dp);
    return answer;
}

static bool selection_equals(const int* selected, int n, const int* expected) {
    if (!selected || !expected) return false;
    for (int i = 0; i < n; i++) {
        if (selected[i] != expected[i]) return false;
    }
    return true;
}

static int sum_selected_weights(const int* selected, const int* weights, int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        if (selected[i]) total += weights[i];
    }
    return total;
}

static int sum_selected_values(const int* selected, const int* values, int n) {
    int total = 0;
    for (int i = 0; i < n; i++) {
        if (selected[i]) total += values[i];
    }
    return total;
}

// ============================================================================
// ALGORITHM A: Max Value
// ============================================================================

static bool test_algo_a_01_empty(void) {
    int v = knapsack_max_value(NULL, NULL, 0, 10);
    return v == 0;
}

static bool test_algo_a_02_single_fits(void) {
    int w[] = {5};
    int v[] = {10};
    return knapsack_max_value(w, v, 1, 10) == 10;
}

static bool test_algo_a_03_single_too_heavy(void) {
    int w[] = {15};
    int v[] = {10};
    return knapsack_max_value(w, v, 1, 10) == 0;
}

static bool test_algo_a_04_zero_capacity(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    return knapsack_max_value(w, v, 3, 0) == 0;
}

static bool test_algo_a_05_choose_one(void) {
    int w[] = {5, 6};
    int v[] = {10, 11};
    return knapsack_max_value(w, v, 2, 10) == 11;
}

static bool test_algo_a_06_combine_two(void) {
    int w[] = {2, 3, 4, 5};
    int v[] = {3, 4, 5, 6};
    return knapsack_max_value(w, v, 4, 5) == 7;
}

static bool test_algo_a_07_greedy_trap(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    return knapsack_max_value(w, v, 3, 50) == 220;
}

static bool test_algo_a_08_duplicates(void) {
    int w[] = {3, 3, 3, 3};
    int v[] = {5, 5, 5, 5};
    return knapsack_max_value(w, v, 4, 10) == 15;
}

static bool test_algo_a_09_pick_two(void) {
    int w[] = {3, 4, 5, 6};
    int v[] = {2, 3, 4, 5};
    return knapsack_max_value(w, v, 4, 10) == 8;
}

static bool test_algo_a_10_stress(void) {
    const int n = 50;
    const int capacity = 100;
    int w[50];
    int v[50];
    for (int i = 0; i < n; i++) {
        w[i] = i + 1;
        v[i] = (i + 1) * 2;
    }

    int expected = reference_max_value(w, v, n, capacity);
    int got = knapsack_max_value(w, v, n, capacity);
    return got == expected;
}

// ============================================================================
// ALGORITHM B: Item Selection
// ============================================================================

static bool test_algo_b_01_single_fits(void) {
    int w[] = {5};
    int v[] = {10};
    KnapsackResult* r = knapsack_solve(w, v, 1, 10);
    if (!r) return false;

    int expected[] = {1};
    bool passed = (r->n == 1)
        && selection_equals(r->selected, 1, expected)
        && r->total_weight == 5
        && r->max_value == 10;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_02_choose_heavier(void) {
    int w[] = {5, 6};
    int v[] = {10, 11};
    KnapsackResult* r = knapsack_solve(w, v, 2, 10);
    if (!r) return false;

    int expected[] = {0, 1};
    bool passed = (r->n == 2)
        && selection_equals(r->selected, 2, expected)
        && r->total_weight == 6
        && r->max_value == 11;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_03_combine_two(void) {
    int w[] = {2, 3, 4, 5};
    int v[] = {3, 4, 5, 6};
    KnapsackResult* r = knapsack_solve(w, v, 4, 5);
    if (!r) return false;

    int expected[] = {1, 1, 0, 0};
    bool passed = (r->n == 4)
        && selection_equals(r->selected, 4, expected)
        && r->total_weight == 5
        && r->max_value == 7;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_04_greedy_trap(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    KnapsackResult* r = knapsack_solve(w, v, 3, 50);
    if (!r) return false;

    int expected[] = {0, 1, 1};
    bool passed = (r->n == 3)
        && selection_equals(r->selected, 3, expected)
        && r->total_weight == 50
        && r->max_value == 220;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_05_zero_capacity(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    KnapsackResult* r = knapsack_solve(w, v, 3, 0);
    if (!r) return false;

    bool passed = (r->n == 3) && (r->total_weight == 0) && (r->max_value == 0);
    if (passed) {
        for (int i = 0; i < 3; i++) {
            if (r->selected[i] != 0) {
                passed = false;
                break;
            }
        }
    }

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_06_too_heavy(void) {
    int w[] = {15};
    int v[] = {10};
    KnapsackResult* r = knapsack_solve(w, v, 1, 10);
    if (!r) return false;

    bool passed = (r->n == 1)
        && r->selected[0] == 0
        && r->total_weight == 0
        && r->max_value == 0;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_07_select_all(void) {
    int w[] = {1, 2, 3};
    int v[] = {10, 20, 30};
    KnapsackResult* r = knapsack_solve(w, v, 3, 10);
    if (!r) return false;

    int expected[] = {1, 1, 1};
    bool passed = (r->n == 3)
        && selection_equals(r->selected, 3, expected)
        && r->total_weight == 6
        && r->max_value == 60;

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_08_weight_invariant(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    const int capacity = 50;
    KnapsackResult* r = knapsack_solve(w, v, 3, capacity);
    if (!r) return false;

    int total = sum_selected_weights(r->selected, w, 3);
    bool passed = (total <= capacity);

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_09_value_invariant(void) {
    int w[] = {10, 20, 30};
    int v[] = {60, 100, 120};
    KnapsackResult* r = knapsack_solve(w, v, 3, 50);
    if (!r) return false;

    int total = sum_selected_values(r->selected, v, 3);
    bool passed = (total == r->max_value);

    free_knapsack_result(r);
    return passed;
}

static bool test_algo_b_10_stress(void) {
    const int n = 50;
    const int capacity = 100;
    int w[50];
    int v[50];
    for (int i = 0; i < n; i++) {
        w[i] = i + 1;
        v[i] = (i + 1) * 2;
    }

    int expected_value = reference_max_value(w, v, n, capacity);
    if (expected_value < 0) return false;

    KnapsackResult* r = knapsack_solve(w, v, n, capacity);
    if (!r) return false;

    int sel_weight = sum_selected_weights(r->selected, w, n);
    int sel_value = sum_selected_values(r->selected, v, n);

    bool passed = (r->n == n)
        && (sel_weight <= capacity)
        && (r->total_weight == sel_weight)
        && (sel_value == r->max_value)
        && (r->max_value == expected_value);

    free_knapsack_result(r);
    return passed;
}

// ============================================================================
// MAIN RUNNER
// ============================================================================

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
    printf("\n--- Algorithm A: Max Value ---\n");
    RUN_TEST(test_algo_a_01_empty, "Test A01 (Empty)");
    RUN_TEST(test_algo_a_02_single_fits, "Test A02 (Single Fits)");
    RUN_TEST(test_algo_a_03_single_too_heavy, "Test A03 (Single Too Heavy)");
    RUN_TEST(test_algo_a_04_zero_capacity, "Test A04 (Zero Capacity)");
    RUN_TEST(test_algo_a_05_choose_one, "Test A05 (Choose One)");
    RUN_TEST(test_algo_a_06_combine_two, "Test A06 (Combine Two)");
    RUN_TEST(test_algo_a_07_greedy_trap, "Test A07 (Greedy Trap)");
    RUN_TEST(test_algo_a_08_duplicates, "Test A08 (Duplicates)");
    RUN_TEST(test_algo_a_09_pick_two, "Test A09 (Pick Two)");
    RUN_TEST(test_algo_a_10_stress, "Test A10 (Stress n=50)");

    printf("\n--- Algorithm B: Item Selection ---\n");
    RUN_TEST(test_algo_b_01_single_fits, "Test B01 (Single Fits)");
    RUN_TEST(test_algo_b_02_choose_heavier, "Test B02 (Choose Heavier)");
    RUN_TEST(test_algo_b_03_combine_two, "Test B03 (Combine Two)");
    RUN_TEST(test_algo_b_04_greedy_trap, "Test B04 (Greedy Trap)");
    RUN_TEST(test_algo_b_05_zero_capacity, "Test B05 (Zero Capacity)");
    RUN_TEST(test_algo_b_06_too_heavy, "Test B06 (Too Heavy)");
    RUN_TEST(test_algo_b_07_select_all, "Test B07 (Select All)");
    RUN_TEST(test_algo_b_08_weight_invariant, "Test B08 (Weight Invariant)");
    RUN_TEST(test_algo_b_09_value_invariant, "Test B09 (Value Invariant)");
    RUN_TEST(test_algo_b_10_stress, "Test B10 (Stress Invariants)");

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
