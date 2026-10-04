# Test 5

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a mathematical expression parser and evaluator in GNU Smalltalk in the class
ExpressionImpl (file ExpressionImpl.st), which subclasses the abstract class Expression.
The parser turns a string into an abstract syntax tree (AstNode), and the evaluator
computes the numeric value of that AST given a collection of variables. The supporting
classes (AstNode, ExprVariable, EvalResult, Expression) are already defined; implement
parseExpression: and evaluate:vars:.

- Implement `parseExpression: aString`: Parse the string and return the root AstNode,
  or nil if the string is not a syntactically valid expression. Whitespace is
  insignificant. You may populate AstNode (kind/numValue/strValue/children) however you
  like; the tests only call parseExpression: and evaluate:vars:.

  Grammar (highest precedence last; `^` is right-associative, everything else is
  left-associative):

      expr    := term   (('+' | '-') term)*
      term    := unary  (('*' | '/' | '%') unary)*
      unary   := ('+' | '-') unary | power
      power   := primary ('^' unary)?
      primary := NUMBER | IDENT | IDENT '(' args ')' | '(' expr ')'
      args    := expr (',' expr)*

  * NUMBER: a non-negative decimal literal, e.g. 42 or 3.14.
  * IDENT: a variable name matching [A-Za-z_][A-Za-z0-9_]*.
  * A call IDENT '(' args ')' is only valid for these functions, with the exact
    argument count shown: sqrt/1, abs/1, sin/1, cos/1, min/2, max/2, pow/2. Any other
    function name, or a wrong number of arguments, is a parse error (nil).
  * Precedence consequences: -2^2 parses as -(2^2) and 2^3^2 as 2^(3^2).

- Implement `evaluate: ast vars: aCollection`: Evaluate the AST using the given
  ExprVariable bindings (each responds to #name and #value) and return an EvalResult
  (built with `EvalResult status: aSymbol value: aNumber`). Use these status symbols:
  #ok, #divByZero, #undefinedVar, #invalidOp, #domainError. If any sub-expression
  produces a non-#ok status, propagate the first such status (short-circuit) with
  value 0.0.

  Semantics:
  * A number evaluates to its literal value with status #ok.
  * A variable evaluates to its bound value, or #undefinedVar if no binding with that
    name exists.
  * Unary '-' negates, unary '+' is identity.
  * '+' '-' '*' are ordinary arithmetic.
  * '/' and '%' give #divByZero when the divisor is 0. '%' is the floating-point
    remainder.
  * '^' and pow(x, y) compute x raised to y; if the result is not a finite real number
    (e.g. a negative base with a non-integer exponent), give #domainError.
  * sqrt(x) gives #domainError when x < 0.
  * abs, sin, cos, min, max behave as usual (angles in radians).

Constraints:
  - parseExpression: '' must return nil.
  - Floating-point results are compared with a small epsilon tolerance.
```
