module Main where

import qualified Control.Exception as E
import Control.Monad (forM)
import Data.Maybe (isJust, isNothing)
import System.Exit (ExitCode (..), exitWith)
import Expression

type TestCase = (String, Bool)

check :: String -> Bool -> IO Bool
check name passed = do
  result <- E.try (E.evaluate passed) :: IO (Either E.SomeException Bool)
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

-- Parse then evaluate; a parse failure is reported as InvalidOp.
evalStr :: String -> [Variable] -> EvalResult
evalStr s vars =
  case parseExpression s of
    Nothing  -> EvalResult InvalidOp 0.0
    Just ast -> evaluate ast vars

valueOk :: EvalResult -> Double -> Bool
valueOk r expected = evalStatus r == Ok && abs (evalValue r - expected) < 1e-9

-- ===========================================================================
-- Algorithm A: parseExpression (syntactic validity / AST construction)
-- ===========================================================================

testAlgoA01SingleNumber :: Bool
testAlgoA01SingleNumber = isJust (parseExpression "42")

testAlgoA02SimpleBinary :: Bool
testAlgoA02SimpleBinary = isJust (parseExpression "1 + 2 * 3")

testAlgoA03Parentheses :: Bool
testAlgoA03Parentheses = isJust (parseExpression "2 * (3 + 4) - 5")

testAlgoA04FunctionCall :: Bool
testAlgoA04FunctionCall = isJust (parseExpression "sqrt(16) + max(1, 2)")

testAlgoA05NestedAndUnary :: Bool
testAlgoA05NestedAndUnary = isJust (parseExpression "-min(max(1, 2), 3) + -(4)")

testAlgoA06DanglingOperator :: Bool
testAlgoA06DanglingOperator = isNothing (parseExpression "1 +")

testAlgoA07EmptyString :: Bool
testAlgoA07EmptyString = isNothing (parseExpression "")

testAlgoA08UnbalancedParens :: Bool
testAlgoA08UnbalancedParens = isNothing (parseExpression "(1 + 2")

testAlgoA09TrailingGarbage :: Bool
testAlgoA09TrailingGarbage =
  isNothing (parseExpression "1 + 2)") && isNothing (parseExpression "3 4")

testAlgoA10BadFunction :: Bool
testAlgoA10BadFunction =
  all isNothing
    [ parseExpression "foo(1)"
    , parseExpression "sqrt(1, 2)"
    , parseExpression "max(1)"
    ]

-- ===========================================================================
-- Algorithm B: evaluate (numeric value + error statuses)
-- ===========================================================================

testAlgoB01Precedence :: Bool
testAlgoB01Precedence = valueOk (evalStr "3 + 4 * 2" []) 11.0

testAlgoB02ParensOverride :: Bool
testAlgoB02ParensOverride = valueOk (evalStr "(3 + 4) * 2" []) 14.0

testAlgoB03PowerRightAssoc :: Bool
testAlgoB03PowerRightAssoc = valueOk (evalStr "2 ^ 3 ^ 2" []) 512.0

testAlgoB04UnaryVsPower :: Bool
testAlgoB04UnaryVsPower = valueOk (evalStr "-2 ^ 2" []) (-4.0)

testAlgoB05Variables :: Bool
testAlgoB05Variables =
  valueOk (evalStr "x * x + y * y" [Variable "x" 3.0, Variable "y" 4.0]) 25.0

testAlgoB06UndefinedVar :: Bool
testAlgoB06UndefinedVar = evalStatus (evalStr "x + 1" []) == UndefinedVar

testAlgoB07DivAndMod :: Bool
testAlgoB07DivAndMod =
  valueOk (evalStr "10 % 3" []) 1.0
    && evalStatus (evalStr "5 / 0" []) == DivByZero

testAlgoB08Functions :: Bool
testAlgoB08Functions =
  valueOk (evalStr "max(3, 7) + min(2, 5)" []) 9.0
    && valueOk (evalStr "abs(-5) + sqrt(9)" []) 8.0
    && valueOk (evalStr "pow(2, 10)" []) 1024.0

testAlgoB09DomainError :: Bool
testAlgoB09DomainError = evalStatus (evalStr "sqrt(-1)" []) == DomainError

testAlgoB10ErrorPropagation :: Bool
testAlgoB10ErrorPropagation =
  evalStatus (evalStr "x + 1 / (x - 2)" [Variable "x" 2.0]) == DivByZero

tests :: [TestCase]
tests =
  [ ("test_algo_a_01_single_number", testAlgoA01SingleNumber)
  , ("test_algo_a_02_simple_binary", testAlgoA02SimpleBinary)
  , ("test_algo_a_03_parentheses", testAlgoA03Parentheses)
  , ("test_algo_a_04_function_call", testAlgoA04FunctionCall)
  , ("test_algo_a_05_nested_and_unary", testAlgoA05NestedAndUnary)
  , ("test_algo_a_06_dangling_operator", testAlgoA06DanglingOperator)
  , ("test_algo_a_07_empty_string", testAlgoA07EmptyString)
  , ("test_algo_a_08_unbalanced_parens", testAlgoA08UnbalancedParens)
  , ("test_algo_a_09_trailing_garbage", testAlgoA09TrailingGarbage)
  , ("test_algo_a_10_bad_function", testAlgoA10BadFunction)
  , ("test_algo_b_01_precedence", testAlgoB01Precedence)
  , ("test_algo_b_02_parens_override", testAlgoB02ParensOverride)
  , ("test_algo_b_03_power_right_assoc", testAlgoB03PowerRightAssoc)
  , ("test_algo_b_04_unary_vs_power", testAlgoB04UnaryVsPower)
  , ("test_algo_b_05_variables", testAlgoB05Variables)
  , ("test_algo_b_06_undefined_var", testAlgoB06UndefinedVar)
  , ("test_algo_b_07_div_and_mod", testAlgoB07DivAndMod)
  , ("test_algo_b_08_functions", testAlgoB08Functions)
  , ("test_algo_b_09_domain_error", testAlgoB09DomainError)
  , ("test_algo_b_10_error_propagation", testAlgoB10ErrorPropagation)
  ]

main :: IO ()
main = do
  putStrLn "=== START ==="
  putStrLn ""
  putStrLn "--- Algorithm A: Parsing & AST Construction ---"
  resultsA <- forM (take 10 tests) (uncurry check)
  putStrLn ""
  putStrLn "--- Algorithm B: Evaluation & Error Semantics ---"
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
