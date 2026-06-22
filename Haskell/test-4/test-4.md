# Test 4

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `maxValue :: [Int] -> [Int] -> Int -> Int`: Given lists of item `weights` and `values` (same length) and a knapsack `capacity`, return the maximum attainable total value such that the sum of selected weights is `<= capacity`. Each item may be taken at most once (0/1 knapsack). Use dynamic programming. Return `0` if `null weights || capacity <= 0`.
- Implement `solve :: [Int] -> [Int] -> Int -> Result`: Return a `Result` with:
  * `resultMaxValue`: the same value `maxValue` would return.
  * `resultSelected`: a list of length `n = length weights` whose entries are `0` or `1`, marking each item as not-taken / taken.
  * `resultTotalWeight`: the sum of weights of the selected items.
- Selection invariants: `sum (selected `zipWith (*)` weights) <= capacity` and `sum (selected `zipWith (*)` values) == resultMaxValue`.
- Do not use greedy heuristics; the answer must be optimal.
- Use idiomatic Haskell (immutable lists or `Data.Array` / `Data.IntMap` for the DP table). Prefer pure functions and avoid mutable state where possible.
```
