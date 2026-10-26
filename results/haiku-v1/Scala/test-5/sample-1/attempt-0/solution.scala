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

  private sealed trait Token
  private case class NumTok(text: String) extends Token
  private case class IdentTok(name: String) extends Token
  private case class OpTok(c: Char) extends Token

  private type Parsed = Option[(AstNode, List[Token])]

  private val arities: Map[String, Int] =
    Map("sqrt" -> 1, "abs" -> 1, "sin" -> 1, "cos" -> 1, "min" -> 2, "max" -> 2, "pow" -> 2)

  private val operatorChars = "+-*/%^(),"

  private def isDigit(c: Char): Boolean = c >= '0' && c <= '9'
  private def isIdentStart(c: Char): Boolean = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  private def isIdentChar(c: Char): Boolean = isIdentStart(c) || isDigit(c)

  private def tokenize(s: String): Option[List[Token]] = {
    @scala.annotation.tailrec
    def go(cs: List[Char], acc: List[Token]): Option[List[Token]] = cs match {
      case Nil => Some(acc.reverse)
      case c :: tail if c.isWhitespace => go(tail, acc)
      case c :: _ if operatorChars.indexOf(c) >= 0 => go(cs.tail, OpTok(c) :: acc)
      case c :: _ if isDigit(c) =>
        val (num, rest) = cs.span(ch => isDigit(ch) || ch == '.')
        val text = num.mkString
        if (text.matches("\\d+(\\.\\d+)?")) go(rest, NumTok(text) :: acc) else None
      case c :: _ if isIdentStart(c) =>
        val (ident, rest) = cs.span(isIdentChar)
        go(rest, IdentTok(ident.mkString) :: acc)
      case _ => None
    }
    go(s.toList, Nil)
  }

  private def leftAssoc(ops: Set[Char], operand: List[Token] => Parsed)(ts: List[Token]): Parsed = {
    def go(left: AstNode, rest: List[Token]): Parsed = rest match {
      case OpTok(c) :: tail if ops.contains(c) =>
        operand(tail).flatMap { case (right, rest2) => go(BinaryOp(c.toString, left, right), rest2) }
      case _ => Some((left, rest))
    }
    operand(ts).flatMap { case (first, rest) => go(first, rest) }
  }

  private def parseExpr(ts: List[Token]): Parsed =
    leftAssoc(Set('+', '-'), parseTerm)(ts)

  private def parseTerm(ts: List[Token]): Parsed =
    leftAssoc(Set('*', '/', '%'), parseUnary)(ts)

  private def parseUnary(ts: List[Token]): Parsed = ts match {
    case OpTok(c) :: rest if c == '+' || c == '-' =>
      parseUnary(rest).map { case (e, r) => (UnaryOp(c.toString, e), r) }
    case _ => parsePower(ts)
  }

  private def parsePower(ts: List[Token]): Parsed =
    parsePrimary(ts).flatMap { case (base, rest) =>
      rest match {
        case OpTok('^') :: tail =>
          parseUnary(tail).map { case (e, r) => (BinaryOp("^", base, e), r) }
        case _ => Some((base, rest))
      }
    }

  private def parsePrimary(ts: List[Token]): Parsed = ts match {
    case NumTok(text) :: rest => Some((NumberNode(text.toDouble), rest))
    case IdentTok(name) :: OpTok('(') :: rest =>
      parseArgs(rest).flatMap {
        case (args, OpTok(')') :: rest2) if arities.get(name).contains(args.length) =>
          Some((FunctionCall(name, args), rest2))
        case _ => None
      }
    case IdentTok(name) :: rest => Some((VariableNode(name), rest))
    case OpTok('(') :: rest =>
      parseExpr(rest).flatMap {
        case (e, OpTok(')') :: rest2) => Some((e, rest2))
        case _ => None
      }
    case _ => None
  }

  private def parseArgs(ts: List[Token]): Option[(List[AstNode], List[Token])] =
    parseExpr(ts).flatMap { case (e, rest) =>
      rest match {
        case OpTok(',') :: tail => parseArgs(tail).map { case (es, r) => (e :: es, r) }
        case _ => Some((List(e), rest))
      }
    }

  def parseExpression(expression: String): Option[AstNode] =
    tokenize(expression).flatMap { ts =>
      parseExpr(ts) match {
        case Some((ast, Nil)) => Some(ast)
        case _ => None
      }
    }

  private def ok(v: Double): EvalResult = EvalResult(Ok, v)
  private def fail(s: EvalStatus): EvalResult = EvalResult(s, 0.0)

  private def power(a: Double, b: Double): EvalResult = {
    val r = math.pow(a, b)
    if (r.isNaN || r.isInfinite) fail(DomainError) else ok(r)
  }

  private def applyFunction(name: String, args: List[Double]): EvalResult = (name, args) match {
    case ("sqrt", x :: Nil) => if (x < 0) fail(DomainError) else ok(math.sqrt(x))
    case ("abs", x :: Nil) => ok(math.abs(x))
    case ("sin", x :: Nil) => ok(math.sin(x))
    case ("cos", x :: Nil) => ok(math.cos(x))
    case ("min", x :: y :: Nil) => ok(math.min(x, y))
    case ("max", x :: y :: Nil) => ok(math.max(x, y))
    case ("pow", x :: y :: Nil) => power(x, y)
    case _ => fail(InvalidOp)
  }

  private def applyBinary(op: String, a: Double, b: Double): EvalResult = op match {
    case "+" => ok(a + b)
    case "-" => ok(a - b)
    case "*" => ok(a * b)
    case "/" => if (b == 0) fail(DivByZero) else ok(a / b)
    case "%" => if (b == 0) fail(DivByZero) else ok(a % b)
    case "^" => power(a, b)
    case _ => fail(InvalidOp)
  }

  def evaluate(ast: AstNode, vars: List[Variable]): EvalResult = ast match {
    case NumberNode(v) => ok(v)

    case VariableNode(name) =>
      vars.find(_.name == name) match {
        case Some(v) => ok(v.value)
        case None => fail(UndefinedVar)
      }

    case UnaryOp(op, operand) =>
      val r = evaluate(operand, vars)
      if (r.status != Ok) fail(r.status)
      else op match {
        case "-" => ok(-r.value)
        case "+" => ok(r.value)
        case _ => fail(InvalidOp)
      }

    case BinaryOp(op, left, right) =>
      val lr = evaluate(left, vars)
      if (lr.status != Ok) fail(lr.status)
      else {
        val rr = evaluate(right, vars)
        if (rr.status != Ok) fail(rr.status)
        else applyBinary(op, lr.value, rr.value)
      }

    case FunctionCall(name, args) =>
      val results = args.map(evaluate(_, vars))
      results.find(_.status != Ok) match {
        case Some(bad) => fail(bad.status)
        case None => applyFunction(name, results.map(_.value))
      }
  }
}
