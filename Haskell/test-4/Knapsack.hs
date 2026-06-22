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
