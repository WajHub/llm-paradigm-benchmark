module Main where

import Control.Exception (SomeException, evaluate, try)
import Control.Monad (forM)
import System.Exit (ExitCode (..), exitWith)
import PalindromeTree

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
-- Algorithm A: eertreeBuild, eertreeCountDistinct, eertreeLongestLength
-- ===========================================================================

testAlgoA01BasicAabaa :: Bool
testAlgoA01BasicAabaa =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 5 && eertreeLongestLength t == 5

testAlgoA02SingleChar :: Bool
testAlgoA02SingleChar =
  let t = eertreeBuild (Just "a") 1
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 1 && eertreeLongestLength t == 1

testAlgoA03AllSameChars :: Bool
testAlgoA03AllSameChars =
  let t = eertreeBuild (Just "aaaa") 4
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 4 && eertreeLongestLength t == 4

testAlgoA04NoInternalPalindromes :: Bool
testAlgoA04NoInternalPalindromes =
  let t = eertreeBuild (Just "abcde") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 5 && eertreeLongestLength t == 1

testAlgoA05EmptyString :: Bool
testAlgoA05EmptyString =
  let t = eertreeBuild (Just "") 0
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 0 && eertreeLongestLength t == 0

testAlgoA06NullInput :: Bool
testAlgoA06NullInput = eertreeBuild Nothing 5 == Nothing

testAlgoA07TwoCharPalindrome :: Bool
testAlgoA07TwoCharPalindrome =
  let t = eertreeBuild (Just "aa") 2
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 2 && eertreeLongestLength t == 2

testAlgoA08Abacaba :: Bool
testAlgoA08Abacaba =
  let t = eertreeBuild (Just "abacaba") 7
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 7 && eertreeLongestLength t == 7

testAlgoA09Abba :: Bool
testAlgoA09Abba =
  let t = eertreeBuild (Just "abba") 4
  in case t of
       Nothing -> False
       _ -> eertreeCountDistinct t == 4 && eertreeLongestLength t == 4

testAlgoA10NodeCountInvariant :: Bool
testAlgoA10NodeCountInvariant =
  let cases = [("racecar", 7), ("aabbaa", 6), ("abcbaabcba", 10), ("zzzzzzzzz", 9)]
      checkCase (s, len) =
        case eertreeBuild (Just s) len of
          Nothing -> False
          t -> let d = eertreeCountDistinct t in d <= len && d > 0
      racecar = eertreeBuild (Just "racecar") 7
  in all checkCase cases
     && (case racecar of
           Nothing -> False
           _ -> eertreeCountDistinct racecar == 7)

-- ===========================================================================
-- Algorithm B: eertreeCountOccurrences
-- ===========================================================================

testAlgoB01SingleCharOccurrences :: Bool
testAlgoB01SingleCharOccurrences =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "a") 1 == 4

testAlgoB02EvenPalindromeOccurrences :: Bool
testAlgoB02EvenPalindromeOccurrences =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "aa") 2 == 2

testAlgoB03FullStringPalindrome :: Bool
testAlgoB03FullStringPalindrome =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "aabaa") 5 == 1

testAlgoB04PatternNotInString :: Bool
testAlgoB04PatternNotInString =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "xyz") 3 == 0

testAlgoB05PatternNotAPalindrome :: Bool
testAlgoB05PatternNotAPalindrome =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "ab") 2 == 0

testAlgoB06OverlappingEvenPalindromes :: Bool
testAlgoB06OverlappingEvenPalindromes =
  let t = eertreeBuild (Just "aaaa") 4
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "aa") 2 == 3

testAlgoB07AllSameSingleChar :: Bool
testAlgoB07AllSameSingleChar =
  let t = eertreeBuild (Just "aaaa") 4
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "a") 1 == 4

testAlgoB08RepeatedPalindrome :: Bool
testAlgoB08RepeatedPalindrome =
  let t = eertreeBuild (Just "abacaba") 7
  in case t of
       Nothing -> False
       _ -> eertreeCountOccurrences t (Just "aba") 3 == 2

testAlgoB09NullArguments :: Bool
testAlgoB09NullArguments =
  let t = eertreeBuild (Just "aabaa") 5
  in case t of
       Nothing -> False
       _ ->
         eertreeCountOccurrences Nothing (Just "a") 1 == 0
         && eertreeCountOccurrences t Nothing 1 == 0
         && eertreeCountOccurrences t (Just "a") 0 == 0
         && eertreeCountOccurrences Nothing Nothing 0 == 0

testAlgoB10StressTest :: Bool
testAlgoB10StressTest =
  let n = 50000
      s = replicate n 'a'
      t = eertreeBuild (Just s) n
  in case t of
       Nothing -> False
       _ ->
         eertreeCountDistinct t == n
         && eertreeLongestLength t == n
         && eertreeCountOccurrences t (Just "a") 1 == n
         && eertreeCountOccurrences t (Just "aa") 2 == n - 1

tests :: [TestCase]
tests =
  [ ("test_algo_a_01_basic_aabaa", testAlgoA01BasicAabaa)
  , ("test_algo_a_02_single_char", testAlgoA02SingleChar)
  , ("test_algo_a_03_all_same_chars", testAlgoA03AllSameChars)
  , ("test_algo_a_04_no_internal_palindromes", testAlgoA04NoInternalPalindromes)
  , ("test_algo_a_05_empty_string", testAlgoA05EmptyString)
  , ("test_algo_a_06_null_input", testAlgoA06NullInput)
  , ("test_algo_a_07_two_char_palindrome", testAlgoA07TwoCharPalindrome)
  , ("test_algo_a_08_abacaba", testAlgoA08Abacaba)
  , ("test_algo_a_09_abba", testAlgoA09Abba)
  , ("test_algo_a_10_node_count_invariant", testAlgoA10NodeCountInvariant)
  , ("test_algo_b_01_single_char_occurrences", testAlgoB01SingleCharOccurrences)
  , ("test_algo_b_02_even_palindrome_occurrences", testAlgoB02EvenPalindromeOccurrences)
  , ("test_algo_b_03_full_string_palindrome", testAlgoB03FullStringPalindrome)
  , ("test_algo_b_04_pattern_not_in_string", testAlgoB04PatternNotInString)
  , ("test_algo_b_05_pattern_not_a_palindrome", testAlgoB05PatternNotAPalindrome)
  , ("test_algo_b_06_overlapping_even_palindromes", testAlgoB06OverlappingEvenPalindromes)
  , ("test_algo_b_07_all_same_single_char", testAlgoB07AllSameSingleChar)
  , ("test_algo_b_08_repeated_palindrome", testAlgoB08RepeatedPalindrome)
  , ("test_algo_b_09_null_arguments", testAlgoB09NullArguments)
  , ("test_algo_b_10_stress_test", testAlgoB10StressTest)
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
