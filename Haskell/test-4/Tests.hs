module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import Data.List (zipWith)
import System.Exit (ExitCode(..), exitWith)
import Knapsack

type TestCase = (String, Bool)

referenceDp :: [Int] -> [Int] -> Int -> Int
referenceDp weights values capacity
  | null weights || capacity <= 0 = 0
  | otherwise =
      let n = length weights
          go i dp
            | i >= n = dp !! capacity
            | otherwise =
                let w = weights !! i
                    v = values !! i
                    dp' = [ if c >= w
                              then max (dp !! c) ((dp !! (c - w)) + v)
                              else dp !! c
                          | c <- [0 .. capacity]
                          ]
                in go (i + 1) dp'
      in go 0 (replicate (capacity + 1) 0)

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

testAlgoA01Empty :: Bool
testAlgoA01Empty = maxValue [] [] 10 == 0

testAlgoA02SingleFit :: Bool
testAlgoA02SingleFit = maxValue [5] [10] 10 == 10

testAlgoA03TooHeavy :: Bool
testAlgoA03TooHeavy = maxValue [15] [10] 10 == 0

testAlgoA04CapZero :: Bool
testAlgoA04CapZero = maxValue [1, 2, 3] [10, 20, 30] 0 == 0

testAlgoA05ChooseBetter :: Bool
testAlgoA05ChooseBetter = maxValue [5, 6] [10, 11] 10 == 11

testAlgoA06Textbook :: Bool
testAlgoA06Textbook = maxValue [2, 3, 4, 5] [3, 4, 5, 6] 5 == 7

testAlgoA07GreedyTrap :: Bool
testAlgoA07GreedyTrap = maxValue [10, 20, 30] [60, 100, 120] 50 == 220

testAlgoA08SameItems :: Bool
testAlgoA08SameItems = maxValue [3, 3, 3, 3] [5, 5, 5, 5] 10 == 15

testAlgoA09TightFit :: Bool
testAlgoA09TightFit = maxValue [3, 4, 5, 6] [2, 3, 4, 5] 10 == 8

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  let weights = [1 .. 50]
      values = map (* 2) [1 .. 50]
      expected = referenceDp weights values 100
  in maxValue weights values 100 == expected

testAlgoB01SingleSelection :: Bool
testAlgoB01SingleSelection =
  let r = solve [5] [10] 10
  in resultMaxValue r == 10
     && resultTotalWeight r == 5
     && resultSelected r == [1]

testAlgoB02ChooseBetterSelection :: Bool
testAlgoB02ChooseBetterSelection =
  let r = solve [5, 6] [10, 11] 10
  in resultMaxValue r == 11
     && resultTotalWeight r == 6
     && resultSelected r == [0, 1]

testAlgoB03TextbookSelection :: Bool
testAlgoB03TextbookSelection =
  let r = solve [2, 3, 4, 5] [3, 4, 5, 6] 5
  in resultMaxValue r == 7
     && resultTotalWeight r == 5
     && resultSelected r == [1, 1, 0, 0]

testAlgoB04GreedyTrapSelection :: Bool
testAlgoB04GreedyTrapSelection =
  let r = solve [10, 20, 30] [60, 100, 120] 50
  in resultMaxValue r == 220
     && resultTotalWeight r == 50
     && resultSelected r == [0, 1, 1]

testAlgoB05CapZeroSelection :: Bool
testAlgoB05CapZeroSelection =
  let r = solve [1, 2, 3] [10, 20, 30] 0
  in resultMaxValue r == 0
     && resultTotalWeight r == 0
     && resultSelected r == [0, 0, 0]

testAlgoB06TooHeavySelection :: Bool
testAlgoB06TooHeavySelection =
  let r = solve [15] [10] 10
  in resultMaxValue r == 0
     && resultTotalWeight r == 0
     && resultSelected r == [0]

testAlgoB07AllFit :: Bool
testAlgoB07AllFit =
  let r = solve [1, 2, 3] [10, 20, 30] 10
  in resultMaxValue r == 60
     && resultTotalWeight r == 6
     && resultSelected r == [1, 1, 1]

testAlgoB08WeightInvariant :: Bool
testAlgoB08WeightInvariant =
  let weights = [10, 20, 30]
      values = [60, 100, 120]
      capacity = 50
      r = solve weights values capacity
      sumW = sum (zipWith (*) (resultSelected r) weights)
  in sumW <= capacity && sumW == resultTotalWeight r

testAlgoB09ValueInvariant :: Bool
testAlgoB09ValueInvariant =
  let weights = [10, 20, 30]
      values = [60, 100, 120]
      r = solve weights values 50
      sumV = sum (zipWith (*) (resultSelected r) values)
  in sumV == resultMaxValue r

testAlgoB10StressInvariants :: Bool
testAlgoB10StressInvariants =
  let weights = [1 .. 50]
      values = map (* 2) [1 .. 50]
      capacity = 100
      expected = referenceDp weights values capacity
      r = solve weights values capacity
      sel = resultSelected r
      sumW = sum (zipWith (*) sel weights)
      sumV = sum (zipWith (*) sel values)
  in length sel == 50
     && all (\x -> x == 0 || x == 1) sel
     && resultMaxValue r == expected
     && sumW <= capacity
     && sumW == resultTotalWeight r
     && sumV == resultMaxValue r

tests :: [TestCase]
tests =
  [ ("Test A01 (Empty)", testAlgoA01Empty)
  , ("Test A02 (Single Fit)", testAlgoA02SingleFit)
  , ("Test A03 (Too Heavy)", testAlgoA03TooHeavy)
  , ("Test A04 (Capacity Zero)", testAlgoA04CapZero)
  , ("Test A05 (Choose Better)", testAlgoA05ChooseBetter)
  , ("Test A06 (Textbook)", testAlgoA06Textbook)
  , ("Test A07 (Greedy Trap)", testAlgoA07GreedyTrap)
  , ("Test A08 (Same Items)", testAlgoA08SameItems)
  , ("Test A09 (Tight Fit)", testAlgoA09TightFit)
  , ("Test A10 (Stress 50 Items)", testAlgoA10Stress)
  , ("Test B01 (Single Selection)", testAlgoB01SingleSelection)
  , ("Test B02 (Choose Better Selection)", testAlgoB02ChooseBetterSelection)
  , ("Test B03 (Textbook Selection)", testAlgoB03TextbookSelection)
  , ("Test B04 (Greedy Trap Selection)", testAlgoB04GreedyTrapSelection)
  , ("Test B05 (Capacity Zero Selection)", testAlgoB05CapZeroSelection)
  , ("Test B06 (Too Heavy Selection)", testAlgoB06TooHeavySelection)
  , ("Test B07 (All Fit)", testAlgoB07AllFit)
  , ("Test B08 (Weight Invariant)", testAlgoB08WeightInvariant)
  , ("Test B09 (Value Invariant)", testAlgoB09ValueInvariant)
  , ("Test B10 (Stress Invariants)", testAlgoB10StressInvariants)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Maximum Value ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Item Selection ---"
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
