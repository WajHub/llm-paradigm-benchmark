module Knapsack
  ( Result (..)
  , maxValue
  , solve
  ) where

import Data.Array

data Result = Result
  { resultMaxValue    :: Int
  , resultSelected    :: [Int]
  , resultTotalWeight :: Int
  } deriving (Eq, Show)

-- | DP table: row i holds best values for capacities 0..cap
-- using only the first i items.
buildTable :: [(Int, Int)] -> Int -> [Array Int Int]
buildTable items cap = scanl step base items
  where
    base = listArray (0, cap) (replicate (cap + 1) 0)
    step prev (w, v)
      | w < 0 = prev
      | otherwise = listArray (0, cap)
          [ if w <= c then max (prev ! c) (prev ! (c - w) + v) else prev ! c
          | c <- [0 .. cap]
          ]

maxValue :: [Int] -> [Int] -> Int -> Int
maxValue [] _ _ = 0
maxValue _ _ cap | cap <= 0 = 0
maxValue weights values cap =
  let n = length weights
      vs = take n (values ++ repeat 0)
      items = zip weights vs
      rows = buildTable items cap
  in last rows ! cap

solve :: [Int] -> [Int] -> Int -> Result
solve weights values cap
  | null weights || cap <= 0 =
      Result 0 (replicate n 0) 0
  | otherwise =
      Result best flags totalW
  where
    n = length weights
    vs = take n (values ++ repeat 0)
    items = zip weights vs
    rows = buildTable items cap
    tbl = listArray (0, n) rows :: Array Int (Array Int Int)
    itemArr = listArray (1, n) items :: Array Int (Int, Int)
    best = (tbl ! n) ! cap

    -- Backtrack from the last item to the first, consing flags so the
    -- final list is in ascending item order.
    go :: Int -> Int -> [Int] -> [Int]
    go i c acc
      | i == 0 = acc
      | otherwise =
          let (w, _) = itemArr ! i
              took = (tbl ! i) ! c /= (tbl ! (i - 1)) ! c
              c' = if took then c - w else c
          in go (i - 1) c' ((if took then 1 else 0) : acc)

    flags = go n cap []
    totalW = sum [w | (w, f) <- zip weights flags, f == 1]
</br>
