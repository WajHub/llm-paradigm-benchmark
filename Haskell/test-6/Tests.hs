module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import Data.Char (digitToInt)
import Data.Maybe (isNothing)
import System.Exit (ExitCode (..), exitWith)
import Sudoku

type TestCase = (String, Bool)

check :: String -> Bool -> IO Bool
check name passed = do
  result <- try (evaluate passed) :: IO (Either SomeException Bool)
  case result of
    Right True -> do
      putStrLn $ "[PASS] " ++ name
      pure True
    Right False -> do
      putStrLn $ "[FAIL] " ++ name
      pure False
    Left _ -> do
      putStrLn $ "[FAIL] " ++ name
      pure False

-- ===========================================================================
-- Grid helpers (row-major, index = row * 9 + col, 0 = empty)
-- ===========================================================================

parseGrid :: String -> [Int]
parseGrid = map toCell . filter (`notElem` " \n")
  where
    toCell '.' = 0
    toCell ch  = digitToInt ch

setCell :: [Int] -> Int -> Int -> Int -> [Int]
setCell grid r c v =
  [ if i == r * 9 + c then v else x | (i, x) <- zip [0 :: Int ..] grid ]

emptyGrid :: [Int]
emptyGrid = replicate 81 0

classicStr :: String
classicStr =
  "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079"

classic :: [Int]
classic = parseGrid classicStr

solved :: [Int]
solved = parseGrid
  "534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179"

inkala :: [Int]
inkala = parseGrid
  "800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402"

inkalaSol :: [Int]
inkalaSol = parseGrid
  "812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452"

antiBf :: [Int]
antiBf = parseGrid
  "000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009"

antiBfSol :: [Int]
antiBfSol = parseGrid
  "987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219"

-- CLASSIC with (1,1)=8: clashes only with (2,2)=8 in box 0.
boxConflict :: [Int]
boxConflict = setCell classic 1 1 8

boxConflict2 :: [Int]
boxConflict2 = setCell (setCell emptyGrid 0 0 1) 1 1 1

rowConflict :: [Int]
rowConflict = setCell classic 0 8 5

colConflict :: [Int]
colConflict = setCell classic 8 0 5

-- Valid, but (0,8) has no candidate.
deadCell :: [Int]
deadCell = setCell ([1 .. 8] ++ [0] ++ drop 9 emptyGrid) 4 8 9

-- Valid, every empty cell has a candidate, but no solution.
hidden :: [Int]
hidden = setCell classic 0 2 1

-- Exactly 8 solutions.
multi :: [Int]
multi = setCell classic 2 2 0

-- ===========================================================================
-- Algorithm A: Validation and Candidates
-- ===========================================================================

testAlgoA01EmptyGridValid :: Bool
testAlgoA01EmptyGridValid = isValid emptyGrid

testAlgoA02SolvedGridValid :: Bool
testAlgoA02SolvedGridValid = isValid solved && isValid classic

testAlgoA03RowConflict :: Bool
testAlgoA03RowConflict = not (isValid rowConflict) && isValid classic

testAlgoA04ColumnConflict :: Bool
testAlgoA04ColumnConflict = not (isValid colConflict) && isValid classic

testAlgoA05BoxOnlyConflict :: Bool
testAlgoA05BoxOnlyConflict =
  not (isValid boxConflict) && not (isValid boxConflict2) && isValid classic

testAlgoA06WrongLength :: Bool
testAlgoA06WrongLength =
  not (isValid (replicate 80 0))
    && not (isValid (replicate 82 0))
    && not (isValid (solved ++ [0]))
    && isValid solved

testAlgoA07ValueOutOfRange :: Bool
testAlgoA07ValueOutOfRange =
  not (isValid (setCell classic 0 2 10))
    && not (isValid (setCell classic 0 2 (-1)))
    && isValid classic

testAlgoA08CandidatesBasic :: Bool
testAlgoA08CandidatesBasic =
  candidates classic 0 2 == [1, 2, 4]
    && candidates classic 4 4 == [5]
    && candidates classic 8 0 == [1, 2, 3]

testAlgoA09CandidatesEdgeCells :: Bool
testAlgoA09CandidatesEdgeCells =
  null (candidates classic 0 0)
    && null (candidates classic 8 8)
    && candidates emptyGrid 8 8 == [1 .. 9]

testAlgoA10CandidatesSweep :: Bool
testAlgoA10CandidatesSweep =
  and [ candidates (setCell solved r c 0) r c == [solved !! (r * 9 + c)]
      | r <- [0 .. 8], c <- [0 .. 8] ]
    && sum [ length (candidates classic r c) | r <- [0 .. 8], c <- [0 .. 8] ] == 153

