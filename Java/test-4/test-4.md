# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValue`: Solve the 0/1 knapsack problem and return the maximum value attainable within the given capacity. Use dynamic programming (O(n * capacity)).
  * Return 0 if weights.length == 0 or capacity <= 0.
  * Each item may be selected at most once.
- Implement `solve`: Return a Result containing maxValue, a 0/1 selected array of length n, and totalWeight of selected items.
  * If n == 0 return Result(0, new int[0], 0). If capacity <= 0 return Result(0, new int[n], 0).
- DO NOT use greedy heuristics — they fail on cases like w=[10,20,30], v=[60,100,120], cap=50 (optimum = 220, greedy by ratio = 160).
- Selection must satisfy: sum(selected[i]*weights[i]) <= capacity; sum(selected[i]*values[i]) == maxValue.
- Keep the contract in Knapsack.java; put the solution in KnapsackImpl.java.
```
