module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import Data.List (sort)
import Data.Maybe (isNothing)
import System.Exit (ExitCode (..), exitWith)
import TspApprox

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

dist :: (Int, Int) -> (Int, Int) -> Int
dist (px, py) (qx, qy) = abs (px - qx) + abs (py - qy)

-- Closed-tour cost recomputed from the points.
recomputeCost :: [(Int, Int)] -> [Int] -> Int
recomputeCost pts tour =
  case map (pts !!) tour of
    ps@(_ : rest@(_ : _)) -> sum (zipWith dist ps (rest ++ take 1 ps))
    _ -> 0

-- Permutation of 0..n-1 starting with 0, cost equals the recomputed cost.
validTour :: [(Int, Int)] -> Maybe TourResult -> Bool
validTour pts (Just (TourResult order cost)) =
  length order == length pts
    && sort order == [0 .. length pts - 1]
    && take 1 order == [0]
    && cost == recomputeCost pts order
validTour _ Nothing = False

-- Valid tour satisfying the given predicate on its cost.
christofidesOk :: [(Int, Int)] -> (Int -> Bool) -> Bool
christofidesOk pts costOk =
  case christofides pts of
    r@(Just tr) -> validTour pts r && costOk (tourCost tr)
    Nothing     -> False

-- Exact double tree: tour, cost and MST weight.
doubleTreeIs :: [(Int, Int)] -> [Int] -> Int -> Int -> Bool
doubleTreeIs pts order cost mst =
  doubleTree pts == Just (TourResult order cost) && mstWeight pts == mst

-- ===========================================================================
-- Point sets
-- ===========================================================================

