module Sudoku
  ( isValid
  , candidates
  , solve
  , countSolutions
  ) where

isValid :: [Int] -> Bool
isValid _ = error "Sudoku.isValid not implemented"

candidates :: [Int] -> Int -> Int -> [Int]
candidates _ _ _ = error "Sudoku.candidates not implemented"

solve :: [Int] -> Maybe [Int]
solve _ = error "Sudoku.solve not implemented"

countSolutions :: [Int] -> Int -> Int
countSolutions _ _ = error "Sudoku.countSolutions not implemented"
