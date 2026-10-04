# Test 5

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a mathematical expression parser and evaluator in SWI-Prolog in the module
expression (file expression.pl). The parser turns a string into an abstract syntax
tree, and the evaluator computes the numeric value of that AST given a set of
variables. Implement parse_expression/2 and evaluate/3.

- Implement `parse_expression(+Expr, -Ast)`: Parse the atom Expr and unify Ast with
  the parse tree, or with the atom `none` if Expr is not a syntactically valid
  expression. Whitespace is insignificant.

  AST representation:
      number(Value)
      variable(Name)                      % Name is an atom
      binary_op(Op, Left, Right)          % Op: '+' '-' '*' '/' '%' '^'
      unary_op(Op, Operand)               % Op: '+' '-'
      function_call(Name, ArgsList)       % Name: sqrt abs sin cos min max pow

  Grammar (highest precedence last; `^` is right-associative, everything else is
  left-associative):

      expr    := term   (('+' | '-') term)*
      term    := unary  (('*' | '/' | '%') unary)*
      unary   := ('+' | '-') unary | power
      power   := primary ('^' unary)?
      primary := NUMBER | IDENT | IDENT '(' args ')' | '(' expr ')'
      args    := expr (',' expr)*

  * NUMBER: a non-negative decimal literal, e.g. 42 or 3.14.
  * IDENT: a name matching [A-Za-z_][A-Za-z0-9_]*.
  * A call IDENT '(' args ')' is only valid for these functions, with the exact arity
    shown: sqrt/1, abs/1, sin/1, cos/1, min/2, max/2, pow/2. Any other function name,
    or a wrong number of arguments, is a parse error (none).
  * Precedence consequences: -2^2 parses as -(2^2) and 2^3^2 as 2^(3^2).

- Implement `evaluate(+Ast, +Vars, -Result)`: Evaluate the AST and unify Result with a
  term `result(Status, Value)`. Vars is a list of `Name-Value` pairs (e.g. [x-3.0,
  y-4.0]). If any sub-expression produces a non-ok status, propagate the first such
  status (short-circuit) with Value 0.0.

  Statuses and semantics:
  * number(V) evaluates to result(ok, V).
  * variable(Name) evaluates to its bound value, or result(undefined_var, 0.0) if it
    is not in Vars.
  * unary_op('-', X) negates; unary_op('+', X) is identity.
  * '+' '-' '*' are ordinary arithmetic.
  * '/' and '%' give result(div_by_zero, 0.0) when the divisor is 0. '%' is the
    floating-point remainder.
  * '^' and pow(X, Y) compute X raised to Y; if the result is not a finite real number
    (e.g. a negative base with a non-integer exponent), give result(domain_error, 0.0).
  * sqrt(X) gives result(domain_error, 0.0) when X < 0.
  * abs, sin, cos, min, max behave as usual (angles in radians).

Constraints:
  - parse_expression('', Ast) must unify Ast with none.
  - Floating-point results are compared with a small epsilon tolerance.
```
