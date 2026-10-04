# Test 5

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a mathematical expression parser and evaluator in Free Pascal in the unit
expression (file expression.pas). The parser turns a string into an abstract syntax
tree (PAstNode), and the evaluator computes the numeric value of that AST given a set
of variables. The unit already defines the types; implement ParseExpression, Evaluate
and FreeAst.

- Implement `ParseExpression(const Expr: AnsiString): PAstNode`: Parse the input string
  and return a pointer to the root node, or nil if the string is not a syntactically
  valid expression. Whitespace is insignificant.

  Grammar (highest precedence last; `^` is right-associative, everything else is
  left-associative):

      expr    := term   (('+' | '-') term)*
      term    := unary  (('*' | '/' | '%') unary)*
      unary   := ('+' | '-') unary | power
      power   := primary ('^' unary)?
      primary := NUMBER | IDENT | IDENT '(' args ')' | '(' expr ')'
      args    := expr (',' expr)*

  * NUMBER: a non-negative decimal literal, e.g. `42` or `3.14` (TAstNodeKind ankNumber,
    stored in NumValue).
  * IDENT: a variable name matching `[A-Za-z_][A-Za-z0-9_]*` (ankVariable, name in
    StrValue).
  * A call `IDENT '(' args ')'` is only valid for these functions, with the exact
    argument count shown: `sqrt`/1, `abs`/1, `sin`/1, `cos`/1, `min`/2, `max`/2,
    `pow`/2 (ankFunction, name in StrValue, arguments in Children). Any other function
    name, or a wrong number of arguments, is a parse error (nil).
  * Binary operators are ankBinaryOp (operator in StrValue, two Children); unary +/- are
    ankUnaryOp (operator in StrValue, one Child).
  * Precedence consequences: `-2^2` parses as `-(2^2)` and `2^3^2` as `2^(3^2)`.

- Implement `Evaluate(Ast: PAstNode; const Vars: TVariableArray): TEvalResult`: Evaluate
  the AST using the given variable bindings and return a TEvalResult (Status + Value).
  If any sub-expression produces a non-esOk status, propagate the first such status
  upward (short-circuit) and leave Value at 0.0.

  Semantics:
  * A number evaluates to its literal value with status esOk.
  * A variable evaluates to its bound value, or esUndefinedVar if no binding with that
    name exists.
  * Unary '-' negates, unary '+' is identity.
  * '+' '-' '*' are ordinary arithmetic.
  * '/' and '%' return esDivByZero when the divisor is 0. '%' is the floating-point
    remainder.
  * '^' and pow(x, y) compute x raised to y; if the result is not a finite real number
    (e.g. a negative base with a non-integer exponent), return esDomainError.
  * sqrt(x) returns esDomainError when x < 0.
  * abs, sin, cos, min, max behave as usual (angles in radians).

- Implement `FreeAst(var Ast: PAstNode)`: Free the whole AST (including all Children)
  and set Ast to nil. FreeAst(nil) is a no-op.

Constraints:
  - ParseExpression('') must return nil.
  - Floating-point results are compared with a small epsilon tolerance.
```
