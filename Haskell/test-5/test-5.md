# Test 5

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a mathematical expression parser and evaluator in Haskell in the module
Expression (file Expression.hs). The parser turns a string into an abstract syntax
tree (AstNode), and the evaluator computes the numeric value of that AST given a set
of variables. The module already defines the data types; implement parseExpression
and evaluate.

- Implement `parseExpression :: String -> Maybe AstNode`: Parse the input string and
  return `Just` the AST, or `Nothing` if the string is not a syntactically valid
  expression. Whitespace is insignificant.

  Grammar (highest precedence last; `^` is right-associative, everything else is
  left-associative):

      expr    := term   (('+' | '-') term)*
      term    := unary  (('*' | '/' | '%') unary)*
      unary   := ('+' | '-') unary | power
      power   := primary ('^' unary)?
      primary := NUMBER | IDENT | IDENT '(' args ')' | '(' expr ')'
      args    := expr (',' expr)*

  * NUMBER: a non-negative decimal literal, e.g. `42` or `3.14`, mapped to NumberNode.
  * IDENT: a variable name matching `[A-Za-z_][A-Za-z0-9_]*`, mapped to VariableNode.
  * A call `IDENT '(' args ')'` is only valid for these functions, with the exact
    argument count shown: `sqrt`/1, `abs`/1, `sin`/1, `cos`/1, `min`/2, `max`/2,
    `pow`/2, mapped to FunctionCall. Any other function name, or a wrong number of
    arguments, is a parse error (Nothing).
  * Precedence consequences: `-2^2` parses as `-(2^2)` and `2^3^2` as `2^(3^2)`.

- Implement `evaluate :: AstNode -> [Variable] -> EvalResult`: Evaluate the AST using
  the given variable bindings and return an `EvalResult { evalStatus, evalValue }`.
  If any sub-expression produces a non-Ok status, propagate the first such status
  upward (short-circuit) and leave evalValue at 0.0.

  Semantics:
  * NumberNode evaluates to its literal value with status Ok.
  * VariableNode evaluates to its bound value, or UndefinedVar if no binding with
    that name exists.
  * UnaryOp "-" negates, UnaryOp "+" is identity.
  * BinaryOp "+" "-" "*" are ordinary arithmetic.
  * BinaryOp "/" and "%" return DivByZero when the divisor is 0. "%" is the
    floating-point remainder.
  * BinaryOp "^" and FunctionCall "pow" compute x raised to y; if the result is not a
    finite real number (e.g. a negative base with a non-integer exponent), return
    DomainError.
  * FunctionCall "sqrt" returns DomainError when its argument is < 0.
  * "abs", "sin", "cos", "min", "max" behave as usual (angles in radians).

Constraints:
  - parseExpression "" must return Nothing.
  - Floating-point results are compared with a small epsilon tolerance.
```
