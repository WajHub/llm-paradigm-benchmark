import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExpressionImpl extends Expression {

    private static final Map<String, Integer> FUNCTIONS = new HashMap<>();

    static {
        FUNCTIONS.put("sqrt", 1);
        FUNCTIONS.put("abs", 1);
        FUNCTIONS.put("sin", 1);
        FUNCTIONS.put("cos", 1);
        FUNCTIONS.put("min", 2);
        FUNCTIONS.put("max", 2);
        FUNCTIONS.put("pow", 2);
    }

    @Override
    public AstNode parse(String expression) {
        if (expression == null || expression.isEmpty()) {
            return null;
        }
        try {
            List<Token> tokens = tokenize(expression);
            Parser parser = new Parser(tokens);
            Node root = parser.parseExpression();
            if (!parser.atEnd()) {
                return null;
            }
            return root;
        } catch (ParseException e) {
            return null;
        }
    }

    @Override
    public EvalResult evaluate(AstNode ast, List<Variable> vars) {
        if (!(ast instanceof Node)) {
            return new EvalResult(EvalStatus.INVALID_OP, 0.0);
        }
        List<Variable> bindings = vars == null ? Collections.<Variable>emptyList() : vars;
        return ((Node) ast).eval(bindings);
    }

    // ---------------------------------------------------------------- helpers

    private static EvalResult ok(double value) {
        return new EvalResult(EvalStatus.OK, value);
    }

    private static EvalResult error(EvalStatus status) {
        return new EvalResult(status, 0.0);
    }

    private static EvalResult checkedPow(double base, double exp) {
        double v = Math.pow(base, exp);
        if (Double.isNaN(v) || Double.isInfinite(v)) {
            return error(EvalStatus.DOMAIN_ERROR);
        }
        return ok(v);
    }

    // ---------------------------------------------------------------- tokens

    private enum Kind {
        NUMBER, IDENT, OP, LPAREN, RPAREN, COMMA, END
    }

    private static final class Token {
        final Kind kind;
        final String text;

        Token(Kind kind, String text) {
            this.kind = kind;
            this.text = text;
        }
    }

    private static final class ParseException extends RuntimeException {
        private static final long serialVersionUID = 1L;

        ParseException() {
            super(null, null, false, false);
        }
    }

    private static boolean isIdentStart(char c) {
        return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || c == '_';
    }

    private static boolean isIdentPart(char c) {
        return isIdentStart(c) || (c >= '0' && c <= '9');
    }

    private static boolean isDigit(char c) {
        return c >= '0' && c <= '9';
    }

    private static List<Token> tokenize(String s) {
        List<Token> tokens = new ArrayList<>();
        int n = s.length();
        int i = 0;
        while (i < n) {
            char c = s.charAt(i);
            if (Character.isWhitespace(c)) {
                i++;
            } else if (isDigit(c) || (c == '.' && i + 1 < n && isDigit(s.charAt(i + 1)))) {
                int start = i;
                while (i < n && isDigit(s.charAt(i))) {
                    i++;
                }
                if (i < n && s.charAt(i) == '.') {
                    i++;
                    int fracStart = i;
                    while (i < n && isDigit(s.charAt(i))) {
                        i++;
                    }
                    if (i == fracStart) {
                        throw new ParseException();
                    }
                }
                tokens.add(new Token(Kind.NUMBER, s.substring(start, i)));
            } else if (isIdentStart(c)) {
                int start = i;
                while (i < n && isIdentPart(s.charAt(i))) {
                    i++;
                }
                tokens.add(new Token(Kind.IDENT, s.substring(start, i)));
            } else if ("+-*/%^".indexOf(c) >= 0) {
                tokens.add(new Token(Kind.OP, String.valueOf(c)));
                i++;
            } else if (c == '(') {
                tokens.add(new Token(Kind.LPAREN, "("));
                i++;
            } else if (c == ')') {
                tokens.add(new Token(Kind.RPAREN, ")"));
                i++;
            } else if (c == ',') {
                tokens.add(new Token(Kind.COMMA, ","));
                i++;
            } else {
                throw new ParseException();
            }
        }
        tokens.add(new Token(Kind.END, ""));
        return tokens;
    }

    // ---------------------------------------------------------------- parser

    private static final class Parser {
        private final List<Token> tokens;
        private int pos = 0;

        Parser(List<Token> tokens) {
            this.tokens = tokens;
        }

        boolean atEnd() {
            return peek().kind == Kind.END;
        }

        private Token peek() {
            return tokens.get(pos);
        }

        private Token advance() {
            return tokens.get(pos++);
        }

        private boolean isOp(String... ops) {
            Token t = peek();
            if (t.kind != Kind.OP) {
                return false;
            }
            for (String op : ops) {
                if (t.text.equals(op)) {
                    return true;
                }
            }
            return false;
        }

        private void expect(Kind kind) {
            if (peek().kind != kind) {
                throw new ParseException();
            }
            advance();
        }

        Node parseExpression() {
            Node node = parseTerm();
            while (isOp("+", "-")) {
                char op = advance().text.charAt(0);
                Node right = parseTerm();
                node = new BinaryNode(op, node, right);
            }
            return node;
        }

        private Node parseTerm() {
            Node node = parseUnary();
            while (isOp("*", "/", "%")) {
                char op = advance().text.charAt(0);
                Node right = parseUnary();
                node = new BinaryNode(op, node, right);
            }
            return node;
        }

        private Node parseUnary() {
            if (isOp("+", "-")) {
                char op = advance().text.charAt(0);
                Node operand = parseUnary();
                return new UnaryNode(op, operand);
            }
            return parsePower();
        }

        private Node parsePower() {
            Node base = parsePrimary();
            if (isOp("^")) {
                advance();
                Node exponent = parseUnary();
                return new BinaryNode('^', base, exponent);
            }
            return base;
        }

        private Node parsePrimary() {
            Token t = peek();
            switch (t.kind) {
                case NUMBER:
                    advance();
                    return new NumberNode(Double.parseDouble(t.text));
                case IDENT: {
                    advance();
                    if (peek().kind == Kind.LPAREN) {
                        Integer arity = FUNCTIONS.get(t.text);
                        if (arity == null) {
                            throw new ParseException();
                        }
                        advance();
                        List<Node> args = new ArrayList<>();
                        args.add(parseExpression());
                        while (peek().kind == Kind.COMMA) {
                            advance();
                            args.add(parseExpression());
                        }
                        expect(Kind.RPAREN);
                        if (args.size() != arity) {
                            throw new ParseException();
                        }
                        return new CallNode(t.text, args);
                    }
                    return new VariableNode(t.text);
                }
                case LPAREN: {
                    advance();
                    Node inner = parseExpression();
                    expect(Kind.RPAREN);
                    return inner;
                }
                default:
                    throw new ParseException();
            }
        }
    }

    // ---------------------------------------------------------------- AST

    private abstract static class Node extends AstNode {
        abstract EvalResult eval(List<Variable> vars);
    }

    private static final class NumberNode extends Node {
        private final double value;

        NumberNode(double value) {
            this.value = value;
        }

        @Override
        EvalResult eval(List<Variable> vars) {
            return ok(value);
        }
    }

    private static final class VariableNode extends Node {
        private final String name;

        VariableNode(String name) {
            this.name = name;
        }

        @Override
        EvalResult eval(List<Variable> vars) {
            for (Variable v : vars) {
                if (v.name.equals(name)) {
                    return ok(v.value);
                }
            }
            return error(EvalStatus.UNDEFINED_VAR);
        }
    }

    private static final class UnaryNode extends Node {
        private final char op;
        private final Node operand;

        UnaryNode(char op, Node operand) {
            this.op = op;
            this.operand = operand;
        }

        @Override
        EvalResult eval(List<Variable> vars) {
            EvalResult r = operand.eval(vars);
            if (r.status != EvalStatus.OK) {
                return r;
            }
            return ok(op == '-' ? -r.value : r.value);
        }
    }

    private static final class BinaryNode extends Node {
        private final char op;
        private final Node left;
        private final Node right;

        BinaryNode(char op, Node left, Node right) {
            this.op = op;
            this.left = left;
            this.right = right;
        }

        @Override
        EvalResult eval(List<Variable> vars) {
            EvalResult l = left.eval(vars);
            if (l.status != EvalStatus.OK) {
                return l;
            }
            EvalResult r = right.eval(vars);
            if (r.status != EvalStatus.OK) {
                return r;
            }
            double a = l.value;
            double b = r.value;
            switch (op) {
                case '+':
                    return ok(a + b);
                case '-':
                    return ok(a - b);
                case '*':
                    return ok(a * b);
                case '/':
                    if (b == 0.0) {
                        return error(EvalStatus.DIV_BY_ZERO);
                    }
                    return ok(a / b);
                case '%':
                    if (b == 0.0) {
                        return error(EvalStatus.DIV_BY_ZERO);
                    }
                    return ok(a % b);
                case '^':
                    return checkedPow(a, b);
                default:
                    return error(EvalStatus.INVALID_OP);
            }
        }
    }

    private static final class CallNode extends Node {
        private final String name;
        private final List<Node> args;

        CallNode(String name, List<Node> args) {
            this.name = name;
            this.args = args;
        }

        @Override
        EvalResult eval(List<Variable> vars) {
            double[] values = new double[args.size()];
            for (int i = 0; i < values.length; i++) {
                EvalResult r = args.get(i).eval(vars);
                if (r.status != EvalStatus.OK) {
                    return r;
                }
                values[i] = r.value;
            }
            switch (name) {
                case "sqrt":
                    if (values[0] < 0) {
                        return error(EvalStatus.DOMAIN_ERROR);
                    }
                    return ok(Math.sqrt(values[0]));
                case "abs":
                    return ok(Math.abs(values[0]));
                case "sin":
                    return ok(Math.sin(values[0]));
                case "cos":
                    return ok(Math.cos(values[0]));
                case "min":
                    return ok(Math.min(values[0], values[1]));
                case "max":
                    return ok(Math.max(values[0], values[1]));
                case "pow":
                    return checkedPow(values[0], values[1]);
                default:
                    return error(EvalStatus.INVALID_OP);
            }
        }
    }
}
