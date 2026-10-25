You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

- Implement `knapsack_max_value`: Solve the 0/1 knapsack problem and return the maximum value attainable within the given capacity. Use dynamic programming (O(n * capacity) time and space).
  * Return 0 if n == 0 or capacity == 0 or capacity < 0.
  * Each item may be selected at most once.
- Implement `knapsack_solve`: Solve the 0/1 knapsack problem and return a KnapsackResult containing the max value, a 0/1 selection array of length n, and the total weight of the selected items.
  * Return NULL if n == 0 (no items to allocate). Return a valid result with all selected[i]=0 if capacity == 0.
  * The returned `selected` array must be a fresh heap allocation owned by the caller.
- Implement `free_knapsack_result`: Free the result and its inner `selected` array. Must handle NULL.
- DO NOT use greedy heuristics — they fail on cases like w=[10,20,30], v=[60,100,120], cap=50 (optimum = 220, greedy by ratio = 160).
- Selection must satisfy: sum of selected weights <= capacity; sum of selected values = max_value.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

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