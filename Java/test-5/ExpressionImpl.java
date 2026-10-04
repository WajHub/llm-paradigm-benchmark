import java.util.List;

public class ExpressionImpl extends Expression {
    @Override
    public AstNode parse(String expression) {
        throw new UnsupportedOperationException("parse not implemented");
    }

    @Override
    public EvalResult evaluate(AstNode ast, List<Variable> vars) {
        throw new UnsupportedOperationException("evaluate not implemented");
    }
}
