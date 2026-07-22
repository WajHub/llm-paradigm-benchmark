# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValue`: Return the maximum value attainable with sum of selected weights ≤ capacity. Use DP. Return 0 if weights.isEmpty or capacity <= 0.
- Implement `solve`: Return Result(maxValue, selected, totalWeight) where selected is a Vector[Int] of 0/1 length n.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220, greedy=160).
- Selection invariants: sum(selected.zip(weights).map(p => p._1 * p._2)) ≤ capacity; sum of selected values = maxValue.
- Use idiomatic immutable Scala.
```
