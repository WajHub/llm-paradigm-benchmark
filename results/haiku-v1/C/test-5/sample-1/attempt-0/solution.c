#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "expression.h"

typedef enum {
    NODE_NUM,
    NODE_VAR,
    NODE_UNARY,
    NODE_BINARY,
    NODE_CALL
} NodeKind;

typedef enum {
    FN_SQRT,
    FN_ABS,
    FN_SIN,
    FN_COS,
    FN_MIN,
    FN_MAX,
    FN_POW
} FuncId;

struct AstNode {
    NodeKind kind;
    double num;
    char *name;
    char op;
    int func;
    int nchild;
    AstNode *child[2];
};

typedef struct {
    const char *s;
    size_t i;
} Parser;

static AstNode *new_node(NodeKind kind) {
    AstNode *n = (AstNode *)calloc(1, sizeof(AstNode));
    if (n) n->kind = kind;
    return n;
}

static AstNode *make_unary(char op, AstNode *operand) {
    AstNode *n = new_node(NODE_UNARY);
    if (!n) {
        free_ast(operand);
        return NULL;
    }
    n->op = op;
    n->nchild = 1;
    n->child[0] = operand;
    return n;
}

static AstNode *make_binary(char op, AstNode *l, AstNode *r) {
    AstNode *n = new_node(NODE_BINARY);
    if (!n) {
        free_ast(l);
        free_ast(r);
        return NULL;
    }
    n->op = op;
    n->nchild = 2;
    n->child[0] = l;
    n->child[1] = r;
    return n;
}

static void skip_ws(Parser *p) {
    while (p->s[p->i] && isspace((unsigned char)p->s[p->i])) p->i++;
}

static AstNode *parse_expr(Parser *p);

static AstNode *parse_primary(Parser *p) {
    skip_ws(p);
    char c = p->s[p->i];

    if (isdigit((unsigned char)c) ||
        (c == '.' && isdigit((unsigned char)p->s[p->i + 1]))) {
        size_t j = p->i;
        while (isdigit((unsigned char)p->s[j])) j++;
        if (p->s[j] == '.') {
            j++;
            while (isdigit((unsigned char)p->s[j])) j++;
        }
        size_t len = j - p->i;
        char *buf = (char *)malloc(len + 1);
        if (!buf) return NULL;
        memcpy(buf, p->s + p->i, len);
        buf[len] = '\0';
        AstNode *n = new_node(NODE_NUM);
        if (!n) {
            free(buf);
            return NULL;
        }
        n->num = strtod(buf, NULL);
        free(buf);
        p->i = j;
        return n;
    }

    if (isalpha((unsigned char)c) || c == '_') {
        size_t start = p->i;
        size_t j = start;
        while (isalnum((unsigned char)p->s[j]) || p->s[j] == '_') j++;
        size_t len = j - start;
        char *name = (char *)malloc(len + 1);
        if (!name) return NULL;
        memcpy(name, p->s + start, len);
        name[len] = '\0';
        p->i = j;
        skip_ws(p);

        if (p->s[p->i] == '(') {
            int func = -1;
            int arity = 0;
            if (strcmp(name, "sqrt") == 0) { func = FN_SQRT; arity = 1; }
            else if (strcmp(name, "abs") == 0) { func = FN_ABS; arity = 1; }
            else if (strcmp(name, "sin") == 0) { func = FN_SIN; arity = 1; }
            else if (strcmp(name, "cos") == 0) { func = FN_COS; arity = 1; }
            else if (strcmp(name, "min") == 0) { func = FN_MIN; arity = 2; }
            else if (strcmp(name, "max") == 0) { func = FN_MAX; arity = 2; }
            else if (strcmp(name, "pow") == 0) { func = FN_POW; arity = 2; }
            free(name);
            if (func < 0) return NULL;

            p->i++; /* consume '(' */
            AstNode *args[2] = {NULL, NULL};
            int argc = 0;
            int ok = 1;

            AstNode *a = parse_expr(p);
            if (!a) {
                ok = 0;
            } else {
                args[argc++] = a;
                skip_ws(p);
                while (ok && p->s[p->i] == ',') {
                    p->i++;
                    if (argc >= 2) { ok = 0; break; }
                    AstNode *b = parse_expr(p);
                    if (!b) { ok = 0; break; }
                    args[argc++] = b;
                    skip_ws(p);
                }
            }
            if (ok) {
                skip_ws(p);
                if (p->s[p->i] != ')') ok = 0;
                else p->i++;
            }
            if (ok && argc != arity) ok = 0;
            if (!ok) {
                free_ast(args[0]);
                free_ast(args[1]);
                return NULL;
            }
            AstNode *n = new_node(NODE_CALL);
            if (!n) {
                free_ast(args[0]);
                free_ast(args[1]);
                return NULL;
            }
            n->func = func;
            n->nchild = argc;
            n->child[0] = args[0];
            n->child[1] = args[1];
            return n;
        }

        AstNode *n = new_node(NODE_VAR);
        if (!n) {
            free(name);
            return NULL;
        }
        n->name = name;
        return n;
    }

    if (c == '(') {
        p->i++;
        AstNode *e = parse_expr(p);
        if (!e) return NULL;
        skip_ws(p);
        if (p->s[p->i] != ')') {
            free_ast(e);
            return NULL;
        }
        p->i++;
        return e;
    }

    return NULL;
}

static AstNode *parse_unary(Parser *p);

static AstNode *parse_power(Parser *p) {
    AstNode *base = parse_primary(p);
    if (!base) return NULL;
    skip_ws(p);
    if (p->s[p->i] == '^') {
        p->i++;
        AstNode *ex = parse_unary(p);
        if (!ex) {
            free_ast(base);
            return NULL;
        }
        return make_binary('^', base, ex);
    }
    return base;
}

