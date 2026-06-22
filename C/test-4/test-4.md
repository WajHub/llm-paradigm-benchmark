# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `knapsack_max_value`: Solve the 0/1 knapsack problem and return the maximum value attainable within the given capacity. Use dynamic programming (O(n * capacity) time and space).
  * Return 0 if n == 0 or capacity == 0 or capacity < 0.
  * Each item may be selected at most once.
- Implement `knapsack_solve`: Solve the 0/1 knapsack problem and return a KnapsackResult containing the max value, a 0/1 selection array of length n, and the total weight of the selected items.
  * Return NULL if n == 0 (no items to allocate). Return a valid result with all selected[i]=0 if capacity == 0.
  * The returned `selected` array must be a fresh heap allocation owned by the caller.
- Implement `free_knapsack_result`: Free the result and its inner `selected` array. Must handle NULL.
- DO NOT use greedy heuristics — they fail on cases like w=[10,20,30], v=[60,100,120], cap=50 (optimum = 220, greedy by ratio = 160).
- Selection must satisfy: sum of selected weights <= capacity; sum of selected values = max_value.
```
