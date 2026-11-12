module Sudoku
  ( isValid
  , candidates
  , solve
  , countSolutions
  ) where

import Data.Array (Array, listArray, elems, (!), (//))
import Data.List (nub, minimumBy)
import Data.Ord (comparing)

-- | All 27 units (9 rows, 9 columns, 9 boxes) as lists of cell indices.
units :: [[Int]]
units =
  [ [r * 9 + c | c <- [0 .. 8]] | r <- [0 .. 8] ]
  ++ [ [r * 9 + c | r <- [0 .. 8]] | c <- [0 .. 8] ]
  ++ [ [(br + i) * 9 + bc + j | i <- [0 .. 2], j <- [0 .. 2]]
     | br <- [0, 3, 6], bc <- [0, 3, 6] ]

-- | For each cell, the indices of all distinct peers (same row, column or box).
peerTable :: Array Int [Int]
peerTable = listArray (0, 80) [peersOf i | i <- [0 .. 80]]
  where
    peersOf i =
      [ j | j <- [0 .. 80], j /= i
          , any (\u -> i `elem` u && j `elem` u) units ]

isValid :: [Int] -> Bool
isValid g =
  length g == 81
    && all (`elem` [0 .. 9]) g
    && all unitOk units
  where
    arr = listArray (0, 80) g :: Array Int Int
    unitOk u =
      let ds = filter (/= 0) [arr ! i | i <- u]
      in length ds == length (nub ds)

candidates :: [Int] -> Int -> Int -> [Int]
candidates grid row col
  | grid !! i /= 0 = []
  | otherwise = [d | d <- [1 .. 9], d `notElem` used]
  where
    i = row * 9 + col
    used = [grid !! j | j <- peerTable ! i]

-- | Candidates for a cell in the array representation.
candA :: Array Int Int -> Int -> [Int]
candA arr i = [d | d <- [1 .. 9], d `notElem` [arr ! j | j <- peerTable ! i]]

-- | Lazily enumerates all complete boards extending the given array,
-- branching on the empty cell with the fewest candidates (MRV).
solutions :: Array Int Int -> [Array Int Int]
solutions arr =
  case [(i, cs) | i <- [0 .. 80], arr ! i == 0, let cs = candA arr i] of
    [] -> [arr]
    open ->
      let (i, cs) = minimumBy (comparing (length . snd)) open
      in concat [solutions (arr // [(i, d)]) | d <- cs]

solve :: [Int] -> Maybe [Int]
solve grid
  | not (isValid grid) = Nothing
  | otherwise =
      case take 1 (solutions (listArray (0, 80) grid)) of
        [a] -> Just (elems a)
        _ -> Nothing

countSolutions :: [Int] -> Int -> Int
countSolutions grid limit
  | limit <= 0 || not (isValid grid) = 0
  | otherwise = length (take limit (solutions (listArray (0, 80) grid)))
