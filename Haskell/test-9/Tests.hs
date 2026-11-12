module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM, guard)
import qualified Data.Set as Set
import System.Exit (ExitCode (..), exitWith)
import BTree

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

-- dump(leaf) = "(k0 k1 ...)", dump(internal) = "(dump(c0) k0 dump(c1) ... dump(ck))".
dump :: BNode -> String
dump (BNode ks []) = "(" ++ unwords (map show ks) ++ ")"
dump (BNode ks (c : cs)) =
  "(" ++ unwords (dump c : concat [[show k, dump ch] | (k, ch) <- zip ks cs]) ++ ")"

dumpOf :: Maybe BNode -> Maybe String
dumpOf = fmap dump

data Stats = Stats
  { stHeight  :: Int
  , stNodes   :: Int
  , stInorder :: [Int]
  }

-- Validates all B-tree invariants (key counts, sorted keys, separator ranges,
-- child count = keys + 1, all leaves at the same depth). Returns height
-- (levels, empty tree = 1), node count and the in-order key list.
validate :: Int -> BNode -> Maybe Stats
validate t = go True Nothing Nothing
  where
    go isRoot lo hi (BNode ks cs) = do
      let n = length ks
      guard (n <= 2 * t - 1)
      guard (isRoot || n >= t - 1)
      guard (and (zipWith (<) ks (drop 1 ks)))
      guard (all (\k -> maybe True (< k) lo && maybe True (> k) hi) ks)
      if null cs
        then pure (Stats 1 1 ks)
        else do
          guard (n >= 1 && length cs == n + 1)
          let ranges = zip (lo : map Just ks) (map Just ks ++ [hi])
          subs <- mapM (\((l, h), c) -> go False l h c) (zip ranges cs)
          let heights = map stHeight subs
          guard (all (== head heights) heights)
          pure Stats
            { stHeight = head heights + 1
            , stNodes = 1 + sum (map stNodes subs)
            , stInorder = concat (zipWith (++) (map stInorder subs) (map pure ks ++ [[]]))
            }

-- Generator G(seed, count, mod).
gen :: Int -> Int -> Int -> [Int]
gen seed count m = take count (map (\x -> (x `div` 65536) `mod` m) (tail (iterate step seed)))
  where step x = (x * 1103515245 + 12345) `mod` 2147483648

sortedDistinct :: [Int] -> [Int]
sortedDistinct = Set.toAscList . Set.fromList

-- Invariants hold and height / node count / root keys / in-order list match.
statsMatch :: Int -> Maybe BNode -> Int -> Int -> Maybe [Int] -> [Int] -> Bool
statsMatch t r height nodes rootKeys inorder =
  case r of
    Nothing -> False
    Just root -> case validate t root of
      Nothing -> False
      Just st ->
        stHeight st == height
          && stNodes st == nodes
          && maybe True (== nodeKeys root) rootKeys
          && stInorder st == inorder

base10 :: [Int]
base10 = [10, 20 .. 100]

-- ===========================================================================
-- Algorithm A: Insertion
-- ===========================================================================

testAlgoA01Empty :: Bool
testAlgoA01Empty = dumpOf (insertAll 2 []) == Just "()"

testAlgoA02InvalidDegree :: Bool
testAlgoA02InvalidDegree = dumpOf (insertAll 1 [1, 2, 3]) == Nothing

testAlgoA03SingleLeaf :: Bool
testAlgoA03SingleLeaf = dumpOf (insertAll 3 [5, 1, 3]) == Just "(1 3 5)"

testAlgoA04RootSplit :: Bool
testAlgoA04RootSplit = dumpOf (insertAll 2 [1, 2, 3, 4]) == Just "((1) 2 (3 4))"

testAlgoA05DuplicateOnFullRoot :: Bool
testAlgoA05DuplicateOnFullRoot = dumpOf (insertAll 2 [1, 2, 3, 2]) == Just "(1 2 3)"

testAlgoA06Ascending :: Bool
testAlgoA06Ascending =
  dumpOf (insertAll 2 base10)
    == Just "(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))"

testAlgoA07ProactiveSplit :: Bool
testAlgoA07ProactiveSplit =
  dumpOf (insertAll 2 [10, 9 .. 1])
    == Just "(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))"

testAlgoA08TextbookT3 :: Bool
testAlgoA08TextbookT3 =
  dumpOf (insertAll 3 [8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18])
    == Just "((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))"

testAlgoA09Invariants :: Bool
testAlgoA09Invariants =
  let ks = gen 7 100 1000
      expected = sortedDistinct ks
  in take 5 ks == [564, 806, 868, 674, 531]
     && length expected == 95
     && statsMatch 3 (insertAll 3 ks) 3 28 Nothing expected

