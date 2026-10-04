#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include "expression.h"

#define EPS 1e-9

// Helper: parse + evaluate with the given variables, return the EvalResult.
// Frees the AST afterwards. If parsing fails, returns status EVAL_INVALID_OP.
static EvalResult eval_str(const char* expr, const Variable* vars, int var_count) {
    AstNode* ast = parse_expression(expr);
    if (!ast) {
        EvalResult r = { EVAL_INVALID_OP, 0.0 };
        return r;
    }
    EvalResult r = evaluate(ast, vars, var_count);
    free_ast(ast);
    return r;
}

static bool value_ok(EvalResult r, double expected) {
    return r.status == EVAL_OK && fabs(r.value - expected) < EPS;
}

// ============================================================================
// TESTY Algorytmu A: parse_expression (syntactic validity / AST construction)
// ============================================================================

bool test_algo_a_01_single_number() {
    AstNode* ast = parse_expression("42");
    bool passed = (ast != NULL);
    free_ast(ast);
    return passed;
}

bool test_algo_a_02_simple_binary() {
    AstNode* ast = parse_expression("1 + 2 * 3");
    bool passed = (ast != NULL);
    free_ast(ast);
    return passed;
}

bool test_algo_a_03_parentheses() {
    AstNode* ast = parse_expression("2 * (3 + 4) - 5");
    bool passed = (ast != NULL);
    free_ast(ast);
    return passed;
}

bool test_algo_a_04_function_call() {
    AstNode* ast = parse_expression("sqrt(16) + max(1, 2)");
    bool passed = (ast != NULL);
    free_ast(ast);
    return passed;
}

bool test_algo_a_05_nested_and_unary() {
    AstNode* ast = parse_expression("-min(max(1, 2), 3) + -(4)");
    bool passed = (ast != NULL);
    free_ast(ast);
    return passed;
}

bool test_algo_a_06_null_input() {
    return parse_expression(NULL) == NULL;
}

bool test_algo_a_07_empty_string() {
    return parse_expression("") == NULL;
}

bool test_algo_a_08_unbalanced_parens() {
    return parse_expression("(1 + 2") == NULL;
}

bool test_algo_a_09_trailing_garbage() {
    return parse_expression("1 + 2)") == NULL
        && parse_expression("3 4") == NULL;
}

bool test_algo_a_10_bad_function() {
    // unknown function and wrong arity are both parse errors
    return parse_expression("foo(1)") == NULL
        && parse_expression("sqrt(1, 2)") == NULL
        && parse_expression("max(1)") == NULL;
}

// ============================================================================
// TESTY Algorytmu B: evaluate (numeric value + error statuses)
// ============================================================================

bool test_algo_b_01_precedence() {
    return value_ok(eval_str("3 + 4 * 2", NULL, 0), 11.0);
}

bool test_algo_b_02_parens_override() {
    return value_ok(eval_str("(3 + 4) * 2", NULL, 0), 14.0);
}

bool test_algo_b_03_power_right_assoc() {
    // 2^(3^2) = 2^9 = 512
    return value_ok(eval_str("2 ^ 3 ^ 2", NULL, 0), 512.0);
}

bool test_algo_b_04_unary_vs_power() {
    // -2^2 parses as -(2^2) = -4
    return value_ok(eval_str("-2 ^ 2", NULL, 0), -4.0);
}

bool test_algo_b_05_variables() {
    Variable vars[] = { { "x", 3.0 }, { "y", 4.0 } };
    return value_ok(eval_str("x * x + y * y", vars, 2), 25.0);
}

bool test_algo_b_06_undefined_var() {
    EvalResult r = eval_str("x + 1", NULL, 0);
    return r.status == EVAL_UNDEFINED_VAR;
}

bool test_algo_b_07_div_and_mod() {
    bool ok = value_ok(eval_str("10 % 3", NULL, 0), 1.0);
    EvalResult r = eval_str("5 / 0", NULL, 0);
    return ok && r.status == EVAL_DIV_BY_ZERO;
}

