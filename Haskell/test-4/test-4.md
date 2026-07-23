# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValue weights values capacity`: Return the maximum value attainable with sum of selected weights ≤ capacity. Use DP. Return 0 if null weights or capacity <= 0.
- Implement `solve weights values capacity`: Return Result with resultMaxValue, resultSelected (length n, entries 0/1), resultTotalWeight.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220, greedy=160).
- Selection invariants: sum of selected weights ≤ capacity; sum of selected values = maxValue.
- Use idiomatic Haskell (immutable lists / arrays).
```