static AstNode *parse_unary(Parser *p) {
    skip_ws(p);
    char c = p->s[p->i];
    if (c == '+' || c == '-') {
        p->i++;
        AstNode *operand = parse_unary(p);
        if (!operand) return NULL;
        return make_unary(c, operand);
    }
    return parse_power(p);
}

static AstNode *parse_term(Parser *p) {
    AstNode *left = parse_unary(p);
    if (!left) return NULL;
    for (;;) {
        skip_ws(p);
        char c = p->s[p->i];
        if (c == '*' || c == '/' || c == '%') {
            p->i++;
            AstNode *right = parse_unary(p);
            if (!right) {
                free_ast(left);
                return NULL;
            }
            left = make_binary(c, left, right);
            if (!left) return NULL;
        } else {
            break;
        }
    }
    return left;
}

static AstNode *parse_expr(Parser *p) {
    AstNode *left = parse_term(p);
    if (!left) return NULL;
    for (;;) {
        skip_ws(p);
        char c = p->s[p->i];
        if (c == '+' || c == '-') {
            p->i++;
            AstNode *right = parse_term(p);
            if (!right) {
                free_ast(left);
                return NULL;
            }
            left = make_binary(c, left, right);
            if (!left) return NULL;
        } else {
            break;
        }
    }
    return left;
}

AstNode *parse_expression(const char *expression) {
    if (!expression || expression[0] == '\0') return NULL;
    Parser p;
    p.s = expression;
    p.i = 0;
    AstNode *root = parse_expr(&p);
    if (!root) return NULL;
    skip_ws(&p);
    if (p.s[p.i] != '\0') {
        free_ast(root);
        return NULL;
    }
    return root;
}

static EvalResult make_result(EvalStatus st, double v) {
    EvalResult r;
    r.status = st;
    r.value = (st == EVAL_OK) ? v : 0.0;
    return r;
}

static EvalResult checked_pow(double x, double y) {
    double r = pow(x, y);
    if (!isfinite(r)) return make_result(EVAL_DOMAIN_ERROR, 0.0);
    return make_result(EVAL_OK, r);
}

static EvalResult eval_node(const AstNode *n, const Variable *vars, int var_count) {
    EvalResult res;
    switch (n->kind) {
    case NODE_NUM:
        return make_result(EVAL_OK, n->num);

    case NODE_VAR: {
        int i;
        for (i = 0; i < var_count; i++) {
            if (vars[i].name && n->name && strcmp(vars[i].name, n->name) == 0)
                return make_result(EVAL_OK, vars[i].value);
        }
        return make_result(EVAL_UNDEFINED_VAR, 0.0);
    }

    case NODE_UNARY: {
        res = eval_node(n->child[0], vars, var_count);
        if (res.status != EVAL_OK) return res;
        if (n->op == '-') return make_result(EVAL_OK, -res.value);
        if (n->op == '+') return make_result(EVAL_OK, res.value);
        return make_result(EVAL_INVALID_OP, 0.0);
    }

    case NODE_BINARY: {
        EvalResult l = eval_node(n->child[0], vars, var_count);
        if (l.status != EVAL_OK) return l;
        EvalResult r = eval_node(n->child[1], vars, var_count);
        if (r.status != EVAL_OK) return r;
        switch (n->op) {
        case '+': return make_result(EVAL_OK, l.value + r.value);
        case '-': return make_result(EVAL_OK, l.value - r.value);
        case '*': return make_result(EVAL_OK, l.value * r.value);
        case '/':
            if (r.value == 0.0) return make_result(EVAL_DIV_BY_ZERO, 0.0);
            return make_result(EVAL_OK, l.value / r.value);
        case '%':
            if (r.value == 0.0) return make_result(EVAL_DIV_BY_ZERO, 0.0);
            return make_result(EVAL_OK, fmod(l.value, r.value));
        case '^':
            return checked_pow(l.value, r.value);
        default:
            return make_result(EVAL_INVALID_OP, 0.0);
        }
    }

    case NODE_CALL: {
        EvalResult a = eval_node(n->child[0], vars, var_count);
        if (a.status != EVAL_OK) return a;
        if (n->nchild == 1) {
            switch (n->func) {
            case FN_SQRT:
                if (a.value < 0.0) return make_result(EVAL_DOMAIN_ERROR, 0.0);
                return make_result(EVAL_OK, sqrt(a.value));
            case FN_ABS:
                return make_result(EVAL_OK, fabs(a.value));
            case FN_SIN:
                return make_result(EVAL_OK, sin(a.value));
            case FN_COS:
                return make_result(EVAL_OK, cos(a.value));
            default:
                return make_result(EVAL_INVALID_OP, 0.0);
            }
        } else {
            EvalResult b = eval_node(n->child[1], vars, var_count);
            if (b.status != EVAL_OK) return b;
            switch (n->func) {
            case FN_MIN:
                return make_result(EVAL_OK, a.value < b.value ? a.value : b.value);
            case FN_MAX:
                return make_result(EVAL_OK, a.value > b.value ? a.value : b.value);
            case FN_POW:
                return checked_pow(a.value, b.value);
            default:
                return make_result(EVAL_INVALID_OP, 0.0);
            }
        }
    }
    }
    return make_result(EVAL_INVALID_OP, 0.0);
}

EvalResult evaluate(const AstNode *ast, const Variable *vars, int var_count) {
    if (!ast) return make_result(EVAL_INVALID_OP, 0.0);
    if (var_count < 0) var_count = 0;
    return eval_node(ast, vars, var_count);
}

void free_ast(AstNode *ast) {
    if (!ast) return;
    free_ast(ast->child[0]);
    free_ast(ast->child[1]);
    free(ast->name);
    free(ast);
}