testAlgoA10Stress :: Bool
testAlgoA10Stress =
  let ks = gen 42 2000 100000
      expected = sortedDistinct ks
  in length expected == 1937
     && sum expected == 31779629
     && statsMatch 4 (insertAll 4 ks) 5 413 (Just [15269]) expected

-- ===========================================================================
-- Algorithm B: Deletion
-- ===========================================================================

testAlgoB01DeleteFromLeaf :: Bool
testAlgoB01DeleteFromLeaf = dumpOf (deleteAll 3 [5, 1, 3, 9, 7] [3]) == Just "(1 5 7 9)"

testAlgoB02AbsentKeyUnchanged :: Bool
testAlgoB02AbsentKeyUnchanged =
  dumpOf (deleteAll 2 [10, 30, 20, 40] [15]) == Just "((10) 20 (30 40))"

testAlgoB03DeleteAll :: Bool
testAlgoB03DeleteAll =
  dumpOf (deleteAll 2 base10 [50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999]) == Just "()"

testAlgoB04PredecessorPreferred :: Bool
testAlgoB04PredecessorPreferred =
  dumpOf (deleteAll 2 [10, 20, 30, 40, 5] [20]) == Just "((5) 10 (30 40))"

testAlgoB05Successor :: Bool
testAlgoB05Successor =
  dumpOf (deleteAll 2 [10, 20, 30, 40, 35] [20]) == Just "((10) 30 (35 40))"

testAlgoB06MergeChildren :: Bool
testAlgoB06MergeChildren =
  dumpOf (deleteAll 2 [14, 3, 4, 11, 5, 15] [4]) == Just "((3 5) 11 (14 15))"

testAlgoB07BorrowLeftFirst :: Bool
testAlgoB07BorrowLeftFirst =
  dumpOf (deleteAll 2 [21, 12, 9, 10, 17, 23, 24] [17]) == Just "((9) 10 (12) 21 (23 24))"

testAlgoB08MergeRightFirst :: Bool
testAlgoB08MergeRightFirst =
  dumpOf (deleteAll 2 [3, 4, 19, 12, 7, 15, 22, 28] [7]) == Just "((3) 4 (12 15) 19 (22 28))"

testAlgoB09RootShrink :: Bool
testAlgoB09RootShrink =
  dumpOf (deleteAll 2 base10 [10, 20]) == Just "((30) 40 (50) 60 (70) 80 (90 100))"

testAlgoB10StressInvariants :: Bool
testAlgoB10StressInvariants =
  let ks = gen 9 300 500
      ds = gen 3 250 500
      expected = Set.toAscList (Set.fromList ks `Set.difference` Set.fromList ds)
  in length expected == 150
     && sum expected == 39704
     && statsMatch 3 (deleteAll 3 ks ds) 4 55 (Just [293]) expected

tests :: [TestCase]
tests =
  [ ("Test A01 (Empty)", testAlgoA01Empty)
  , ("Test A02 (Invalid Degree)", testAlgoA02InvalidDegree)
  , ("Test A03 (Single Leaf)", testAlgoA03SingleLeaf)
  , ("Test A04 (Root Split)", testAlgoA04RootSplit)
  , ("Test A05 (Duplicate On Full Root)", testAlgoA05DuplicateOnFullRoot)
  , ("Test A06 (Ascending)", testAlgoA06Ascending)
  , ("Test A07 (Proactive Split)", testAlgoA07ProactiveSplit)
  , ("Test A08 (Textbook t3)", testAlgoA08TextbookT3)
  , ("Test A09 (Invariants)", testAlgoA09Invariants)
  , ("Test A10 (Stress)", testAlgoA10Stress)
  , ("Test B01 (Delete From Leaf)", testAlgoB01DeleteFromLeaf)
  , ("Test B02 (Absent Key Unchanged)", testAlgoB02AbsentKeyUnchanged)
  , ("Test B03 (Delete All)", testAlgoB03DeleteAll)
  , ("Test B04 (Predecessor Preferred)", testAlgoB04PredecessorPreferred)
  , ("Test B05 (Successor)", testAlgoB05Successor)
  , ("Test B06 (Merge Children)", testAlgoB06MergeChildren)
  , ("Test B07 (Borrow Left First)", testAlgoB07BorrowLeftFirst)
  , ("Test B08 (Merge Right First)", testAlgoB08MergeRightFirst)
  , ("Test B09 (Root Shrink)", testAlgoB09RootShrink)
  , ("Test B10 (Stress Invariants)", testAlgoB10StressInvariants)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Insertion ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Deletion ---"
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
