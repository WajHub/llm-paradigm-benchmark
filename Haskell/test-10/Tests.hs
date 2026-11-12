module Main where

import Control.Exception (Exception, SomeException, evaluate, throwIO, try)
import Control.Monad (forM, when)
import Data.Array (Array, listArray, (!))
import Data.IORef (modifyIORef', newIORef, readIORef)
import Data.Maybe (isNothing)
import System.Exit (ExitCode (..), exitWith)
import OrderStats

-- Section A tests are pure Bool values; section B tests run the monadic
-- medianTwoSorted in IO with a counting probe.
type TestCase = (String, IO Bool)

check :: String -> IO Bool -> IO Bool
check name action = do
  result <- try (action >>= evaluate) :: IO (Either SomeException Bool)
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

sel :: [Int] -> Int -> Maybe (Int, [Int])
sel xs k = fmap (\r -> (selValue r, selPivots r)) (selectKth xs k)

lcgOutputs :: Int -> [Int]
lcgOutputs seed = map (`div` 65536) (tail (iterate step seed))
  where step x = (x * 1103515245 + 12345) `mod` 2147483648

stressXs :: [Int]
stressXs = map (\r -> r `mod` 20001 - 10000) (take 5000 (lcgOutputs 42))

-- Probe failures raised by the test sources.
data ProbeError = BudgetExceeded | IndexOutOfRange Int
  deriving Show

instance Exception ProbeError

bitlen :: Int -> Int
bitlen 0 = 0
bitlen x = 1 + bitlen (x `div` 2)

-- A virtual sorted sequence: its length and element formula.
data Spec = Spec Int (Int -> Int)

fromList :: [Int] -> Spec
fromList vs = Spec n (arr !)
  where
    n = length vs
    arr = listArray (0, n - 1) vs :: Array Int Int

-- Runs medianTwoSorted on two counting sources sharing one read budget
-- 16 * (bitlen (m + n) + 1). Over-budget or out-of-range reads throw.
runMedian :: Spec -> Spec -> IO (Maybe Double)
runMedian (Spec m fa) (Spec n fb) = do
  counter <- newIORef (0 :: Int)
  let budget = 16 * (bitlen (m + n) + 1)
      probe len f i = do
        modifyIORef' counter (+ 1)
        used <- readIORef counter
        when (used > budget) $ throwIO BudgetExceeded
        when (i < 0 || i >= len) $ throwIO (IndexOutOfRange i)
        pure $! f i
  medianTwoSorted (Source m (probe m fa)) (Source n (probe n fb))

medianIs :: Spec -> Spec -> Maybe Double -> IO Bool
medianIs a b expected = do
  r <- runMedian a b
  pure $ case (r, expected) of
    (Nothing, Nothing) -> True
    (Just v, Just e)   -> abs (v - e) < 1e-9
    _                  -> False

-- ===========================================================================
-- Algorithm A: Median of Medians
-- ===========================================================================

testAlgoA01Empty :: Bool
testAlgoA01Empty = isNothing (medianOfMedians []) && isNothing (selectKth [] 0)

testAlgoA02Single :: Bool
testAlgoA02Single =
  medianOfMedians [7] == Just 7
    && sel [7] 0 == Just (7, [])
    && isNothing (selectKth [7] 1)

testAlgoA03OutOfRange :: Bool
testAlgoA03OutOfRange =
  isNothing (selectKth [3, 1, 2] 3)
    && isNothing (selectKth [3, 1, 2] (-1))
    && sel [3, 1, 2] 2 == Just (3, [])
    && medianOfMedians [3, 1, 2] == Just 2

testAlgoA04OneGroup :: Bool
testAlgoA04OneGroup =
  let xs = [9, 1, 8, 2, 7]
  in medianOfMedians xs == Just 7
     && sel xs 0 == Just (1, [])
     && sel xs 2 == Just (7, [])
     && sel xs 4 == Just (9, [])

testAlgoA05PivotIsNotMedian :: Bool
testAlgoA05PivotIsNotMedian =
  let xs = [1 .. 10]
  in medianOfMedians xs == Just 3
     && sel xs 4 == Just (5, [3, 6])
     && sel xs 5 == Just (6, [3, 6])

testAlgoA06PartialLastGroup :: Bool
testAlgoA06PartialLastGroup =
  let xs = [5, 3, 9, 1, 8, 2, 6]
  in medianOfMedians xs == Just 2
     && sel xs 3 == Just (5, [2])
     && sel xs 6 == Just (9, [2])

testAlgoA07ManyDuplicates :: Bool
testAlgoA07ManyDuplicates =
  let xs = [5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5]
  in medianOfMedians xs == Just 5
     && sel xs 0 == Just (1, [5])
     && sel xs 5 == Just (5, [5])
     && sel xs 10 == Just (9, [5])

testAlgoA08StablePartitionOrder :: Bool
testAlgoA08StablePartitionOrder =
  let xs = [40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27]
  in medianOfMedians xs == Just 40 && sel xs 6 == Just (51, [40, 41, 51])

testAlgoA09AllRanks :: Bool
testAlgoA09AllRanks =
  let xs = [12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14]
      sortedXs = [-30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41]
      pivotsFor k
        | k <= 6 = [3, -11]
        | k <= 11 = [3]
        | otherwise = [3, 14]
  in medianOfMedians xs == Just 3
     && and [ sel xs k == Just (sortedXs !! k, pivotsFor k) | k <- [0 .. 22] ]

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  take 6 stressXs == [9081, 7033, 5269, -4540, 3856, -8907]
    && medianOfMedians stressXs == Just (-1678)
    && sel stressXs 0
         == Just (-9996, [-1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995])
    && sel stressXs 2499
         == Just (-1694, [-1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694])
    && sel stressXs 4999
         == Just (9984, [-1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974])

-- ===========================================================================
-- Algorithm B: Median of Two Sorted Arrays
-- ===========================================================================

testAlgoB01BothEmpty :: IO Bool
testAlgoB01BothEmpty = medianIs (fromList []) (fromList []) Nothing

testAlgoB02OneEmpty :: IO Bool
testAlgoB02OneEmpty = medianIs (fromList []) (fromList [1, 2, 3, 4]) (Just 2.5)

testAlgoB03SingleEach :: IO Bool
testAlgoB03SingleEach = medianIs (fromList [1]) (fromList [2]) (Just 1.5)

testAlgoB04OddTotalInterleaved :: IO Bool
testAlgoB04OddTotalInterleaved = medianIs (fromList [1, 3, 5]) (fromList [2, 4]) (Just 3.0)

testAlgoB05DisjointRanges :: IO Bool
testAlgoB05DisjointRanges =
  medianIs (fromList [10, 11, 12, 13]) (fromList [1, 2, 3]) (Just 10.0)

testAlgoB06Duplicates :: IO Bool
testAlgoB06Duplicates = medianIs (fromList [1, 1, 1, 1]) (fromList [1, 1, 2]) (Just 1.0)

testAlgoB07NoOverflow :: IO Bool
testAlgoB07NoOverflow = do
  r1 <- medianIs (fromList [2147483647]) (fromList [2147483647]) (Just 2147483647.0)
  r2 <- medianIs (fromList [-2147483648, 2147483647]) (fromList []) (Just (-0.5))
  pure (r1 && r2)

testAlgoB08HugeInterleaved :: IO Bool
testAlgoB08HugeInterleaved =
  medianIs (Spec 1000000000 (\i -> 2 * i - 1000000000))
           (Spec 999999999 (\j -> 2 * j - 999999999))
           (Just (-1.0))

testAlgoB09HugeUnbalanced :: IO Bool
testAlgoB09HugeUnbalanced =
  medianIs (fromList [-5, 0, 7])
           (Spec 2000000000 (\j -> j `div` 2 - 500000000))
           (Just 0.0)

testAlgoB10HugeDuplicates :: IO Bool
testAlgoB10HugeDuplicates =
  medianIs (Spec 1500000000 (`div` 1000000))
           (Spec 600000000 (\j -> 700 + j `div` 3000000))
           (Just 787.0)

tests :: [TestCase]
tests =
  [ ("Test A01 (Empty)", pure testAlgoA01Empty)
  , ("Test A02 (Single)", pure testAlgoA02Single)
  , ("Test A03 (Out Of Range)", pure testAlgoA03OutOfRange)
  , ("Test A04 (One Group)", pure testAlgoA04OneGroup)
  , ("Test A05 (Pivot Is Not Median)", pure testAlgoA05PivotIsNotMedian)
  , ("Test A06 (Partial Last Group)", pure testAlgoA06PartialLastGroup)
  , ("Test A07 (Many Duplicates)", pure testAlgoA07ManyDuplicates)
  , ("Test A08 (Stable Partition Order)", pure testAlgoA08StablePartitionOrder)
  , ("Test A09 (All Ranks)", pure testAlgoA09AllRanks)
  , ("Test A10 (Stress)", pure testAlgoA10Stress)
  , ("Test B01 (Both Empty)", testAlgoB01BothEmpty)
  , ("Test B02 (One Empty)", testAlgoB02OneEmpty)
  , ("Test B03 (Single Each)", testAlgoB03SingleEach)
  , ("Test B04 (Odd Total Interleaved)", testAlgoB04OddTotalInterleaved)
  , ("Test B05 (Disjoint Ranges)", testAlgoB05DisjointRanges)
  , ("Test B06 (Duplicates)", testAlgoB06Duplicates)
  , ("Test B07 (No Overflow)", testAlgoB07NoOverflow)
  , ("Test B08 (Huge Interleaved)", testAlgoB08HugeInterleaved)
  , ("Test B09 (Huge Unbalanced)", testAlgoB09HugeUnbalanced)
  , ("Test B10 (Huge Duplicates)", testAlgoB10HugeDuplicates)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Median of Medians ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Median of Two Sorted Arrays ---"
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
