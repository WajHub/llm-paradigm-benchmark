import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public final class Tests {
    private static final Expression EXPR = new ExpressionImpl();

    private Tests() {
    }

    private static Expression.EvalResult evalStr(String s, List<Expression.Variable> vars) {
        Expression.AstNode ast = EXPR.parse(s);
        if (ast == null) {
            return new Expression.EvalResult(Expression.EvalStatus.INVALID_OP, 0.0);
        }
        return EXPR.evaluate(ast, vars);
    }

    private static boolean valueOk(Expression.EvalResult r, double expected) {
        return r.status == Expression.EvalStatus.OK && Math.abs(r.value - expected) < 1e-9;
    }

    private static List<Expression.Variable> noVars() {
        return Collections.emptyList();
    }

    // ========================================================================
    // Algorithm A: parse (syntactic validity / AST construction)
    // ========================================================================

    private static boolean testAlgoA01SingleNumber() {
        try {
            return EXPR.parse("42") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SimpleBinary() {
        try {
            return EXPR.parse("1 + 2 * 3") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03Parentheses() {
        try {
            return EXPR.parse("2 * (3 + 4) - 5") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04FunctionCall() {
        try {
            return EXPR.parse("sqrt(16) + max(1, 2)") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05NestedAndUnary() {
        try {
            return EXPR.parse("-min(max(1, 2), 3) + -(4)") != null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06DanglingOperator() {
        try {
            return EXPR.parse("1 +") == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07EmptyString() {
        try {
            return EXPR.parse("") == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08UnbalancedParens() {
        try {
            return EXPR.parse("(1 + 2") == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09TrailingGarbage() {
        try {
            return EXPR.parse("1 + 2)") == null && EXPR.parse("3 4") == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10BadFunction() {
        try {
            return EXPR.parse("foo(1)") == null
                && EXPR.parse("sqrt(1, 2)") == null
                && EXPR.parse("max(1)") == null;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: evaluate (numeric value + error statuses)
    // ========================================================================

    private static boolean testAlgoB01Precedence() {
        try {
            return valueOk(evalStr("3 + 4 * 2", noVars()), 11.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02ParensOverride() {
        try {
            return valueOk(evalStr("(3 + 4) * 2", noVars()), 14.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03PowerRightAssoc() {
        try {
            return valueOk(evalStr("2 ^ 3 ^ 2", noVars()), 512.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04UnaryVsPower() {
        try {
            return valueOk(evalStr("-2 ^ 2", noVars()), -4.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05Variables() {
        try {
            List<Expression.Variable> vars = Arrays.asList(
                new Expression.Variable("x", 3.0),
                new Expression.Variable("y", 4.0));
            return valueOk(evalStr("x * x + y * y", vars), 25.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06UndefinedVar() {
        try {
            return evalStr("x + 1", noVars()).status == Expression.EvalStatus.UNDEFINED_VAR;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07DivAndMod() {
        try {
            return valueOk(evalStr("10 % 3", noVars()), 1.0)
                && evalStr("5 / 0", noVars()).status == Expression.EvalStatus.DIV_BY_ZERO;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08Functions() {
        try {
            return valueOk(evalStr("max(3, 7) + min(2, 5)", noVars()), 9.0)
                && valueOk(evalStr("abs(-5) + sqrt(9)", noVars()), 8.0)
                && valueOk(evalStr("pow(2, 10)", noVars()), 1024.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09DomainError() {
        try {
            return evalStr("sqrt(-1)", noVars()).status == Expression.EvalStatus.DOMAIN_ERROR;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10ErrorPropagation() {
        try {
            List<Expression.Variable> vars = Arrays.asList(new Expression.Variable("x", 2.0));
            return evalStr("x + 1 / (x - 2)", vars).status == Expression.EvalStatus.DIV_BY_ZERO;
        } catch (Exception e) {
            return false;
        }
    }

    private static int totalTests = 0;

    private static void runTest(String name, boolean passed, List<String> failed) {
        totalTests++;
        if (passed) {
            System.out.println("[PASS] " + name);
        } else {
            System.out.println("[FAIL] " + name);
            failed.add(name);
        }
    }

    public static void main(String[] args) {
        List<String> failed = new ArrayList<>();

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Parsing & AST Construction ---");
        runTest("Test A01 (Single Number)", testAlgoA01SingleNumber(), failed);
        runTest("Test A02 (Binary + Precedence)", testAlgoA02SimpleBinary(), failed);
        runTest("Test A03 (Parentheses)", testAlgoA03Parentheses(), failed);
        runTest("Test A04 (Function Calls)", testAlgoA04FunctionCall(), failed);
        runTest("Test A05 (Nested + Unary)", testAlgoA05NestedAndUnary(), failed);
        runTest("Test A06 (Dangling Operator)", testAlgoA06DanglingOperator(), failed);
        runTest("Test A07 (Empty String)", testAlgoA07EmptyString(), failed);
        runTest("Test A08 (Unbalanced Parens)", testAlgoA08UnbalancedParens(), failed);
        runTest("Test A09 (Trailing Garbage)", testAlgoA09TrailingGarbage(), failed);
        runTest("Test A10 (Bad Function Call)", testAlgoA10BadFunction(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Evaluation & Error Semantics ---");
        runTest("Test B01 (Operator Precedence)", testAlgoB01Precedence(), failed);
        runTest("Test B02 (Parentheses Override)", testAlgoB02ParensOverride(), failed);
        runTest("Test B03 (Power Right-Assoc)", testAlgoB03PowerRightAssoc(), failed);
        runTest("Test B04 (Unary vs Power)", testAlgoB04UnaryVsPower(), failed);
        runTest("Test B05 (Variables)", testAlgoB05Variables(), failed);
        runTest("Test B06 (Undefined Variable)", testAlgoB06UndefinedVar(), failed);
        runTest("Test B07 (Division & Modulo)", testAlgoB07DivAndMod(), failed);
        runTest("Test B08 (Built-in Functions)", testAlgoB08Functions(), failed);
        runTest("Test B09 (Domain Error)", testAlgoB09DomainError(), failed);
        runTest("Test B10 (Error Propagation)", testAlgoB10ErrorPropagation(), failed);

        System.out.println();
        System.out.println("=== BENCHMARK RESULTS ===");
        System.out.println("Completed " + totalTests + " tests.");

        if (failed.isEmpty()) {
            System.out.println("All tests passed!");
            System.exit(0);
        } else {
            System.out.println("Tests that failed (" + failed.size() + "):");
            for (String name : failed) {
                System.out.println(" - " + name);
            }
            System.exit(1);
        }
    }
}
