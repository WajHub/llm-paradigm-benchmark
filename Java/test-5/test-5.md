# Test 5

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a mathematical expression parser and evaluator in Java in the class
ExpressionImpl (file ExpressionImpl.java), which extends the abstract class Expression.
The parser turns a string into an abstract syntax tree (Expression.AstNode), and the
evaluator computes the numeric value of that AST given a set of variables. The base
class already defines the data types; implement parse and evaluate.

- Implement `AstNode parse(String expression)`: Parse the input string and return the
  root AST node, or null if the string is not a syntactically valid expression.
  Whitespace is insignificant. You may define your own concrete AstNode subclasses.

  Grammar (highest precedence last; `^` is right-associative, everything else is
  left-associative):

      expr    := term   (('+' | '-') term)*
      term    := unary  (('*' | '/' | '%') unary)*
      unary   := ('+' | '-') unary | power
      power   := primary ('^' unary)?
      primary := NUMBER | IDENT | IDENT '(' args ')' | '(' expr ')'
      args    := expr (',' expr)*

  * NUMBER: a non-negative decimal literal, e.g. `42` or `3.14`.
  * IDENT: a variable name matching `[A-Za-z_][A-Za-z0-9_]*`.
  * A call `IDENT '(' args ')'` is only valid for these functions, with the exact
    argument count shown: `sqrt`/1, `abs`/1, `sin`/1, `cos`/1, `min`/2, `max`/2,
    `pow`/2. Any other function name, or a wrong number of arguments, is a parse
    error (null).
  * Precedence consequences: `-2^2` parses as `-(2^2)` and `2^3^2` as `2^(3^2)`.

- Implement `EvalResult evaluate(AstNode ast, List<Variable> vars)`: Evaluate the AST
  using the given variable bindings and return an EvalResult(status, value). If any
  sub-expression produces a non-OK status, propagate the first such status upward
  (short-circuit) and leave value at 0.0.

  Semantics:
  * A number evaluates to its literal value with status OK.
  * A variable evaluates to its bound value, or UNDEFINED_VAR if no binding with that
    name exists.
  * Unary '-' negates, unary '+' is identity.
  * '+' '-' '*' are ordinary arithmetic.
  * '/' and '%' return DIV_BY_ZERO when the divisor is 0. '%' is the floating-point
    remainder.
  * '^' and pow(x, y) compute x raised to y; if the result is not a finite real number
    (e.g. a negative base with a non-integer exponent), return DOMAIN_ERROR.
  * sqrt(x) returns DOMAIN_ERROR when x < 0.
  * abs, sin, cos, min, max behave as usual (angles in radians).

Constraints:
  - parse(null) and parse("") must return null.
  - Floating-point results are compared with a small epsilon tolerance.
```
