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
    ("test_algo_a_01_single_number", () => testAlgoA01SingleNumber()),
    ("test_algo_a_02_simple_binary", () => testAlgoA02SimpleBinary()),
    ("test_algo_a_03_parentheses", () => testAlgoA03Parentheses()),
    ("test_algo_a_04_function_call", () => testAlgoA04FunctionCall()),
    ("test_algo_a_05_nested_and_unary", () => testAlgoA05NestedAndUnary()),
    ("test_algo_a_06_dangling_operator", () => testAlgoA06DanglingOperator()),
    ("test_algo_a_07_empty_string", () => testAlgoA07EmptyString()),
    ("test_algo_a_08_unbalanced_parens", () => testAlgoA08UnbalancedParens()),
    ("test_algo_a_09_trailing_garbage", () => testAlgoA09TrailingGarbage()),
    ("test_algo_a_10_bad_function", () => testAlgoA10BadFunction()),
    ("test_algo_b_01_precedence", () => testAlgoB01Precedence()),
    ("test_algo_b_02_parens_override", () => testAlgoB02ParensOverride()),
    ("test_algo_b_03_power_right_assoc", () => testAlgoB03PowerRightAssoc()),
    ("test_algo_b_04_unary_vs_power", () => testAlgoB04UnaryVsPower()),
    ("test_algo_b_05_variables", () => testAlgoB05Variables()),
    ("test_algo_b_06_undefined_var", () => testAlgoB06UndefinedVar()),
    ("test_algo_b_07_div_and_mod", () => testAlgoB07DivAndMod()),
    ("test_algo_b_08_functions", () => testAlgoB08Functions()),
    ("test_algo_b_09_domain_error", () => testAlgoB09DomainError()),
    ("test_algo_b_10_error_propagation", () => testAlgoB10ErrorPropagation())
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
