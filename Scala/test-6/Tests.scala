object Tests {
  import Sudoku._

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

  // Row-major string -> grid; '.' or '0' = empty, spaces are ignored.
  def parseGrid(s: String): Vector[Int] =
    s.filter(ch => ch == '.' || ch.isDigit).map(ch => if (ch == '.') 0 else ch - '0').toVector

  def set(grid: Vector[Int], row: Int, col: Int, value: Int): Vector[Int] =
    grid.updated(row * 9 + col, value)

  val Empty: Vector[Int] = Vector.fill(81)(0)
  val Classic: Vector[Int] = parseGrid(
    "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079")
  val Solved: Vector[Int] = parseGrid(
    "534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179")
  val Inkala: Vector[Int] = parseGrid(
    "800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402")
  val InkalaSol: Vector[Int] = parseGrid(
    "812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452")
  val AntiBf: Vector[Int] = parseGrid(
    "000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009")
  val AntiBfSol: Vector[Int] = parseGrid(
    "987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219")

  val BoxConflict: Vector[Int] = set(Classic, 1, 1, 8)
  val BoxConflict2: Vector[Int] = set(set(Empty, 0, 0, 1), 1, 1, 1)
  val RowConflict: Vector[Int] = set(Classic, 0, 8, 5)
  val ColConflict: Vector[Int] = set(Classic, 8, 0, 5)
  val DeadCell: Vector[Int] = set(Vector(1, 2, 3, 4, 5, 6, 7, 8, 0) ++ Vector.fill(72)(0), 4, 8, 9)
  val Hidden: Vector[Int] = set(Classic, 0, 2, 1)
  val Multi: Vector[Int] = set(Classic, 2, 2, 0)

  // ==========================================================================
  // Algorithm A: isValid / candidates
  // ==========================================================================

  def testAlgoA01EmptyGridValid(): Boolean =
    try { isValid(Empty) } catch { case _: Throwable => false }

  def testAlgoA02SolvedGridValid(): Boolean =
    try { isValid(Solved) && isValid(Classic) } catch { case _: Throwable => false }

  def testAlgoA03RowConflict(): Boolean =
    try { !isValid(RowConflict) && isValid(Classic) } catch { case _: Throwable => false }

  def testAlgoA04ColumnConflict(): Boolean =
    try { !isValid(ColConflict) && isValid(Classic) } catch { case _: Throwable => false }

  def testAlgoA05BoxOnlyConflict(): Boolean =
    try {
      !isValid(BoxConflict) && !isValid(BoxConflict2) && isValid(Classic)
    } catch { case _: Throwable => false }

  def testAlgoA06WrongLength(): Boolean =
    try {
      !isValid(Vector.fill(80)(0)) &&
        !isValid(Vector.fill(82)(0)) &&
        !isValid(Solved :+ 0) &&
        isValid(Solved)
    } catch { case _: Throwable => false }

  def testAlgoA07ValueOutOfRange(): Boolean =
    try {
      !isValid(set(Classic, 0, 2, 10)) && !isValid(set(Classic, 0, 2, -1)) && isValid(Classic)
    } catch { case _: Throwable => false }

  def testAlgoA08CandidatesBasic(): Boolean =
    try {
      candidates(Classic, 0, 2) == List(1, 2, 4) &&
        candidates(Classic, 4, 4) == List(5) &&
        candidates(Classic, 8, 0) == List(1, 2, 3)
    } catch { case _: Throwable => false }

  def testAlgoA09CandidatesEdgeCells(): Boolean =
    try {
      candidates(Classic, 0, 0) == Nil &&
        candidates(Classic, 8, 8) == Nil &&
        candidates(Empty, 8, 8) == (1 to 9).toList
    } catch { case _: Throwable => false }

  def testAlgoA10CandidatesSweep(): Boolean =
    try {
      val cells = for (r <- 0 until 9; c <- 0 until 9) yield (r, c)
      val sweepOk = cells.forall { case (r, c) =>
        candidates(set(Solved, r, c, 0), r, c) == List(Solved(r * 9 + c))
      }
      val total = cells.map { case (r, c) => candidates(Classic, r, c).length }.sum
      sweepOk && total == 153
    } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: solve / countSolutions
  // ==========================================================================

  def testAlgoB01AlreadySolved(): Boolean =
    try { solve(Solved) == Some(Solved) } catch { case _: Throwable => false }

  def testAlgoB02ClassicPuzzle(): Boolean =
    try {
      val input = Classic
      val result = solve(input)
      result == Some(Solved) && input == parseGrid(
        "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079")
    } catch { case _: Throwable => false }

  def testAlgoB03InvalidGrid(): Boolean =
    try {
      solve(BoxConflict).isEmpty &&
        solve(Vector.fill(80)(0)).isEmpty &&
        solve(set(Classic, 0, 2, 10)).isEmpty &&
        countSolutions(BoxConflict, 5) == 0 &&
        countSolutions(Vector.fill(80)(0), 5) == 0
    } catch { case _: Throwable => false }

  def testAlgoB04DeadCell(): Boolean =
    try { solve(DeadCell).isEmpty && countSolutions(DeadCell, 5) == 0 } catch { case _: Throwable => false }

  def testAlgoB05HiddenContradiction(): Boolean =
    try { solve(Hidden).isEmpty && countSolutions(Hidden, 5) == 0 } catch { case _: Throwable => false }

  def testAlgoB06BacktrackingRequired(): Boolean =
    try { solve(Inkala) == Some(InkalaSol) } catch { case _: Throwable => false }

  def testAlgoB07CountUnique(): Boolean =
    try { countSolutions(Classic, 2) == 1 && countSolutions(Solved, 2) == 1 } catch { case _: Throwable => false }

  def testAlgoB08CountMultiple(): Boolean =
    try {
      countSolutions(Multi, 100) == 8 && countSolutions(Multi, 5) == 5 && countSolutions(Multi, 1) == 1
    } catch { case _: Throwable => false }

  def testAlgoB09CountEmptyGridLimit(): Boolean =
    try {
      countSolutions(Empty, 2) == 2 &&
        countSolutions(Empty, 1) == 1 &&
        countSolutions(Empty, 0) == 0 &&
        countSolutions(Empty, -3) == 0
    } catch { case _: Throwable => false }

  def testAlgoB10StressAntiBruteForce(): Boolean =
    try { solve(AntiBf) == Some(AntiBfSol) } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Empty Grid Valid)", () => testAlgoA01EmptyGridValid()),
    ("Test A02 (Solved Grid Valid)", () => testAlgoA02SolvedGridValid()),
    ("Test A03 (Row Conflict)", () => testAlgoA03RowConflict()),
    ("Test A04 (Column Conflict)", () => testAlgoA04ColumnConflict()),
    ("Test A05 (Box Only Conflict)", () => testAlgoA05BoxOnlyConflict()),
    ("Test A06 (Wrong Length)", () => testAlgoA06WrongLength()),
    ("Test A07 (Value Out Of Range)", () => testAlgoA07ValueOutOfRange()),
    ("Test A08 (Candidates Basic)", () => testAlgoA08CandidatesBasic()),
    ("Test A09 (Candidates Edge Cells)", () => testAlgoA09CandidatesEdgeCells()),
    ("Test A10 (Candidates Sweep)", () => testAlgoA10CandidatesSweep()),
    ("Test B01 (Already Solved)", () => testAlgoB01AlreadySolved()),
    ("Test B02 (Classic Puzzle)", () => testAlgoB02ClassicPuzzle()),
    ("Test B03 (Invalid Grid)", () => testAlgoB03InvalidGrid()),
    ("Test B04 (Dead Cell)", () => testAlgoB04DeadCell()),
    ("Test B05 (Hidden Contradiction)", () => testAlgoB05HiddenContradiction()),
    ("Test B06 (Backtracking Required)", () => testAlgoB06BacktrackingRequired()),
    ("Test B07 (Count Unique)", () => testAlgoB07CountUnique()),
    ("Test B08 (Count Multiple)", () => testAlgoB08CountMultiple()),
    ("Test B09 (Count Empty Grid Limit)", () => testAlgoB09CountEmptyGridLimit()),
    ("Test B10 (Stress Anti Brute Force)", () => testAlgoB10StressAntiBruteForce())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Validation and Candidates ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Solving ---")
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
