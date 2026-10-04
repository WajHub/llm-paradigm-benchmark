#include "expression.h"
#include <stdlib.h>

AstNode* parse_expression(const char* expression) {
    (void)expression;
    return NULL;
}

EvalResult evaluate(const AstNode* ast, const Variable* vars, int var_count) {
    (void)ast; (void)vars; (void)var_count;
    EvalResult r = { EVAL_INVALID_OP, 0.0 };
    return r;
}

void free_ast(AstNode* ast) {
    (void)ast;
}
