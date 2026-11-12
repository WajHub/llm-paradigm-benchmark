object Tests {
  import SequenceAlignment._

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

  val StressA: String =
    "CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA"
  val StressB: String =
    "GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC"

  // Score of an alignment by definition: columns without '-' score match/mismatch,
  // every maximal run of '-' of length L in one row costs gapOpen + L * gapExtend.
  def scoreOf(sa: String, sb: String, m: Int, x: Int, o: Int, e: Int): Int = {
    val columns = sa.zip(sb).map { case (ca, cb) =>
      if (ca == '-' || cb == '-') 0 else if (ca == cb) m else -x
    }.sum
    def gapCost(row: String): Int = {
      val runs = row.foldLeft((List.empty[Int], 0)) { case ((acc, run), ch) =>
        if (ch == '-') (acc, run + 1) else if (run > 0) (run :: acc, 0) else (acc, 0)
      }
      val all = if (runs._2 > 0) runs._2 :: runs._1 else runs._1
      all.map(l => o + l * e).sum
    }
    columns - gapCost(sa) - gapCost(sb)
  }

  // Full validity check of an alignment result against the expected optimal score.
  def validAlignment(r: AlignResult, a: String, b: String,
                     m: Int, x: Int, o: Int, e: Int, expected: Int): Boolean =
    r != null && r.alignedA != null && r.alignedB != null &&
      r.score == expected &&
      r.alignedA.length == r.alignedB.length &&
      r.alignedA.filter(_ != '-') == a &&
      r.alignedB.filter(_ != '-') == b &&
      r.alignedA.zip(r.alignedB).forall { case (ca, cb) => !(ca == '-' && cb == '-') } &&
      scoreOf(r.alignedA, r.alignedB, m, x, o, e) == expected

  def exactAlignment(r: AlignResult, a: String, b: String, m: Int, x: Int, o: Int, e: Int,
                     expected: Int, expA: String, expB: String): Boolean =
    validAlignment(r, a, b, m, x, o, e, expected) && r.alignedA == expA && r.alignedB == expB

  // ==========================================================================
  // Algorithm A: alignmentScore
  // ==========================================================================

  def testAlgoA01BothEmpty(): Boolean =
    try { alignmentScore("", "", 1, 1, 2, 1) == 0 } catch { case _: Throwable => false }

  def testAlgoA02OneEmpty(): Boolean =
    try { alignmentScore("", "ACG", 1, 1, 2, 1) == -5 } catch { case _: Throwable => false }

  def testAlgoA03Identical(): Boolean =
    try { alignmentScore("GATTACA", "GATTACA", 2, 1, 3, 1) == 14 } catch { case _: Throwable => false }

  def testAlgoA04MismatchBeatsGaps(): Boolean =
    try { alignmentScore("A", "C", 1, 1, 2, 1) == -1 } catch { case _: Throwable => false }

  def testAlgoA05Textbook(): Boolean =
    try { alignmentScore("GATTACA", "GCATGCU", 1, 1, 1, 1) == -1 } catch { case _: Throwable => false }

  def testAlgoA06OneLongGap(): Boolean =
    try { alignmentScore("AAAGGGTTT", "AAATTT", 2, 2, 5, 1) == 4 } catch { case _: Throwable => false }

  def testAlgoA07ZeroExtend(): Boolean =
    try { alignmentScore("TTACGGA", "ACG", 2, 2, 2, 0) == 2 } catch { case _: Throwable => false }

  def testAlgoA08AdjacentGapsBeatMismatch(): Boolean =
    try { alignmentScore("XAY", "XCY", 1, 10, 1, 1) == -2 } catch { case _: Throwable => false }

  def testAlgoA09TerminalGapsPenalized(): Boolean =
    try { alignmentScore("AAAACCCC", "CCCC", 2, 1, 3, 1) == 1 } catch { case _: Throwable => false }

  def testAlgoA10Stress(): Boolean =
    try { alignmentScore(StressA, StressB, 2, 1, 3, 1) == 16 } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: align
  // ==========================================================================

  def testAlgoB01BothEmpty(): Boolean =
    try {
      exactAlignment(align("", "", 1, 1, 2, 1), "", "", 1, 1, 2, 1, 0, "", "")
    } catch { case _: Throwable => false }

  def testAlgoB02SecondEmpty(): Boolean =
    try {
      exactAlignment(align("ACG", "", 1, 1, 2, 1), "ACG", "", 1, 1, 2, 1, -5, "ACG", "---")
    } catch { case _: Throwable => false }

  def testAlgoB03Identical(): Boolean =
    try {
      exactAlignment(align("GATTACA", "GATTACA", 2, 1, 3, 1), "GATTACA", "GATTACA", 2, 1, 3, 1,
        14, "GATTACA", "GATTACA")
    } catch { case _: Throwable => false }

  def testAlgoB04UniqueLongGap(): Boolean =
    try {
      exactAlignment(align("AAAGGGTTT", "AAATTT", 2, 2, 5, 1), "AAAGGGTTT", "AAATTT", 2, 2, 5, 1,
        4, "AAAGGGTTT", "AAA---TTT")
    } catch { case _: Throwable => false }

  def testAlgoB05AdjacentGaps(): Boolean =
    try {
      validAlignment(align("XAY", "XCY", 1, 10, 1, 1), "XAY", "XCY", 1, 10, 1, 1, -2)
    } catch { case _: Throwable => false }

  def testAlgoB06TextbookUnique(): Boolean =
    try {
      exactAlignment(align("GATTACA", "GCATGCU", 1, 1, 1, 1), "GATTACA", "GCATGCU", 1, 1, 1, 1,
        -1, "GATTACA", "GCATGCU")
    } catch { case _: Throwable => false }

  def testAlgoB07GapMerging(): Boolean =
    try {
      exactAlignment(align("ACCCGT", "AGT", 2, 3, 6, 1), "ACCCGT", "AGT", 2, 3, 6, 1,
        -3, "ACCCGT", "A---GT")
    } catch { case _: Throwable => false }

  def testAlgoB08GapsInBothRows(): Boolean =
    try {
      exactAlignment(align("CACGCA", "AGGCGC", 3, 2, 3, 1), "CACGCA", "AGGCGC", 3, 2, 3, 1,
        -1, "CA--CGCA", "-AGGCGC-")
    } catch { case _: Throwable => false }

  def testAlgoB09TiedGapPositions(): Boolean =
    try {
      validAlignment(align("AAAA", "AA", 1, 1, 1, 1), "AAAA", "AA", 1, 1, 1, 1, -1)
    } catch { case _: Throwable => false }

  def testAlgoB10StressInvariants(): Boolean =
    try {
      validAlignment(align(StressA, StressB, 3, 2, 5, 1), StressA, StressB, 3, 2, 5, 1, 10)
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Both Empty)", () => testAlgoA01BothEmpty()),
    ("Test A02 (One Empty)", () => testAlgoA02OneEmpty()),
    ("Test A03 (Identical)", () => testAlgoA03Identical()),
    ("Test A04 (Mismatch Beats Gaps)", () => testAlgoA04MismatchBeatsGaps()),
    ("Test A05 (Textbook)", () => testAlgoA05Textbook()),
    ("Test A06 (One Long Gap)", () => testAlgoA06OneLongGap()),
    ("Test A07 (Zero Extend)", () => testAlgoA07ZeroExtend()),
    ("Test A08 (Adjacent Gaps Beat Mismatch)", () => testAlgoA08AdjacentGapsBeatMismatch()),
    ("Test A09 (Terminal Gaps Penalized)", () => testAlgoA09TerminalGapsPenalized()),
    ("Test A10 (Stress)", () => testAlgoA10Stress()),
    ("Test B01 (Both Empty)", () => testAlgoB01BothEmpty()),
    ("Test B02 (Second Empty)", () => testAlgoB02SecondEmpty()),
    ("Test B03 (Identical)", () => testAlgoB03Identical()),
    ("Test B04 (Unique Long Gap)", () => testAlgoB04UniqueLongGap()),
    ("Test B05 (Adjacent Gaps)", () => testAlgoB05AdjacentGaps()),
    ("Test B06 (Textbook Unique)", () => testAlgoB06TextbookUnique()),
    ("Test B07 (Gap Merging)", () => testAlgoB07GapMerging()),
    ("Test B08 (Gaps In Both Rows)", () => testAlgoB08GapsInBothRows()),
    ("Test B09 (Tied Gap Positions)", () => testAlgoB09TiedGapPositions()),
    ("Test B10 (Stress Invariants)", () => testAlgoB10StressInvariants())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Alignment Score ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Alignment Reconstruction ---")
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
