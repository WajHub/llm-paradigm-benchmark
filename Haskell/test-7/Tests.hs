module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import Data.List (group)
import System.Exit (ExitCode (..), exitWith)
import SequenceAlignment

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
-- Helpers
-- ===========================================================================

-- Score of an alignment by definition: column scores plus one penalty
-- gapOpen + L * gapExtend per maximal run of '-' in each row.
scoreOf :: String -> String -> Int -> Int -> Int -> Int -> Int
scoreOf sa sb m x o e = columns + gaps sa + gaps sb
  where
    columns = sum [ if ca == cb then m else negate x
                  | (ca, cb) <- zip sa sb, ca /= '-', cb /= '-' ]
    gaps row = negate (sum [ o + length run * e | run <- group row, head run == '-' ])

-- All invariants of an alignment result, plus the exact rows when given.
validAlignment
  :: String -> String -> Int -> Int -> Int -> Int
  -> Int -> Maybe (String, String) -> Bool
validAlignment a b m x o e expected exact =
  let r = alignmentAlign a b m x o e
      sa = arAlignedA r
      sb = arAlignedB r
  in arScore r == expected
     && length sa == length sb
     && filter (/= '-') sa == a
     && filter (/= '-') sb == b
     && not (any (\(ca, cb) -> ca == '-' && cb == '-') (zip sa sb))
     && scoreOf sa sb m x o e == expected
     && maybe True (== (sa, sb)) exact

stressA :: String
stressA =
  "CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA"

stressB :: String
stressB =
  "GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC"

-- ===========================================================================
-- Algorithm A: Alignment Score
-- ===========================================================================

testAlgoA01BothEmpty :: Bool
testAlgoA01BothEmpty = alignmentScore "" "" 1 1 2 1 == 0

testAlgoA02OneEmpty :: Bool
testAlgoA02OneEmpty = alignmentScore "" "ACG" 1 1 2 1 == -5

testAlgoA03Identical :: Bool
testAlgoA03Identical = alignmentScore "GATTACA" "GATTACA" 2 1 3 1 == 14

testAlgoA04MismatchBeatsGaps :: Bool
testAlgoA04MismatchBeatsGaps = alignmentScore "A" "C" 1 1 2 1 == -1

testAlgoA05Textbook :: Bool
testAlgoA05Textbook = alignmentScore "GATTACA" "GCATGCU" 1 1 1 1 == -1

testAlgoA06OneLongGap :: Bool
testAlgoA06OneLongGap = alignmentScore "AAAGGGTTT" "AAATTT" 2 2 5 1 == 4

testAlgoA07ZeroExtend :: Bool
testAlgoA07ZeroExtend = alignmentScore "TTACGGA" "ACG" 2 2 2 0 == 2

testAlgoA08AdjacentGapsBeatMismatch :: Bool
testAlgoA08AdjacentGapsBeatMismatch = alignmentScore "XAY" "XCY" 1 10 1 1 == -2

testAlgoA09TerminalGapsPenalized :: Bool
testAlgoA09TerminalGapsPenalized = alignmentScore "AAAACCCC" "CCCC" 2 1 3 1 == 1

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  length stressA == 120
    && length stressB == 110
    && alignmentScore stressA stressB 2 1 3 1 == 16

-- ===========================================================================
-- Algorithm B: Alignment Reconstruction
-- ===========================================================================

testAlgoB01BothEmpty :: Bool
testAlgoB01BothEmpty = validAlignment "" "" 1 1 2 1 0 (Just ("", ""))

testAlgoB02SecondEmpty :: Bool
testAlgoB02SecondEmpty = validAlignment "ACG" "" 1 1 2 1 (-5) (Just ("ACG", "---"))

testAlgoB03Identical :: Bool
testAlgoB03Identical =
  validAlignment "GATTACA" "GATTACA" 2 1 3 1 14 (Just ("GATTACA", "GATTACA"))

testAlgoB04UniqueLongGap :: Bool
testAlgoB04UniqueLongGap =
  validAlignment "AAAGGGTTT" "AAATTT" 2 2 5 1 4 (Just ("AAAGGGTTT", "AAA---TTT"))

testAlgoB05AdjacentGaps :: Bool
testAlgoB05AdjacentGaps = validAlignment "XAY" "XCY" 1 10 1 1 (-2) Nothing

testAlgoB06TextbookUnique :: Bool
testAlgoB06TextbookUnique =
  validAlignment "GATTACA" "GCATGCU" 1 1 1 1 (-1) (Just ("GATTACA", "GCATGCU"))

testAlgoB07GapMerging :: Bool
testAlgoB07GapMerging =
  validAlignment "ACCCGT" "AGT" 2 3 6 1 (-3) (Just ("ACCCGT", "A---GT"))

testAlgoB08GapsInBothRows :: Bool
testAlgoB08GapsInBothRows =
  validAlignment "CACGCA" "AGGCGC" 3 2 3 1 (-1) (Just ("CA--CGCA", "-AGGCGC-"))

testAlgoB09TiedGapPositions :: Bool
testAlgoB09TiedGapPositions = validAlignment "AAAA" "AA" 1 1 1 1 (-1) Nothing

testAlgoB10StressInvariants :: Bool
testAlgoB10StressInvariants = validAlignment stressA stressB 3 2 5 1 10 Nothing

tests :: [TestCase]
tests =
  [ ("Test A01 (Both Empty)", testAlgoA01BothEmpty)
  , ("Test A02 (One Empty)", testAlgoA02OneEmpty)
  , ("Test A03 (Identical)", testAlgoA03Identical)
  , ("Test A04 (Mismatch Beats Gaps)", testAlgoA04MismatchBeatsGaps)
  , ("Test A05 (Textbook)", testAlgoA05Textbook)
  , ("Test A06 (One Long Gap)", testAlgoA06OneLongGap)
  , ("Test A07 (Zero Extend)", testAlgoA07ZeroExtend)
  , ("Test A08 (Adjacent Gaps Beat Mismatch)", testAlgoA08AdjacentGapsBeatMismatch)
  , ("Test A09 (Terminal Gaps Penalized)", testAlgoA09TerminalGapsPenalized)
  , ("Test A10 (Stress)", testAlgoA10Stress)
  , ("Test B01 (Both Empty)", testAlgoB01BothEmpty)
  , ("Test B02 (Second Empty)", testAlgoB02SecondEmpty)
  , ("Test B03 (Identical)", testAlgoB03Identical)
  , ("Test B04 (Unique Long Gap)", testAlgoB04UniqueLongGap)
  , ("Test B05 (Adjacent Gaps)", testAlgoB05AdjacentGaps)
  , ("Test B06 (Textbook Unique)", testAlgoB06TextbookUnique)
  , ("Test B07 (Gap Merging)", testAlgoB07GapMerging)
  , ("Test B08 (Gaps In Both Rows)", testAlgoB08GapsInBothRows)
  , ("Test B09 (Tied Gap Positions)", testAlgoB09TiedGapPositions)
  , ("Test B10 (Stress Invariants)", testAlgoB10StressInvariants)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Alignment Score ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Alignment Reconstruction ---"
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
