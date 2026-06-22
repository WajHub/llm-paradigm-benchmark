module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import System.Exit (ExitCode(..), exitWith)
import ShortestPath

type TestCase = (String, Bool)

approxEq :: Double -> Double -> Bool
approxEq a b = abs (a - b) < 1e-9

distanceIs :: Double -> Double -> Bool
distanceIs actual expected
  | isInfinite expected = isInfinite actual && actual > 0
  | otherwise = approxEq actual expected

checkDistance :: Maybe PathResult -> Int -> Double -> Bool
checkDistance result target expected =
  distanceIs (getShortestDistance result target) expected

pathEquals :: Maybe [Int] -> [Int] -> Bool
pathEquals (Just path) expected = path == expected
pathEquals Nothing _ = False

buildGraph :: Int -> [(Int, Int, Double)] -> Graph
buildGraph numVertices edges =
  foldl (\g (from, to, weight) -> addEdge g from to weight) (createGraph numVertices) edges

createLinearChain :: Int -> Double -> Graph
createLinearChain numVertices weight =
  foldl (\g i -> addEdge g i (i + 1) weight) (createGraph numVertices) [0 .. numVertices - 2]

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

testAlgoA01LinearChain :: Bool
testAlgoA01LinearChain =
  let graph = buildGraph 4 [(0, 1, 1), (1, 2, 2), (2, 3, 3)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ ->
         checkDistance result 0 0
         && checkDistance result 1 1
         && checkDistance result 2 3
         && checkDistance result 3 6

testAlgoA02Diamond :: Bool
testAlgoA02Diamond =
  let graph = buildGraph 4 [(0, 1, 1), (0, 2, 4), (1, 3, 6), (2, 3, 1)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ ->
         checkDistance result 0 0
         && checkDistance result 1 1
         && checkDistance result 2 4
         && checkDistance result 3 5

testAlgoA03Disconnected :: Bool
testAlgoA03Disconnected =
  let graph = buildGraph 5 [(0, 1, 2), (1, 2, 3)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ ->
         checkDistance result 0 0
         && checkDistance result 1 2
         && checkDistance result 2 5
         && checkDistance result 3 (1 / 0)
         && checkDistance result 4 (1 / 0)

testAlgoA04SingleVertex :: Bool
testAlgoA04SingleVertex =
  let graph = createGraph 1
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> checkDistance result 0 0

testAlgoA05ParallelEdges :: Bool
testAlgoA05ParallelEdges =
  let graph = buildGraph 2 [(0, 1, 5), (0, 1, 2), (0, 1, 8)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> checkDistance result 1 2

testAlgoA06ZeroWeightEdges :: Bool
testAlgoA06ZeroWeightEdges =
  let graph = buildGraph 4 [(0, 1, 0), (1, 2, 0), (2, 3, 1)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ ->
         checkDistance result 1 0
         && checkDistance result 2 0
         && checkDistance result 3 1

testAlgoA07NullGraph :: Bool
testAlgoA07NullGraph = dijkstra Nothing 0 == Nothing

testAlgoA08InvalidSource :: Bool
testAlgoA08InvalidSource =
  let graph = createGraph 3
      resultHigh = dijkstra (Just graph) 5
      resultLow = dijkstra (Just graph) (-1)
  in resultHigh == Nothing && resultLow == Nothing

testAlgoA09ComplexGraph :: Bool
testAlgoA09ComplexGraph =
  let graph =
        buildGraph
          6
          [ (0, 1, 7)
          , (0, 2, 9)
          , (0, 5, 14)
          , (1, 2, 10)
          , (1, 3, 15)
          , (2, 3, 11)
          , (2, 5, 2)
          , (3, 4, 6)
          , (4, 5, 9)
          ]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ ->
         checkDistance result 0 0
         && checkDistance result 1 7
         && checkDistance result 2 9
         && checkDistance result 3 20
         && checkDistance result 4 26
         && checkDistance result 5 11

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  let graph = createLinearChain 1000 1
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> checkDistance result 999 999

testAlgoB01SimplePath :: Bool
testAlgoB01SimplePath =
  let graph = buildGraph 4 [(0, 1, 1), (1, 2, 2), (2, 3, 3)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 3) [0, 1, 2, 3]

testAlgoB02DiamondPath :: Bool
testAlgoB02DiamondPath =
  let graph = buildGraph 4 [(0, 1, 1), (0, 2, 4), (1, 3, 6), (2, 3, 1)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 3) [0, 2, 3]

testAlgoB03SelfPath :: Bool
testAlgoB03SelfPath =
  let graph = buildGraph 3 [(0, 1, 1), (1, 2, 1)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 0) [0]

testAlgoB04Unreachable :: Bool
testAlgoB04Unreachable =
  let graph = buildGraph 5 [(0, 1, 2), (1, 2, 3)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> reconstructPath result 4 == Nothing

testAlgoB05LongChain :: Bool
testAlgoB05LongChain =
  let graph = createLinearChain 10 1
      result = dijkstra (Just graph) 0
      expected = [0 .. 9]
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 9) expected

testAlgoB06Cycle :: Bool
testAlgoB06Cycle =
  let graph = buildGraph 4 [(0, 1, 1), (1, 2, 1), (2, 0, 1), (1, 3, 2)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 3) [0, 1, 3]

testAlgoB07Star :: Bool
testAlgoB07Star =
  let graph = buildGraph 5 [(0, 1, 2), (0, 2, 3), (0, 3, 1), (0, 4, 5)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 3) [0, 3]

testAlgoB08NullResult :: Bool
testAlgoB08NullResult = reconstructPath Nothing 0 == Nothing

testAlgoB09Bidirectional :: Bool
testAlgoB09Bidirectional =
  let graph = buildGraph 3 [(0, 1, 1), (1, 0, 10), (1, 2, 1), (0, 2, 5)]
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       _ -> pathEquals (reconstructPath result 2) [0, 1, 2]

testAlgoB10StressPath :: Bool
testAlgoB10StressPath =
  let graph = createLinearChain 1000 1
      result = dijkstra (Just graph) 0
  in case result of
       Nothing -> False
       Just _ ->
         case reconstructPath result 999 of
           Nothing -> False
           Just path -> length path == 1000 && head path == 0 && last path == 999

tests :: [TestCase]
tests =
  [ ("test_algo_a_01_linear_chain", testAlgoA01LinearChain)
  , ("test_algo_a_02_diamond", testAlgoA02Diamond)
  , ("test_algo_a_03_disconnected", testAlgoA03Disconnected)
  , ("test_algo_a_04_single_vertex", testAlgoA04SingleVertex)
  , ("test_algo_a_05_parallel_edges", testAlgoA05ParallelEdges)
  , ("test_algo_a_06_zero_weight_edges", testAlgoA06ZeroWeightEdges)
  , ("test_algo_a_07_null_graph", testAlgoA07NullGraph)
  , ("test_algo_a_08_invalid_source", testAlgoA08InvalidSource)
  , ("test_algo_a_09_complex_graph", testAlgoA09ComplexGraph)
  , ("test_algo_a_10_stress", testAlgoA10Stress)
  , ("test_algo_b_01_simple_path", testAlgoB01SimplePath)
  , ("test_algo_b_02_diamond_path", testAlgoB02DiamondPath)
  , ("test_algo_b_03_self_path", testAlgoB03SelfPath)
  , ("test_algo_b_04_unreachable", testAlgoB04Unreachable)
  , ("test_algo_b_05_long_chain", testAlgoB05LongChain)
  , ("test_algo_b_06_cycle", testAlgoB06Cycle)
  , ("test_algo_b_07_star", testAlgoB07Star)
  , ("test_algo_b_08_null_result", testAlgoB08NullResult)
  , ("test_algo_b_09_bidirectional", testAlgoB09Bidirectional)
  , ("test_algo_b_10_stress_path", testAlgoB10StressPath)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  results <- forM tests (uncurry check)
  let totalTests = length tests
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
