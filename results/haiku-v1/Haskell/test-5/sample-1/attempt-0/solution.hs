module Expression
  ( AstNode (..)
  , Variable (..)
  , EvalStatus (..)
  , EvalResult (..)
  , parseExpression
  , evaluate
  ) where

import Data.Char (isAsciiLower, isAsciiUpper, isDigit, isSpace)
import Data.Fixed (mod')

data AstNode
  = NumberNode Double
  | VariableNode String
  | BinaryOp String AstNode AstNode
  | UnaryOp String AstNode
  | FunctionCall String [AstNode]
  deriving (Eq, Show)

data Variable = Variable
  { variableName  :: String
  , variableValue :: Double
  } deriving (Eq, Show)

data EvalStatus
  = Ok
  | DivByZero
  | UndefinedVar
  | InvalidOp
  | DomainError
  deriving (Eq, Show)

data EvalResult = EvalResult
  { evalStatus :: EvalStatus
  , evalValue  :: Double
  } deriving (Eq, Show)

-- Parser -------------------------------------------------------------------

type Parser a = String -> Maybe (a, String)

skipWs :: String -> String
skipWs = dropWhile isSpace

isIdentStart :: Char -> Bool
isIdentStart c = isAsciiUpper c || isAsciiLower c || c == '_'

isIdentChar :: Char -> Bool
isIdentChar c = isIdentStart c || isDigit c

parseExpression :: String -> Maybe AstNode
parseExpression str = case parseExpr str of
  Just (e, r) | all isSpace r -> Just e
  _                           -> Nothing

binChain :: String -> Parser AstNode -> Parser AstNode
binChain ops sub s = sub s >>= uncurry loop
  where
    loop lhs r = case skipWs r of
      (c:rest) | c `elem` ops -> do
        (rhs, r') <- sub rest
        loop (BinaryOp [c] lhs rhs) r'
      _ -> Just (lhs, r)

parseExpr :: Parser AstNode
parseExpr = binChain "+-" parseTerm

parseTerm :: Parser AstNode
parseTerm = binChain "*/%" parseUnary

parseUnary :: Parser AstNode
parseUnary s = case skipWs s of
  (c:rest) | c `elem` "+-" -> do
    (e, r) <- parseUnary rest
    Just (UnaryOp [c] e, r)
  _ -> parsePower s

parsePower :: Parser AstNode
parsePower s = do
  (p, r) <- parsePrimary s
  case skipWs r of
    ('^':rest) -> do
      (e, r') <- parseUnary rest
      Just (BinaryOp "^" p e, r')
    _ -> Just (p, r)

parsePrimary :: Parser AstNode
parsePrimary s = case skipWs s of
  [] -> Nothing
  str@(c:_)
    | isDigit c -> parseNumber str
    | isIdentStart c -> parseIdent str
    | c == '(' -> do
        (e, r) <- parseExpr (tail str)
        case skipWs r of
          (')':r') -> Just (e, r')
          _        -> Nothing
    | otherwise -> Nothing

parseNumber :: Parser AstNode
parseNumber s =
  let (ip, r1) = span isDigit s
  in case r1 of
       ('.':t) ->
         let (fp, r2) = span isDigit t
         in if null fp
              then Nothing
              else Just (NumberNode (read (ip ++ "." ++ fp)), r2)
       _ -> Just (NumberNode (read ip), r1)

parseIdent :: Parser AstNode
parseIdent s =
  let (name, r) = span isIdentChar s
  in case skipWs r of
       ('(':rest) -> do
         (args, r') <- parseArgs rest
         if arityOk name (length args)
           then Just (FunctionCall name args, r')
           else Nothing
       _ -> Just (VariableNode name, r)

parseArgs :: Parser [AstNode]
parseArgs s = do
  (e, r) <- parseExpr s
  case skipWs r of
    (',':rest) -> do
      (es, r') <- parseArgs rest
      Just (e : es, r')
    (')':rest) -> Just ([e], rest)
    _          -> Nothing

arityOk :: String -> Int -> Bool
arityOk name n = lookup name table == Just n
  where
    table =
      [ ("sqrt", 1), ("abs", 1), ("sin", 1), ("cos", 1)
      , ("min", 2), ("max", 2), ("pow", 2)
      ]

-- Evaluator ----------------------------------------------------------------

evaluate :: AstNode -> [Variable] -> EvalResult
evaluate node vars = case evalE vars node of
  Left st -> EvalResult st 0
  Right v -> EvalResult Ok v

evalE :: [Variable] -> AstNode -> Either EvalStatus Double
evalE _ (NumberNode n) = Right n
evalE vars (VariableNode name) =
  case lookup name [(variableName v, variableValue v) | v <- vars] of
    Just x  -> Right x
    Nothing -> Left UndefinedVar
evalE vars (UnaryOp op e) = do
  x <- evalE vars e
  case op of
    "-" -> Right (negate x)
    "+" -> Right x
    _   -> Left InvalidOp
evalE vars (BinaryOp op a b) = do
  x <- evalE vars a
  y <- evalE vars b
  binOp op x y
evalE vars (FunctionCall name args) = do
  vs <- mapM (evalE vars) args
  callFn name vs

binOp :: String -> Double -> Double -> Either EvalStatus Double
binOp "+" x y = Right (x + y)
binOp "-" x y = Right (x - y)
binOp "*" x y = Right (x * y)
binOp "/" x y
  | y == 0    = Left DivByZero
  | otherwise = Right (x / y)
binOp "%" x y
  | y == 0    = Left DivByZero
  | otherwise = Right (fmod x y)
binOp "^" x y = powD x y
binOp _ _ _ = Left InvalidOp

-- C-style fmod: result has the sign of the dividend.
fmod :: Double -> Double -> Double
fmod x y = signum x * (abs x `mod'` abs y)

powD :: Double -> Double -> Either EvalStatus Double
powD x y =
  let r = x ** y
  in if isNaN r || isInfinite r
       then Left DomainError
       else Right r

callFn :: String -> [Double] -> Either EvalStatus Double
callFn "sqrt" [a]
  | a < 0     = Left DomainError
  | otherwise = Right (sqrt a)
callFn "abs" [a] = Right (abs a)
callFn "sin" [a] = Right (sin a)
callFn "cos" [a] = Right (cos a)
callFn "min" [a, b] = Right (min a b)
callFn "max" [a, b] = Right (max a b)
callFn "pow" [a, b] = powD a b
callFn _ _ = Left InvalidOp
