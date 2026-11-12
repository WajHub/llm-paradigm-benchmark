object Tests {
  import BTree._

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

  // dump(leaf) = "(k0 k1 ...)", dump(internal) = "(dump(c0) k0 dump(c1) k1 ... dump(ck))"
  def dump(x: Node): String =
    if (x.children.isEmpty) x.keys.mkString("(", " ", ")")
    else {
      val inner = (dump(x.children.head) +: x.keys.indices.flatMap(i =>
        Vector(x.keys(i).toString, dump(x.children(i + 1))))).mkString(" ")
      "(" + inner + ")"
    }

  def dumpOpt(r: Option[Node]): String = r match {
    case Some(root) if root != null => dump(root)
    case Some(_)                    => "NULL"
    case None                       => "NONE"
  }

  // Result of the invariant check: height in levels (empty tree = 1), node count, in-order keys.
  case class TreeInfo(height: Int, nodes: Int, inorder: Vector[Int])

  // Validates all B-tree invariants; None if any is violated.
  def validate(root: Node, t: Int): Option[TreeInfo] = {
    def rec(x: Node, isRoot: Boolean, lo: Option[Int], hi: Option[Int]): Option[TreeInfo] =
      if (x == null || x.keys == null || x.children == null) None
      else {
        val n = x.keys.length
        val keysOk = n <= 2 * t - 1 &&
          (isRoot || n >= t - 1) &&
          x.keys.zip(x.keys.drop(1)).forall { case (p, q) => p < q } &&
          x.keys.forall(k => lo.forall(k > _) && hi.forall(k < _))
        if (!keysOk) None
        else if (x.children.isEmpty) Some(TreeInfo(1, 1, x.keys))
        else if (n == 0 || x.children.length != n + 1) None
        else {
          val subs = x.children.indices.map { i =>
            rec(x.children(i), false,
              if (i > 0) Some(x.keys(i - 1)) else lo,
              if (i < n) Some(x.keys(i)) else hi)
          }
          if (subs.exists(_.isEmpty)) None
          else {
            val infos = subs.map(_.get)
            if (infos.map(_.height).distinct.size != 1) None
            else {
              val inorder = infos.head.inorder ++ x.keys.indices.flatMap(i => x.keys(i) +: infos(i + 1).inorder)
              Some(TreeInfo(infos.head.height + 1, 1 + infos.map(_.nodes).sum, inorder))
            }
          }
        }
      }
    rec(root, isRoot = true, None, None)
  }

  // G(seed, count, mod): LCG x = (x * 1103515245 + 12345) mod 2^31, outputs (x div 65536) mod mod.
  def gen(seed: Long, count: Int, mod: Int): Vector[Int] =
    Iterator.iterate(seed)(x => (x * 1103515245L + 12345L) % 2147483648L)
      .drop(1).take(count).map(x => ((x / 65536L) % mod).toInt).toVector

  val Tens: Vector[Int] = Vector(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

  def insertDump(t: Int, keys: Vector[Int]): String = dumpOpt(insertAll(t, keys))
  def deleteDump(t: Int, keys: Vector[Int], dels: Vector[Int]): String = dumpOpt(deleteAll(t, keys, dels))

  // ==========================================================================
  // Algorithm A: Insertion
  // ==========================================================================

  def testAlgoA01Empty(): Boolean =
    try { insertDump(2, Vector.empty) == "()" } catch { case _: Throwable => false }

  def testAlgoA02InvalidDegree(): Boolean =
    try { insertAll(1, Vector(1, 2, 3)).isEmpty } catch { case _: Throwable => false }

  def testAlgoA03SingleLeaf(): Boolean =
    try { insertDump(3, Vector(5, 1, 3)) == "(1 3 5)" } catch { case _: Throwable => false }

  def testAlgoA04RootSplit(): Boolean =
    try { insertDump(2, Vector(1, 2, 3, 4)) == "((1) 2 (3 4))" } catch { case _: Throwable => false }

  def testAlgoA05DuplicateOnFullRoot(): Boolean =
    try { insertDump(2, Vector(1, 2, 3, 2)) == "(1 2 3)" } catch { case _: Throwable => false }

  def testAlgoA06Ascending(): Boolean =
    try {
      insertDump(2, Tens) == "(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))"
    } catch { case _: Throwable => false }

  def testAlgoA07ProactiveSplit(): Boolean =
    try {
      insertDump(2, Vector(10, 9, 8, 7, 6, 5, 4, 3, 2, 1)) == "(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))"
    } catch { case _: Throwable => false }

  def testAlgoA08TextbookT3(): Boolean =
    try {
      insertDump(3, Vector(8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18)) ==
        "((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))"
    } catch { case _: Throwable => false }

  def testAlgoA09Invariants(): Boolean =
    try {
      val keys = gen(7, 100, 1000)
      val expected = keys.distinct.sorted
      insertAll(3, keys).flatMap(r => validate(r, 3)) match {
        case Some(info) =>
          expected.length == 95 && info.inorder == expected && info.height == 3 && info.nodes == 28
        case None => false
      }
    } catch { case _: Throwable => false }

  def testAlgoA10Stress(): Boolean =
    try {
      val keys = gen(42, 2000, 100000)
      val expected = keys.distinct.sorted
      insertAll(4, keys) match {
        case Some(root) if root != null =>
          validate(root, 4) match {
            case Some(info) =>
              info.inorder == expected && expected.length == 1937 && expected.map(_.toLong).sum == 31779629L &&
                info.height == 5 && info.nodes == 413 && root.keys == Vector(15269)
            case None => false
          }
        case _ => false
      }
    } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: Deletion
  // ==========================================================================

  def testAlgoB01DeleteFromLeaf(): Boolean =
    try { deleteDump(3, Vector(5, 1, 3, 9, 7), Vector(3)) == "(1 5 7 9)" } catch { case _: Throwable => false }

  def testAlgoB02AbsentKeyUnchanged(): Boolean =
    try {
      deleteDump(2, Vector(10, 30, 20, 40), Vector(15)) == "((10) 20 (30 40))"
    } catch { case _: Throwable => false }

  def testAlgoB03DeleteAll(): Boolean =
    try {
      deleteDump(2, Tens, Vector(50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999)) == "()"
    } catch { case _: Throwable => false }

  def testAlgoB04PredecessorPreferred(): Boolean =
    try {
      deleteDump(2, Vector(10, 20, 30, 40, 5), Vector(20)) == "((5) 10 (30 40))"
    } catch { case _: Throwable => false }

  def testAlgoB05Successor(): Boolean =
    try {
      deleteDump(2, Vector(10, 20, 30, 40, 35), Vector(20)) == "((10) 30 (35 40))"
    } catch { case _: Throwable => false }

  def testAlgoB06MergeChildren(): Boolean =
    try {
      deleteDump(2, Vector(14, 3, 4, 11, 5, 15), Vector(4)) == "((3 5) 11 (14 15))"
    } catch { case _: Throwable => false }

  def testAlgoB07BorrowLeftFirst(): Boolean =
    try {
      deleteDump(2, Vector(21, 12, 9, 10, 17, 23, 24), Vector(17)) == "((9) 10 (12) 21 (23 24))"
    } catch { case _: Throwable => false }

  def testAlgoB08MergeRightFirst(): Boolean =
    try {
      deleteDump(2, Vector(3, 4, 19, 12, 7, 15, 22, 28), Vector(7)) == "((3) 4 (12 15) 19 (22 28))"
    } catch { case _: Throwable => false }

  def testAlgoB09RootShrink(): Boolean =
    try {
      deleteDump(2, Tens, Vector(10, 20)) == "((30) 40 (50) 60 (70) 80 (90 100))"
    } catch { case _: Throwable => false }

  def testAlgoB10StressInvariants(): Boolean =
    try {
      val keys = gen(9, 300, 500)
      val dels = gen(3, 250, 500)
      val delSet = dels.toSet
      val expected = keys.distinct.filterNot(delSet).sorted
      deleteAll(3, keys, dels) match {
        case Some(root) if root != null =>
          validate(root, 3) match {
            case Some(info) =>
              info.inorder == expected && expected.length == 150 && expected.sum == 39704 &&
                info.height == 4 && info.nodes == 55 && root.keys == Vector(293)
            case None => false
          }
        case _ => false
      }
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Empty)", () => testAlgoA01Empty()),
    ("Test A02 (Invalid Degree)", () => testAlgoA02InvalidDegree()),
    ("Test A03 (Single Leaf)", () => testAlgoA03SingleLeaf()),
    ("Test A04 (Root Split)", () => testAlgoA04RootSplit()),
    ("Test A05 (Duplicate On Full Root)", () => testAlgoA05DuplicateOnFullRoot()),
    ("Test A06 (Ascending)", () => testAlgoA06Ascending()),
    ("Test A07 (Proactive Split)", () => testAlgoA07ProactiveSplit()),
    ("Test A08 (Textbook t3)", () => testAlgoA08TextbookT3()),
    ("Test A09 (Invariants)", () => testAlgoA09Invariants()),
    ("Test A10 (Stress)", () => testAlgoA10Stress()),
    ("Test B01 (Delete From Leaf)", () => testAlgoB01DeleteFromLeaf()),
    ("Test B02 (Absent Key Unchanged)", () => testAlgoB02AbsentKeyUnchanged()),
    ("Test B03 (Delete All)", () => testAlgoB03DeleteAll()),
    ("Test B04 (Predecessor Preferred)", () => testAlgoB04PredecessorPreferred()),
    ("Test B05 (Successor)", () => testAlgoB05Successor()),
    ("Test B06 (Merge Children)", () => testAlgoB06MergeChildren()),
    ("Test B07 (Borrow Left First)", () => testAlgoB07BorrowLeftFirst()),
    ("Test B08 (Merge Right First)", () => testAlgoB08MergeRightFirst()),
    ("Test B09 (Root Shrink)", () => testAlgoB09RootShrink()),
    ("Test B10 (Stress Invariants)", () => testAlgoB10StressInvariants())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Insertion ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Deletion ---")
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
