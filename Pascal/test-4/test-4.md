# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `KnapsackMaxValue`: Return the maximum value attainable within capacity using DP. Return 0 if Length(Weights)=0 or Capacity<=0.
- Implement `KnapsackSolve`: Return a PKnapsackResult with MaxValue, Selected (0/1 array of length n), TotalWeight.
  * If n=0 return a result with MaxValue=0, empty Selected, TotalWeight=0 (or nil — tests for n=0 use MaxValue only via KnapsackMaxValue).
  * If Capacity<=0 return Selected all zeros, MaxValue=0, TotalWeight=0.
- Implement `FreeKnapsackResult(var AResult)`: Free the result. Must handle nil. Do NOT name the parameter `Result`.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum of selected weights <= capacity; sum of selected values = MaxValue.
```
