object Expression {
  sealed trait AstNode
  case class NumberNode(value: Double) extends AstNode
  case class VariableNode(name: String) extends AstNode
  case class BinaryOp(op: String, left: AstNode, right: AstNode) extends AstNode
  case class UnaryOp(op: String, operand: AstNode) extends AstNode
  case class FunctionCall(name: String, args: List[AstNode]) extends AstNode

  case class Variable(name: String, value: Double)

  sealed trait EvalStatus
  case object Ok extends EvalStatus
  case object DivByZero extends EvalStatus
  case object UndefinedVar extends EvalStatus
  case object InvalidOp extends EvalStatus
  case object DomainError extends EvalStatus

  case class EvalResult(status: EvalStatus, value: Double)

  def parseExpression(expression: String): Option[AstNode] =
    sys.error("Expression.parseExpression not implemented")

  def evaluate(ast: AstNode, vars: List[Variable]): EvalResult =
    sys.error("Expression.evaluate not implemented")
}
