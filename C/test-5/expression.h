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
