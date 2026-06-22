module Expression
  ( AstNode (..)
  , Variable (..)
  , EvalStatus (..)
  , EvalResult (..)
  , parseExpression
  , evaluate
  ) where

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

parseExpression :: String -> Maybe AstNode
parseExpression _ = error "Expression.parseExpression not implemented"

evaluate :: AstNode -> [Variable] -> EvalResult
evaluate _ _ = error "Expression.evaluate not implemented"
