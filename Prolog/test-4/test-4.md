# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `knapsack_max_value(+Weights, +Values, +Capacity, -MaxValue)`: 0/1 knapsack via DP. Return 0 for empty list or Capacity <= 0.
- Implement `knapsack_solve(+Weights, +Values, +Capacity, -Result)`: Result = result(MaxValue, Selected, TotalWeight) where Selected is a list of 0/1 of length n.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum of selected weights <= capacity; sum of selected values = MaxValue.
- Idiomatic SWI-Prolog (memoization or pure recursion with accumulators).
```