-- ===========================================================================
-- Algorithm B: Solving
-- ===========================================================================

testAlgoB01AlreadySolved :: Bool
testAlgoB01AlreadySolved = solve solved == Just solved

testAlgoB02ClassicPuzzle :: Bool
testAlgoB02ClassicPuzzle =
  solve classic == Just solved && classic == parseGrid classicStr

testAlgoB03InvalidGrid :: Bool
testAlgoB03InvalidGrid =
  isNothing (solve boxConflict)
    && isNothing (solve (replicate 80 0))
    && isNothing (solve (setCell classic 0 2 10))
    && countSolutions boxConflict 5 == 0
    && countSolutions (replicate 80 0) 5 == 0

testAlgoB04DeadCell :: Bool
testAlgoB04DeadCell = isNothing (solve deadCell) && countSolutions deadCell 5 == 0

testAlgoB05HiddenContradiction :: Bool
testAlgoB05HiddenContradiction = isNothing (solve hidden) && countSolutions hidden 5 == 0

testAlgoB06BacktrackingRequired :: Bool
testAlgoB06BacktrackingRequired = solve inkala == Just inkalaSol

testAlgoB07CountUnique :: Bool
testAlgoB07CountUnique = countSolutions classic 2 == 1 && countSolutions solved 2 == 1

testAlgoB08CountMultiple :: Bool
testAlgoB08CountMultiple =
  countSolutions multi 100 == 8
    && countSolutions multi 5 == 5
    && countSolutions multi 1 == 1

testAlgoB09CountEmptyGridLimit :: Bool
testAlgoB09CountEmptyGridLimit =
  countSolutions emptyGrid 2 == 2
    && countSolutions emptyGrid 1 == 1
    && countSolutions emptyGrid 0 == 0
    && countSolutions emptyGrid (-3) == 0

testAlgoB10StressAntiBruteForce :: Bool
testAlgoB10StressAntiBruteForce = solve antiBf == Just antiBfSol

tests :: [TestCase]
tests =
  [ ("Test A01 (Empty Grid Valid)", testAlgoA01EmptyGridValid)
  , ("Test A02 (Solved Grid Valid)", testAlgoA02SolvedGridValid)
  , ("Test A03 (Row Conflict)", testAlgoA03RowConflict)
  , ("Test A04 (Column Conflict)", testAlgoA04ColumnConflict)
  , ("Test A05 (Box Only Conflict)", testAlgoA05BoxOnlyConflict)
  , ("Test A06 (Wrong Length)", testAlgoA06WrongLength)
  , ("Test A07 (Value Out Of Range)", testAlgoA07ValueOutOfRange)
  , ("Test A08 (Candidates Basic)", testAlgoA08CandidatesBasic)
  , ("Test A09 (Candidates Edge Cells)", testAlgoA09CandidatesEdgeCells)
  , ("Test A10 (Candidates Sweep)", testAlgoA10CandidatesSweep)
  , ("Test B01 (Already Solved)", testAlgoB01AlreadySolved)
  , ("Test B02 (Classic Puzzle)", testAlgoB02ClassicPuzzle)
  , ("Test B03 (Invalid Grid)", testAlgoB03InvalidGrid)
  , ("Test B04 (Dead Cell)", testAlgoB04DeadCell)
  , ("Test B05 (Hidden Contradiction)", testAlgoB05HiddenContradiction)
  , ("Test B06 (Backtracking Required)", testAlgoB06BacktrackingRequired)
  , ("Test B07 (Count Unique)", testAlgoB07CountUnique)
  , ("Test B08 (Count Multiple)", testAlgoB08CountMultiple)
  , ("Test B09 (Count Empty Grid Limit)", testAlgoB09CountEmptyGridLimit)
  , ("Test B10 (Stress Anti Brute Force)", testAlgoB10StressAntiBruteForce)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Validation and Candidates ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Solving ---"
  resultsB <- forM (drop 10 tests) (uncurry check)
  let results = resultsA ++ resultsB
      totalTests = length tests
      passedCount = length (filter id results)
      failedCount = totalTests - passedCount
      failedTests = [name | ((name, _), passed) <- zip tests results, not passed]

  putStrLn ""
  putStrLn "=== BENCHMARK RESULTS ==="
  putStrLn $ "Completed " ++ show totalTests ++ " tests."
  putStrLn $ "Passed: " ++ show passedCount
  putStrLn $ "Failed: " ++ show failedCount

  if and results
    then exitWith ExitSuccess
    else do
      putStrLn "Tests that failed:"
      mapM_ (putStrLn . (" - " ++)) failedTests
      exitWith (ExitFailure 1)
