You are a Haskell programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `maxValue weights values capacity`: Return the maximum value attainable with sum of selected weights ≤ capacity. Use DP. Return 0 if null weights or capacity <= 0.
- Implement `solve weights values capacity`: Return Result with resultMaxValue, resultSelected (length n, entries 0/1), resultTotalWeight.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220, greedy=160).
- Selection invariants: sum of selected weights ≤ capacity; sum of selected values = maxValue.
- Use idiomatic Haskell (immutable lists / arrays).

General Requirements:
- Use idiomatic, pure Haskell.
- Prefer immutable data, algebraic data types, and total functions where practical.
- Model absence with `Maybe` instead of null pointers.
- Return ONLY raw Haskell code (no Markdown tags, no ```haskell blocks, no side text). Your code will be directly saved to a .hs file and compiled.
- Do not provide test runner code.

module Knapsack
  ( Result (..)
  , maxValue
  , solve
  ) where

data Result = Result
  { resultMaxValue    :: Int
  , resultSelected    :: [Int]
  , resultTotalWeight :: Int
  } deriving (Eq, Show)

maxValue :: [Int] -> [Int] -> Int -> Int
maxValue _ _ _ = error "Knapsack.maxValue not implemented"

solve :: [Int] -> [Int] -> Int -> Result
solve _ _ _ = error "Knapsack.solve not implemented"