#ifndef KNAPSACK_H
#define KNAPSACK_H

typedef struct {
    int max_value;
    int* selected;       /* length n; entries 0 or 1 */
    int n;
    int total_weight;
} KnapsackResult;

int knapsack_max_value(const int* weights, const int* values, int n, int capacity);
KnapsackResult* knapsack_solve(const int* weights, const int* values, int n, int capacity);
void free_knapsack_result(KnapsackResult* result);

#endif
