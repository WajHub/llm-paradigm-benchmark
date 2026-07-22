# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValueOf: weights values: values capacity: capacity`: Return max attainable value via DP. Return 0 if empty or capacity <= 0.
- Implement `solveWeights: weights values: values capacity: capacity`: Return KnapsackResult with maxValue, selected (Array/OrderedCollection of 0/1 length n), totalWeight.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum(selected_i * weights_i) <= capacity; sum(selected_i * values_i) = maxValue.
- Put the solution in KnapsackImpl.st. Idiomatic GNU Smalltalk.
```
