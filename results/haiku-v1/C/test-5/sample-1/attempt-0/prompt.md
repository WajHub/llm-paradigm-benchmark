You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

Implement a mathematical expression parser and evaluator in C using the header
file expression.h. The parser turns a string into an abstract syntax tree (AST),
and the evaluator computes the numeric value of that AST given a set of variables.

- Implement `parse_expression`: Parse the input string into an AST and return a
  pointer to its root node. Return NULL if the string is not a syntactically valid
  expression. Whitespace is insignificant.

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
    error (return NULL).
  * Precedence consequences: `-2^2` parses as `-(2^2)` and `2^3^2` as `2^(3^2)`.

- Implement `evaluate`: Evaluate the AST using the variable bindings in `vars`
  (an array of `var_count` entries). Return an `EvalResult` with a `status` and a
  `value`. If any sub-expression produces a non-OK status, propagate the first such
  status upward (short-circuit) and leave `value` at 0.0.

  Semantics:
  * Numbers evaluate to their literal value with status EVAL_OK.
  * A variable evaluates to its bound value, or EVAL_UNDEFINED_VAR if no binding
    with that name exists.
  * Unary `-` negates, unary `+` is identity.
  * `+ - *` are ordinary arithmetic.
  * `/` and `%` return EVAL_DIV_BY_ZERO when the divisor is 0. `%` is floating-point
    remainder (fmod).
  * `^` and `pow(x, y)` compute x raised to y; if the result is not a finite real
    number (e.g. a negative base with a non-integer exponent), return
    EVAL_DOMAIN_ERROR.
  * `sqrt(x)` returns EVAL_DOMAIN_ERROR when x < 0.
  * `abs`, `sin`, `cos`, `min`, `max` behave as usual (angles in radians).

- Implement `free_ast`: Free all memory owned by the AST. `free_ast(NULL)` is a
  no-op. Must not leak memory (verified by valgrind).

Constraints:
  - `parse_expression(NULL)` and `parse_expression("")` must return NULL.
  - Floating-point results are compared with a small epsilon tolerance.
  - All functions must handle their edge cases without crashing.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

#ifndef EXPRESSION_H
#define EXPRESSION_H

typedef struct AstNode AstNode;

typedef enum {
    EVAL_OK,
    EVAL_DIV_BY_ZERO,
    EVAL_UNDEFINED_VAR,
    EVAL_INVALID_OP,
    EVAL_DOMAIN_ERROR
} EvalStatus;

typedef struct {
    const char* name;
    double value;
} Variable;

typedef struct {
    EvalStatus status;
    double value;
} EvalResult;

AstNode* parse_expression(const char* expression);
EvalResult evaluate(const AstNode* ast, const Variable* vars, int var_count);
void free_ast(AstNode* ast);

#endif