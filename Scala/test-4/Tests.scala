object Tests {
  import Knapsack._

  type TestCase = (String, () => Boolean)

  def referenceDp(weights: Vector[Int], values: Vector[Int], capacity: Int): Int = {
    if (weights.isEmpty || capacity <= 0) return 0
    val dp = Array.fill(capacity + 1)(0)
    for (i <- weights.indices) {
      var c = capacity
      while (c >= weights(i)) {
        val cand = dp(c - weights(i)) + values(i)
        if (cand > dp(c)) dp(c) = cand
        c -= 1
      }
    }
    dp(capacity)
  }

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

  def testAlgoA01Empty(): Boolean =
    try { maxValue(Vector.empty, Vector.empty, 10) == 0 } catch { case _: Throwable => false }

  def testAlgoA02SingleFit(): Boolean =
    try { maxValue(Vector(5), Vector(10), 10) == 10 } catch { case _: Throwable => false }

  def testAlgoA03TooHeavy(): Boolean =
    try { maxValue(Vector(15), Vector(10), 10) == 0 } catch { case _: Throwable => false }

  def testAlgoA04CapZero(): Boolean =
    try { maxValue(Vector(1, 2, 3), Vector(10, 20, 30), 0) == 0 } catch { case _: Throwable => false }

  def testAlgoA05ChooseBetter(): Boolean =
    try { maxValue(Vector(5, 6), Vector(10, 11), 10) == 11 } catch { case _: Throwable => false }

  def testAlgoA06Textbook(): Boolean =
    try { maxValue(Vector(2, 3, 4, 5), Vector(3, 4, 5, 6), 5) == 7 } catch { case _: Throwable => false }

  def testAlgoA07GreedyTrap(): Boolean =
    try { maxValue(Vector(10, 20, 30), Vector(60, 100, 120), 50) == 220 } catch { case _: Throwable => false }

  def testAlgoA08SameItems(): Boolean =
    try { maxValue(Vector(3, 3, 3, 3), Vector(5, 5, 5, 5), 10) == 15 } catch { case _: Throwable => false }

  def testAlgoA09TightFit(): Boolean =
    try { maxValue(Vector(3, 4, 5, 6), Vector(2, 3, 4, 5), 10) == 8 } catch { case _: Throwable => false }

  def testAlgoA10Stress(): Boolean =
    try {
      val weights = Vector.tabulate(50)(i => i + 1)
      val values = Vector.tabulate(50)(i => (i + 1) * 2)
      val expected = referenceDp(weights, values, 100)
      maxValue(weights, values, 100) == expected
    } catch { case _: Throwable => false }

  def testAlgoB01SingleSelection(): Boolean =
    try {
      val r = solve(Vector(5), Vector(10), 10)
      r.maxValue == 10 && r.totalWeight == 5 && r.selected == Vector(1)
    } catch { case _: Throwable => false }

  def testAlgoB02ChooseBetterSelection(): Boolean =
    try {
      val r = solve(Vector(5, 6), Vector(10, 11), 10)
      r.maxValue == 11 && r.totalWeight == 6 && r.selected == Vector(0, 1)
    } catch { case _: Throwable => false }

  def testAlgoB03TextbookSelection(): Boolean =
    try {
      val r = solve(Vector(2, 3, 4, 5), Vector(3, 4, 5, 6), 5)
      r.maxValue == 7 && r.totalWeight == 5 && r.selected == Vector(1, 1, 0, 0)
    } catch { case _: Throwable => false }

  def testAlgoB04GreedyTrapSelection(): Boolean =
    try {
      val r = solve(Vector(10, 20, 30), Vector(60, 100, 120), 50)
      r.maxValue == 220 && r.totalWeight == 50 && r.selected == Vector(0, 1, 1)
    } catch { case _: Throwable => false }

  def testAlgoB05CapZeroSelection(): Boolean =
    try {
      val r = solve(Vector(1, 2, 3), Vector(10, 20, 30), 0)
      r.maxValue == 0 && r.totalWeight == 0 && r.selected == Vector(0, 0, 0)
    } catch { case _: Throwable => false }

  def testAlgoB06TooHeavySelection(): Boolean =
    try {
      val r = solve(Vector(15), Vector(10), 10)
      r.maxValue == 0 && r.totalWeight == 0 && r.selected == Vector(0)
    } catch { case _: Throwable => false }

  def testAlgoB07AllFit(): Boolean =
    try {
      val r = solve(Vector(1, 2, 3), Vector(10, 20, 30), 10)
      r.maxValue == 60 && r.totalWeight == 6 && r.selected == Vector(1, 1, 1)
    } catch { case _: Throwable => false }

  def testAlgoB08WeightInvariant(): Boolean =
    try {
      val weights = Vector(10, 20, 30)
      val values = Vector(60, 100, 120)
      val capacity = 50
      val r = solve(weights, values, capacity)
      val sumW = r.selected.zip(weights).map { case (s, w) => s * w }.sum
      sumW <= capacity && sumW == r.totalWeight
    } catch { case _: Throwable => false }

  def testAlgoB09ValueInvariant(): Boolean =
    try {
      val weights = Vector(10, 20, 30)
      val values = Vector(60, 100, 120)
      val r = solve(weights, values, 50)
      val sumV = r.selected.zip(values).map { case (s, v) => s * v }.sum
      sumV == r.maxValue
    } catch { case _: Throwable => false }

  def testAlgoB10StressInvariants(): Boolean =
    try {
      val weights = Vector.tabulate(50)(i => i + 1)
      val values = Vector.tabulate(50)(i => (i + 1) * 2)
      val capacity = 100
      val expected = referenceDp(weights, values, capacity)
      val r = solve(weights, values, capacity)
      val sumW = r.selected.zip(weights).map { case (s, w) => s * w }.sum
      val sumV = r.selected.zip(values).map { case (s, v) => s * v }.sum
      r.selected.length == 50 &&
        r.selected.forall(x => x == 0 || x == 1) &&
        r.maxValue == expected &&
        sumW <= capacity &&
        sumW == r.totalWeight &&
        sumV == r.maxValue
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Empty)", () => testAlgoA01Empty()),
    ("Test A02 (Single Fit)", () => testAlgoA02SingleFit()),
    ("Test A03 (Too Heavy)", () => testAlgoA03TooHeavy()),
    ("Test A04 (Capacity Zero)", () => testAlgoA04CapZero()),
    ("Test A05 (Choose Better)", () => testAlgoA05ChooseBetter()),
    ("Test A06 (Textbook)", () => testAlgoA06Textbook()),
    ("Test A07 (Greedy Trap)", () => testAlgoA07GreedyTrap()),
    ("Test A08 (Same Items)", () => testAlgoA08SameItems()),
    ("Test A09 (Tight Fit)", () => testAlgoA09TightFit()),
    ("Test A10 (Stress 50 Items)", () => testAlgoA10Stress()),
    ("Test B01 (Single Selection)", () => testAlgoB01SingleSelection()),
    ("Test B02 (Choose Better Selection)", () => testAlgoB02ChooseBetterSelection()),
    ("Test B03 (Textbook Selection)", () => testAlgoB03TextbookSelection()),
    ("Test B04 (Greedy Trap Selection)", () => testAlgoB04GreedyTrapSelection()),
    ("Test B05 (Capacity Zero Selection)", () => testAlgoB05CapZeroSelection()),
    ("Test B06 (Too Heavy Selection)", () => testAlgoB06TooHeavySelection()),
    ("Test B07 (All Fit)", () => testAlgoB07AllFit()),
    ("Test B08 (Weight Invariant)", () => testAlgoB08WeightInvariant()),
    ("Test B09 (Value Invariant)", () => testAlgoB09ValueInvariant()),
    ("Test B10 (Stress Invariants)", () => testAlgoB10StressInvariants())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Maximum Value ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Item Selection ---")
    val resultsB = tests.drop(10).map { case (name, test) => check(name)(test()) }

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
