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
  [ ("Test A01 (Single Number)", testAlgoA01SingleNumber)
  , ("Test A02 (Binary + Precedence)", testAlgoA02SimpleBinary)
  , ("Test A03 (Parentheses)", testAlgoA03Parentheses)
  , ("Test A04 (Function Calls)", testAlgoA04FunctionCall)
  , ("Test A05 (Nested + Unary)", testAlgoA05NestedAndUnary)
  , ("Test A06 (Dangling Operator)", testAlgoA06DanglingOperator)
  , ("Test A07 (Empty String)", testAlgoA07EmptyString)
  , ("Test A08 (Unbalanced Parens)", testAlgoA08UnbalancedParens)
  , ("Test A09 (Trailing Garbage)", testAlgoA09TrailingGarbage)
  , ("Test A10 (Bad Function Call)", testAlgoA10BadFunction)
  , ("Test B01 (Operator Precedence)", testAlgoB01Precedence)
  , ("Test B02 (Parentheses Override)", testAlgoB02ParensOverride)
  , ("Test B03 (Power Right-Assoc)", testAlgoB03PowerRightAssoc)
  , ("Test B04 (Unary vs Power)", testAlgoB04UnaryVsPower)
  , ("Test B05 (Variables)", testAlgoB05Variables)
  , ("Test B06 (Undefined Variable)", testAlgoB06UndefinedVar)
  , ("Test B07 (Division & Modulo)", testAlgoB07DivAndMod)
  , ("Test B08 (Built-in Functions)", testAlgoB08Functions)
  , ("Test B09 (Domain Error)", testAlgoB09DomainError)
  , ("Test B10 (Error Propagation)", testAlgoB10ErrorPropagation)
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
