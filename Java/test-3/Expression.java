import java.util.List;

public abstract class Expression {
    protected Expression() {}

    public abstract static class AstNode {}

    public static final class Variable {
        public final String name;
        public final double value;
        public Variable(String name, double value) { this.name = name; this.value = value; }
    }

    public enum EvalStatus {
        OK,
        DIV_BY_ZERO,
        UNDEFINED_VAR,
        INVALID_OP,
        DOMAIN_ERROR
    }

    public static final class EvalResult {
        public final EvalStatus status;
        public final double value;
        public EvalResult(EvalStatus status, double value) {
            this.status = status;
            this.value = value;
        }
    }

    public abstract AstNode parse(String expression);
    public abstract EvalResult evaluate(AstNode ast, List<Variable> vars);
}