bool test_algo_b_08_functions() {
    bool a = value_ok(eval_str("max(3, 7) + min(2, 5)", NULL, 0), 9.0);
    bool b = value_ok(eval_str("abs(-5) + sqrt(9)", NULL, 0), 8.0);
    bool c = value_ok(eval_str("pow(2, 10)", NULL, 0), 1024.0);
    return a && b && c;
}

bool test_algo_b_09_domain_error() {
    EvalResult r = eval_str("sqrt(-1)", NULL, 0);
    return r.status == EVAL_DOMAIN_ERROR;
}

bool test_algo_b_10_error_propagation() {
    // a division-by-zero deep inside must bubble up
    Variable vars[] = { { "x", 2.0 } };
    EvalResult r = eval_str("x + 1 / (x - 2)", vars, 1);
    return r.status == EVAL_DIV_BY_ZERO;
}

int main() {
    int failed_count = 0;
    const char* failed_tests[50];
    int total_tests = 0;

    #define RUN_TEST(func, name) \
        do { \
            total_tests++; \
            if (func()) { \
                printf("[PASS] %s\n", name); \
            } else { \
                printf("[FAIL] %s\n", name); \
                failed_tests[failed_count++] = name; \
            } \
        } while (0)

    printf("=== START ===\n");

    printf("\n--- Algorithm A: Parsing & AST Construction ---\n");
    RUN_TEST(test_algo_a_01_single_number,     "Test A01 (Single Number)");
    RUN_TEST(test_algo_a_02_simple_binary,     "Test A02 (Binary + Precedence)");
    RUN_TEST(test_algo_a_03_parentheses,       "Test A03 (Parentheses)");
    RUN_TEST(test_algo_a_04_function_call,     "Test A04 (Function Calls)");
    RUN_TEST(test_algo_a_05_nested_and_unary,  "Test A05 (Nested + Unary)");
    RUN_TEST(test_algo_a_06_null_input,        "Test A06 (NULL Input)");
    RUN_TEST(test_algo_a_07_empty_string,      "Test A07 (Empty String)");
    RUN_TEST(test_algo_a_08_unbalanced_parens, "Test A08 (Unbalanced Parens)");
    RUN_TEST(test_algo_a_09_trailing_garbage,  "Test A09 (Trailing Garbage)");
    RUN_TEST(test_algo_a_10_bad_function,      "Test A10 (Bad Function Call)");

    printf("\n--- Algorithm B: Evaluation & Error Semantics ---\n");
    RUN_TEST(test_algo_b_01_precedence,        "Test B01 (Operator Precedence)");
    RUN_TEST(test_algo_b_02_parens_override,   "Test B02 (Parentheses Override)");
    RUN_TEST(test_algo_b_03_power_right_assoc, "Test B03 (Power Right-Assoc)");
    RUN_TEST(test_algo_b_04_unary_vs_power,    "Test B04 (Unary vs Power)");
    RUN_TEST(test_algo_b_05_variables,         "Test B05 (Variables)");
    RUN_TEST(test_algo_b_06_undefined_var,     "Test B06 (Undefined Variable)");
    RUN_TEST(test_algo_b_07_div_and_mod,       "Test B07 (Division & Modulo)");
    RUN_TEST(test_algo_b_08_functions,         "Test B08 (Built-in Functions)");
    RUN_TEST(test_algo_b_09_domain_error,      "Test B09 (Domain Error)");
    RUN_TEST(test_algo_b_10_error_propagation, "Test B10 (Error Propagation)");

    printf("\n=== BENCHMARK RESULTS ===\n");
    printf("Completed %d tests.\n", total_tests);

    if (failed_count == 0) {
        printf("All tests passed!\n");
        return 0;
    } else {
        printf("Tests that failed (%d):\n", failed_count);
        for (int i = 0; i < failed_count; i++) {
            printf(" - %s\n", failed_tests[i]);
        }
        return 1;
    }
}