single, two, collinear, square, parentTie, grid, dup, star, clusters, spiral, s12, s20, s40 :: [(Int, Int)]
single = [(5, 5)]
two = [(0, 0), (3, 4)]
collinear = [(0, 0), (4, 0), (1, 0), (9, 0), (6, 0)]
square = [(0, 0), (0, 2), (2, 2), (2, 0)]
parentTie = [(2, 0), (0, 3), (2, 3), (3, 4), (1, 4)]
grid = [(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (0, 2), (1, 2), (2, 2)]
dup = [(3, 3), (3, 3), (0, 0), (3, 3)]
star = [(5, 5), (5, 0), (0, 5), (10, 5)]
clusters = [(0, 0), (20, 0), (1, 1), (21, 1), (0, 20), (20, 20), (1, 21), (21, 21)]
spiral = [(0, 0), (8, 0), (8, 8), (0, 8), (2, 2), (6, 2), (6, 6), (2, 6), (4, 4)]
s12 = take 12 s40
s20 =
  [ (38, 58), (13, 15), (51, 27), (10, 19), (12, 86), (49, 67), (84, 60), (25, 43), (89, 83), (37, 66)
  , (66, 78), (95, 11), (67, 54), (31, 45), (82, 36), (24, 5), (94, 2), (51, 67), (54, 53), (61, 96) ]
s40 =
  [ (81, 33), (69, 61), (56, 93), (77, 0), (65, 25), (72, 14), (14, 48), (33, 32), (73, 63), (71, 87)
  , (5, 8), (54, 24), (22, 71), (51, 45), (55, 89), (29, 78), (87, 65), (32, 67), (53, 10), (27, 83)
  , (36, 30), (41, 96), (2, 37), (8, 85), (78, 74), (59, 59), (76, 26), (9, 63), (63, 86), (7, 17)
  , (91, 65), (27, 22), (7, 85), (95, 32), (35, 71), (7, 65), (12, 61), (82, 60), (5, 35), (74, 66) ]

-- ===========================================================================
-- Algorithm A: MST Double Tree
-- ===========================================================================

testAlgoA01Empty :: Bool
testAlgoA01Empty = mstWeight [] == 0 && isNothing (doubleTree [])

testAlgoA02SinglePoint :: Bool
testAlgoA02SinglePoint = doubleTreeIs single [0] 0 0

testAlgoA03TwoPoints :: Bool
testAlgoA03TwoPoints = doubleTreeIs two [0, 1] 14 7

testAlgoA04CollinearUnsorted :: Bool
testAlgoA04CollinearUnsorted = doubleTreeIs collinear [0, 2, 1, 4, 3] 18 9

testAlgoA05Square :: Bool
testAlgoA05Square = doubleTreeIs square [0, 1, 2, 3] 8 6

testAlgoA06ParentTieBreaking :: Bool
testAlgoA06ParentTieBreaking = doubleTreeIs parentTie [0, 2, 1, 4, 3] 14 9

testAlgoA07GridTies :: Bool
testAlgoA07GridTies = doubleTreeIs grid [0, 1, 2, 5, 8, 4, 7, 3, 6] 12 8

testAlgoA08DuplicatePoints :: Bool
testAlgoA08DuplicatePoints = doubleTreeIs dup [0, 1, 2, 3] 12 6

testAlgoA09ClustersTwoApprox :: Bool
testAlgoA09ClustersTwoApprox =
  doubleTreeIs clusters [0, 1, 3, 5, 7, 2, 4, 6] 128 68
    && maybe False ((<= 2 * 88) . tourCost) (doubleTree clusters)

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  let r = doubleTree s40
  in length s40 == 40
     && mstWeight s40 == 503
     && fmap tourCost r == Just 832
     && validTour s40 r

-- ===========================================================================
-- Algorithm B: Christofides
-- ===========================================================================

testAlgoB01Empty :: Bool
testAlgoB01Empty = matchingWeight [] == 0 && isNothing (christofides [])

testAlgoB02TwoPointsDoubleEdge :: Bool
testAlgoB02TwoPointsDoubleEdge =
  matchingWeight two == 7
    && christofidesOk two (== 14)
    && christofides two == Just (TourResult [0, 1] 14)

testAlgoB03StarParallelEdges :: Bool
testAlgoB03StarParallelEdges = matchingWeight star == 15 && christofidesOk star (== 30)

testAlgoB04Collinear :: Bool
testAlgoB04Collinear = matchingWeight collinear == 9 && christofidesOk collinear (== 18)

testAlgoB05Grid :: Bool
testAlgoB05Grid = matchingWeight grid == 4 && christofidesOk grid (<= 12)

testAlgoB06BeatsDoubleTree :: Bool
testAlgoB06BeatsDoubleTree = matchingWeight clusters == 24 && christofidesOk clusters (<= 92)

testAlgoB07SpiralBound :: Bool
testAlgoB07SpiralBound =
  matchingWeight spiral == 20
    && christofidesOk spiral (\c -> c <= 52 && 2 * c <= 3 * 44)

testAlgoB08GreedyMatchingTrap :: Bool
testAlgoB08GreedyMatchingTrap =
  matchingWeight s12 == 163
    && christofidesOk s12 (\c -> c <= 440 && 2 * c <= 3 * 396)

testAlgoB09DuplicatePoints :: Bool
testAlgoB09DuplicatePoints = matchingWeight dup == 6 && christofidesOk dup (== 12)

testAlgoB10Stress :: Bool
testAlgoB10Stress =
  matchingWeight s20 == 211
    && christofidesOk s20 (\c -> c <= 608 && 2 * c <= 3 * 540)

tests :: [TestCase]
tests =
  [ ("Test A01 (Empty)", testAlgoA01Empty)
  , ("Test A02 (Single Point)", testAlgoA02SinglePoint)
  , ("Test A03 (Two Points)", testAlgoA03TwoPoints)
  , ("Test A04 (Collinear Unsorted)", testAlgoA04CollinearUnsorted)
  , ("Test A05 (Square)", testAlgoA05Square)
  , ("Test A06 (Parent Tie Breaking)", testAlgoA06ParentTieBreaking)
  , ("Test A07 (Grid Ties)", testAlgoA07GridTies)
  , ("Test A08 (Duplicate Points)", testAlgoA08DuplicatePoints)
  , ("Test A09 (Clusters Two Approx)", testAlgoA09ClustersTwoApprox)
  , ("Test A10 (Stress)", testAlgoA10Stress)
  , ("Test B01 (Empty)", testAlgoB01Empty)
  , ("Test B02 (Two Points Double Edge)", testAlgoB02TwoPointsDoubleEdge)
  , ("Test B03 (Star Parallel Edges)", testAlgoB03StarParallelEdges)
  , ("Test B04 (Collinear)", testAlgoB04Collinear)
  , ("Test B05 (Grid)", testAlgoB05Grid)
  , ("Test B06 (Beats Double Tree)", testAlgoB06BeatsDoubleTree)
  , ("Test B07 (Spiral Bound)", testAlgoB07SpiralBound)
  , ("Test B08 (Greedy Matching Trap)", testAlgoB08GreedyMatchingTrap)
  , ("Test B09 (Duplicate Points)", testAlgoB09DuplicatePoints)
  , ("Test B10 (Stress)", testAlgoB10Stress)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: MST Double Tree ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Christofides ---"
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
