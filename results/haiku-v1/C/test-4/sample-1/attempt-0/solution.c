#include <stdlib.h>
#include "knapsack.h"

int knapsack_max_value(const int* weights, const int* values, int n, int capacity) {
    if (weights == NULL || values == NULL || n <= 0 || capacity <= 0) {
        return 0;
    }

    int* dp = (int*)calloc((size_t)capacity + 1, sizeof(int));
    if (dp == NULL) {
        return 0;
    }

    for (int i = 0; i < n; i++) {
        int w = weights[i];
        int v = values[i];
        if (w < 0) {
            continue;
        }
        for (int c = capacity; c >= w; c--) {
            int cand = dp[c - w] + v;
            if (cand > dp[c]) {
                dp[c] = cand;
            }
        }
    }

    int best = dp[capacity];
    free(dp);
    return best;
}

KnapsackResult* knapsack_solve(const int* weights, const int* values, int n, int capacity) {
    if (weights == NULL || values == NULL || n <= 0) {
        return NULL;
    }

    KnapsackResult* result = (KnapsackResult*)malloc(sizeof(KnapsackResult));
    if (result == NULL) {
        return NULL;
    }

    result->n = n;
    result->max_value = 0;
    result->total_weight = 0;
    result->selected = (int*)calloc((size_t)n, sizeof(int));
    if (result->selected == NULL) {
        free(result);
        return NULL;
    }

    if (capacity <= 0) {
        return result;
    }

    size_t cols = (size_t)capacity + 1;
    size_t rows = (size_t)n + 1;
    int* dp = (int*)calloc(rows * cols, sizeof(int));
    if (dp == NULL) {
        free(result->selected);
        free(result);
        return NULL;
    }

    /* dp[i][c]: best value using first i items with capacity c */
    for (int i = 1; i <= n; i++) {
        int w = weights[i - 1];
        int v = values[i - 1];
        for (int c = 0; c <= capacity; c++) {
            int best = dp[(size_t)(i - 1) * cols + c];
            if (w >= 0 && w <= c) {
                int cand = dp[(size_t)(i - 1) * cols + (c - w)] + v;
                if (cand > best) {
                    best = cand;
                }
            }
            dp[(size_t)i * cols + c] = best;
        }
    }

    result->max_value = dp[(size_t)n * cols + capacity];

    /* Reconstruct selection */
    int c = capacity;
    for (int i = n; i >= 1; i--) {
        if (dp[(size_t)i * cols + c] != dp[(size_t)(i - 1) * cols + c]) {
            result->selected[i - 1] = 1;
            result->total_weight += weights[i - 1];
            c -= weights[i - 1];
        }
    }

    free(dp);
    return result;
}

void free_knapsack_result(KnapsackResult* result) {
    if (result == NULL) {
        return;
    }
    free(result->selected);
    free(result);
}
