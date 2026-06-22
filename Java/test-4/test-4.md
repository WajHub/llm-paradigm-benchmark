# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValue`: return the maximum total value attainable by choosing a subset of items whose summed weight is at most `capacity`. Solve with classic 0/1 knapsack dynamic programming in O(n * capacity).
- Implement `solve`: return a `Knapsack.Result` containing `maxValue`, a `selected` array of length `n` whose entries are `0` or `1` (1 = item taken, 0 = item left), and `totalWeight` = sum of weights of selected items.
- `weights[i]` and `values[i]` describe the i-th item; `weights.length == values.length == n`.
- Edge cases:
  * If `weights.length == 0`, `maxValue` must return `0` and `solve` must return `new Result(0, new int[0], 0)`.
  * If `capacity <= 0`, `maxValue` must return `0` and `solve` must return `new Result(0, new int[n], 0)`.
- Each item may be taken at most once (0/1 knapsack); greedy/value-density heuristics are not acceptable, e.g. `weights = {10, 20, 30}`, `values = {60, 100, 120}`, `capacity = 50` must return `220` (taking items 2 and 3), not `160`.
- Selection invariants for the returned `Result`:
  * `sum(selected[i] * weights[i]) <= capacity`
  * `sum(selected[i] * values[i]) == maxValue`
- Use object-oriented Java and model the domain with classes.
- Keep the contract in `Knapsack.java`; the concrete solution lives in `KnapsackImpl.java`.
- Return only raw Java code.
```
