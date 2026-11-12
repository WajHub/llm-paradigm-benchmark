object Tests {
  import OrderStats._

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

  // ==========================================================================
  // Helpers
  // ==========================================================================

  def sel(xs: Vector[Int], k: Int, value: Int, pivots: Vector[Int]): Boolean =
    selectKth(xs, k) == Some(SelectResult(value, pivots))

  // A10 generator: LCG x = (x * 1103515245 + 12345) mod 2^31, seed 42, r = x div 65536,
  // xs(i) = (r mod 20001) - 10000.
  def genStress(n: Int): Vector[Int] =
    Iterator.iterate(42L)(x => (x * 1103515245L + 12345L) % 2147483648L)
      .drop(1).take(n).map(x => ((x / 65536L) % 20001L - 10000L).toInt).toVector

  final class ProbeAbort(msg: String) extends RuntimeException(msg)

  // Shared read counter of both sources of one call.
  final class ReadBudget(val limit: Int) {
    var reads: Int = 0
    var violated: Boolean = false
  }

  // Counting probe: aborts the call when the budget is exceeded or an index is out of range.
  final class Probe(len: Int, f: Int => Int, budget: ReadBudget) extends SortedSource {
    def length: Int = len
    def get(index: Int): Int = {
      budget.reads += 1
      if (budget.reads > budget.limit) {
        budget.violated = true
        throw new ProbeAbort("read budget exceeded")
      }
      if (index < 0 || index >= len) {
        budget.violated = true
        throw new ProbeAbort("index out of range: " + index)
      }
      f(index)
    }
  }

  def bitlen(x: Long): Int = 64 - java.lang.Long.numberOfLeadingZeros(x)

  def readLimit(lenA: Int, lenB: Int): Int = 16 * (bitlen(lenA.toLong + lenB.toLong) + 1)

  // Runs medianTwoSorted on two probes and checks the result, the read budget and index validity.
  def medianCheck(lenA: Int, fa: Int => Int, lenB: Int, fb: Int => Int,
                  expected: Option[Double], expectedLimit: Int): Boolean = {
    val limit = readLimit(lenA, lenB)
    val budget = new ReadBudget(limit)
    val r = medianTwoSorted(new Probe(lenA, fa, budget), new Probe(lenB, fb, budget))
    val valueOk = expected match {
      case None    => r.isEmpty
      case Some(e) => r.exists(v => math.abs(v - e) < 1e-9)
    }
    limit == expectedLimit && !budget.violated && budget.reads <= limit && valueOk
  }

  def listCheck(a: Vector[Int], b: Vector[Int], expected: Option[Double], expectedLimit: Int): Boolean =
    medianCheck(a.length, i => a(i), b.length, j => b(j), expected, expectedLimit)

  // ==========================================================================
  // Algorithm A: Median of Medians
  // ==========================================================================

  def testAlgoA01Empty(): Boolean =
    try {
      medianOfMedians(Vector.empty).isEmpty && selectKth(Vector.empty, 0).isEmpty
    } catch { case _: Throwable => false }

  def testAlgoA02Single(): Boolean =
    try {
      val xs = Vector(7)
      medianOfMedians(xs) == Some(7) && sel(xs, 0, 7, Vector()) && selectKth(xs, 1).isEmpty
    } catch { case _: Throwable => false }

  def testAlgoA03OutOfRange(): Boolean =
    try {
      val xs = Vector(3, 1, 2)
      selectKth(xs, 3).isEmpty && selectKth(xs, -1).isEmpty &&
        sel(xs, 2, 3, Vector()) && medianOfMedians(xs) == Some(2)
    } catch { case _: Throwable => false }

  def testAlgoA04OneGroup(): Boolean =
    try {
      val xs = Vector(9, 1, 8, 2, 7)
      medianOfMedians(xs) == Some(7) &&
        sel(xs, 0, 1, Vector()) && sel(xs, 2, 7, Vector()) && sel(xs, 4, 9, Vector())
    } catch { case _: Throwable => false }

  def testAlgoA05PivotIsNotMedian(): Boolean =
    try {
      val xs = Vector(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
      medianOfMedians(xs) == Some(3) &&
        sel(xs, 4, 5, Vector(3, 6)) && sel(xs, 5, 6, Vector(3, 6))
    } catch { case _: Throwable => false }

  def testAlgoA06PartialLastGroup(): Boolean =
    try {
      val xs = Vector(5, 3, 9, 1, 8, 2, 6)
      medianOfMedians(xs) == Some(2) && sel(xs, 3, 5, Vector(2)) && sel(xs, 6, 9, Vector(2))
    } catch { case _: Throwable => false }

  def testAlgoA07ManyDuplicates(): Boolean =
    try {
      val xs = Vector(5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5)
      medianOfMedians(xs) == Some(5) &&
        sel(xs, 0, 1, Vector(5)) && sel(xs, 5, 5, Vector(5)) && sel(xs, 10, 9, Vector(5))
    } catch { case _: Throwable => false }

  def testAlgoA08StablePartitionOrder(): Boolean =
    try {
      val xs = Vector(40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27)
      medianOfMedians(xs) == Some(40) && sel(xs, 6, 51, Vector(40, 41, 51))
    } catch { case _: Throwable => false }

  def testAlgoA09AllRanks(): Boolean =
    try {
      val xs = Vector(12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14)
      val copy = xs.toList
      val sortedValues = Vector(-30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41)
      def pivotsFor(k: Int): Vector[Int] =
        if (k <= 6) Vector(3, -11) else if (k <= 11) Vector(3) else Vector(3, 14)
      medianOfMedians(xs) == Some(3) &&
        (0 until 23).forall(k => sel(xs, k, sortedValues(k), pivotsFor(k))) &&
        xs.toList == copy
    } catch { case _: Throwable => false }

  def testAlgoA10Stress(): Boolean =
    try {
      val xs = genStress(5000)
      medianOfMedians(xs) == Some(-1678) &&
        sel(xs, 0, -9996, Vector(-1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995)) &&
        sel(xs, 2499, -1694, Vector(-1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694)) &&
        sel(xs, 4999, 9984, Vector(-1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974))
    } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: Median of Two Sorted Arrays
  // ==========================================================================

  def testAlgoB01BothEmpty(): Boolean =
    try { listCheck(Vector(), Vector(), None, 16) } catch { case _: Throwable => false }

  def testAlgoB02OneEmpty(): Boolean =
    try { listCheck(Vector(), Vector(1, 2, 3, 4), Some(2.5), 64) } catch { case _: Throwable => false }

  def testAlgoB03SingleEach(): Boolean =
    try { listCheck(Vector(1), Vector(2), Some(1.5), 48) } catch { case _: Throwable => false }

  def testAlgoB04OddTotalInterleaved(): Boolean =
    try { listCheck(Vector(1, 3, 5), Vector(2, 4), Some(3.0), 64) } catch { case _: Throwable => false }

  def testAlgoB05DisjointRanges(): Boolean =
    try { listCheck(Vector(10, 11, 12, 13), Vector(1, 2, 3), Some(10.0), 64) } catch { case _: Throwable => false }

  def testAlgoB06Duplicates(): Boolean =
    try { listCheck(Vector(1, 1, 1, 1), Vector(1, 1, 2), Some(1.0), 64) } catch { case _: Throwable => false }

  def testAlgoB07NoOverflow(): Boolean =
    try {
      listCheck(Vector(2147483647), Vector(2147483647), Some(2147483647.0), 48) &&
        listCheck(Vector(-2147483648, 2147483647), Vector(), Some(-0.5), 48)
    } catch { case _: Throwable => false }

  def testAlgoB08HugeInterleaved(): Boolean =
    try {
      medianCheck(
        1000000000, i => (2L * i - 1000000000L).toInt,
        999999999, j => (2L * j - 999999999L).toInt,
        Some(-1.0), 512)
    } catch { case _: Throwable => false }

  def testAlgoB09HugeUnbalanced(): Boolean =
    try {
      val small = Vector(-5, 0, 7)
      medianCheck(
        3, i => small(i),
        2000000000, j => (j.toLong / 2L - 500000000L).toInt,
        Some(0.0), 512)
    } catch { case _: Throwable => false }

  def testAlgoB10HugeDuplicates(): Boolean =
    try {
      medianCheck(
        1500000000, i => (i.toLong / 1000000L).toInt,
        600000000, j => (700L + j.toLong / 3000000L).toInt,
        Some(787.0), 512)
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Empty)", () => testAlgoA01Empty()),
    ("Test A02 (Single)", () => testAlgoA02Single()),
    ("Test A03 (Out Of Range)", () => testAlgoA03OutOfRange()),
    ("Test A04 (One Group)", () => testAlgoA04OneGroup()),
    ("Test A05 (Pivot Is Not Median)", () => testAlgoA05PivotIsNotMedian()),
    ("Test A06 (Partial Last Group)", () => testAlgoA06PartialLastGroup()),
    ("Test A07 (Many Duplicates)", () => testAlgoA07ManyDuplicates()),
    ("Test A08 (Stable Partition Order)", () => testAlgoA08StablePartitionOrder()),
    ("Test A09 (All Ranks)", () => testAlgoA09AllRanks()),
    ("Test A10 (Stress)", () => testAlgoA10Stress()),
    ("Test B01 (Both Empty)", () => testAlgoB01BothEmpty()),
    ("Test B02 (One Empty)", () => testAlgoB02OneEmpty()),
    ("Test B03 (Single Each)", () => testAlgoB03SingleEach()),
    ("Test B04 (Odd Total Interleaved)", () => testAlgoB04OddTotalInterleaved()),
    ("Test B05 (Disjoint Ranges)", () => testAlgoB05DisjointRanges()),
    ("Test B06 (Duplicates)", () => testAlgoB06Duplicates()),
    ("Test B07 (No Overflow)", () => testAlgoB07NoOverflow()),
    ("Test B08 (Huge Interleaved)", () => testAlgoB08HugeInterleaved()),
    ("Test B09 (Huge Unbalanced)", () => testAlgoB09HugeUnbalanced()),
    ("Test B10 (Huge Duplicates)", () => testAlgoB10HugeDuplicates())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Median of Medians ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Median of Two Sorted Arrays ---")
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
