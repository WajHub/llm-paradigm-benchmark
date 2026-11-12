object Tests {
  import Expression._

  type TestCase = (String, () => Boolean)

  def check(name: String)(body: => Boolean): Boolean = {
    try {
      if (body) {
        println("[PASS] " + name)
        true
      } else {
        println("[FAIL] " + name)
        false
      }
    } catch {
      case _: Throwable =>
        println("[FAIL] " + name)
        false
    }
  }

  // Parse then evaluate; a parse failure is reported as InvalidOp.
  def evalStr(s: String, vars: List[Variable]): EvalResult =
    parseExpression(s) match {
      case None      => EvalResult(InvalidOp, 0.0)
      case Some(ast) => evaluate(ast, vars)
    }

  def valueOk(r: EvalResult, expected: Double): Boolean =
    r.status == Ok && math.abs(r.value - expected) < 1e-9

  // ==========================================================================
  // Algorithm A: parseExpression (syntactic validity / AST construction)
  // ==========================================================================

  def testAlgoA01SingleNumber(): Boolean = parseExpression("42").isDefined
  def testAlgoA02SimpleBinary(): Boolean = parseExpression("1 + 2 * 3").isDefined
  def testAlgoA03Parentheses(): Boolean = parseExpression("2 * (3 + 4) - 5").isDefined
  def testAlgoA04FunctionCall(): Boolean = parseExpression("sqrt(16) + max(1, 2)").isDefined
  def testAlgoA05NestedAndUnary(): Boolean = parseExpression("-min(max(1, 2), 3) + -(4)").isDefined
  def testAlgoA06DanglingOperator(): Boolean = parseExpression("1 +").isEmpty
  def testAlgoA07EmptyString(): Boolean = parseExpression("").isEmpty
  def testAlgoA08UnbalancedParens(): Boolean = parseExpression("(1 + 2").isEmpty
  def testAlgoA09TrailingGarbage(): Boolean =
    parseExpression("1 + 2)").isEmpty && parseExpression("3 4").isEmpty
  def testAlgoA10BadFunction(): Boolean =
    parseExpression("foo(1)").isEmpty &&
      parseExpression("sqrt(1, 2)").isEmpty &&
      parseExpression("max(1)").isEmpty

  // ==========================================================================
  // Algorithm B: evaluate (numeric value + error statuses)
  // ==========================================================================

  def testAlgoB01Precedence(): Boolean = valueOk(evalStr("3 + 4 * 2", Nil), 11.0)
  def testAlgoB02ParensOverride(): Boolean = valueOk(evalStr("(3 + 4) * 2", Nil), 14.0)
  def testAlgoB03PowerRightAssoc(): Boolean = valueOk(evalStr("2 ^ 3 ^ 2", Nil), 512.0)
  def testAlgoB04UnaryVsPower(): Boolean = valueOk(evalStr("-2 ^ 2", Nil), -4.0)
  def testAlgoB05Variables(): Boolean =
    valueOk(evalStr("x * x + y * y", List(Variable("x", 3.0), Variable("y", 4.0))), 25.0)
  def testAlgoB06UndefinedVar(): Boolean = evalStr("x + 1", Nil).status == UndefinedVar
  def testAlgoB07DivAndMod(): Boolean =
    valueOk(evalStr("10 % 3", Nil), 1.0) && evalStr("5 / 0", Nil).status == DivByZero
  def testAlgoB08Functions(): Boolean =
    valueOk(evalStr("max(3, 7) + min(2, 5)", Nil), 9.0) &&
      valueOk(evalStr("abs(-5) + sqrt(9)", Nil), 8.0) &&
      valueOk(evalStr("pow(2, 10)", Nil), 1024.0)
  def testAlgoB09DomainError(): Boolean = evalStr("sqrt(-1)", Nil).status == DomainError
  def testAlgoB10ErrorPropagation(): Boolean =
    evalStr("x + 1 / (x - 2)", List(Variable("x", 2.0))).status == DivByZero

  val tests: List[TestCase] = List(
    ("Test A01 (Single Number)", () => testAlgoA01SingleNumber()),
    ("Test A02 (Binary + Precedence)", () => testAlgoA02SimpleBinary()),
    ("Test A03 (Parentheses)", () => testAlgoA03Parentheses()),
    ("Test A04 (Function Calls)", () => testAlgoA04FunctionCall()),
    ("Test A05 (Nested + Unary)", () => testAlgoA05NestedAndUnary()),
    ("Test A06 (Dangling Operator)", () => testAlgoA06DanglingOperator()),
    ("Test A07 (Empty String)", () => testAlgoA07EmptyString()),
    ("Test A08 (Unbalanced Parens)", () => testAlgoA08UnbalancedParens()),
    ("Test A09 (Trailing Garbage)", () => testAlgoA09TrailingGarbage()),
    ("Test A10 (Bad Function Call)", () => testAlgoA10BadFunction()),
    ("Test B01 (Operator Precedence)", () => testAlgoB01Precedence()),
    ("Test B02 (Parentheses Override)", () => testAlgoB02ParensOverride()),
    ("Test B03 (Power Right-Assoc)", () => testAlgoB03PowerRightAssoc()),
    ("Test B04 (Unary vs Power)", () => testAlgoB04UnaryVsPower()),
    ("Test B05 (Variables)", () => testAlgoB05Variables()),
    ("Test B06 (Undefined Variable)", () => testAlgoB06UndefinedVar()),
    ("Test B07 (Division & Modulo)", () => testAlgoB07DivAndMod()),
    ("Test B08 (Built-in Functions)", () => testAlgoB08Functions()),
    ("Test B09 (Domain Error)", () => testAlgoB09DomainError()),
    ("Test B10 (Error Propagation)", () => testAlgoB10ErrorPropagation())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Parsing & AST Construction ---")

    val algoATests = tests.take(10)
    val algoBTests = tests.drop(10)

    val resultsA = algoATests.map { case (name, test) => check(name)(test()) }

    println()
    println("--- Algorithm B: Evaluation & Error Semantics ---")

    val resultsB = algoBTests.map { case (name, test) => check(name)(test()) }

    val results = resultsA ++ resultsB
    val totalTests = tests.length
    val passedCount = results.count(identity)
    val failedCount = totalTests - passedCount
    val failedTests = tests.zip(results).collect { case ((name, _), false) => name }

    println()
    println("=== BENCHMARK RESULTS ===")
    println("Completed " + totalTests + " tests.")
    println("Passed: " + passedCount)
    println("Failed: " + failedCount)

    if (results.forall(identity)) {
      sys.exit(0)
    } else {
      println("Tests that failed:")
      failedTests.foreach(name => println(" - " + name))
      sys.exit(1)
    }
  }
}
