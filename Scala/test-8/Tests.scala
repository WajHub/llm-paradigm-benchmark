object Tests {
  import TspApprox._

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

  type Pts = Vector[(Int, Int)]

  val Empty: Pts = Vector.empty
  val Single: Pts = Vector((5, 5))
  val Two: Pts = Vector((0, 0), (3, 4))
  val Collinear: Pts = Vector((0, 0), (4, 0), (1, 0), (9, 0), (6, 0))
  val Square: Pts = Vector((0, 0), (0, 2), (2, 2), (2, 0))
  val ParentTie: Pts = Vector((2, 0), (0, 3), (2, 3), (3, 4), (1, 4))
  val Grid: Pts = Vector((0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1), (0, 2), (1, 2), (2, 2))
  val Dup: Pts = Vector((3, 3), (3, 3), (0, 0), (3, 3))
  val Star: Pts = Vector((5, 5), (5, 0), (0, 5), (10, 5))
  val Clusters: Pts = Vector((0, 0), (20, 0), (1, 1), (21, 1), (0, 20), (20, 20), (1, 21), (21, 21))
  val Spiral: Pts = Vector((0, 0), (8, 0), (8, 8), (0, 8), (2, 2), (6, 2), (6, 6), (2, 6), (4, 4))
  val S40: Pts = Vector(
    (81, 33), (69, 61), (56, 93), (77, 0), (65, 25), (72, 14), (14, 48), (33, 32), (73, 63), (71, 87),
    (5, 8), (54, 24), (22, 71), (51, 45), (55, 89), (29, 78), (87, 65), (32, 67), (53, 10), (27, 83),
    (36, 30), (41, 96), (2, 37), (8, 85), (78, 74), (59, 59), (76, 26), (9, 63), (63, 86), (7, 17),
    (91, 65), (27, 22), (7, 85), (95, 32), (35, 71), (7, 65), (12, 61), (82, 60), (5, 35), (74, 66))
  val S12: Pts = S40.take(12)
  val S20: Pts = Vector(
    (38, 58), (13, 15), (51, 27), (10, 19), (12, 86), (49, 67), (84, 60), (25, 43), (89, 83), (37, 66),
    (66, 78), (95, 11), (67, 54), (31, 45), (82, 36), (24, 5), (94, 2), (51, 67), (54, 53), (61, 96))

  def dist(p: (Int, Int), q: (Int, Int)): Int = math.abs(p._1 - q._1) + math.abs(p._2 - q._2)

  def tourCost(pts: Pts, tour: Vector[Int]): Int =
    if (tour.length <= 1) 0
    else tour.indices.map(i => dist(pts(tour(i)), pts(tour((i + 1) % tour.length)))).sum

  // Tour is a permutation of 0..n-1 starting with 0 and its cost matches the recomputed cost.
  def validTour(pts: Pts, r: Option[TourResult]): Boolean = r match {
    case Some(TourResult(tour, cost)) if tour != null =>
      tour.length == pts.length &&
        tour.nonEmpty && tour.head == 0 &&
        tour.sorted == pts.indices.toVector &&
        cost == tourCost(pts, tour)
    case _ => false
  }

  def exactDoubleTree(pts: Pts, expTour: Vector[Int], expCost: Int, expMst: Int): Boolean = {
    val r = doubleTree(pts)
    validTour(pts, r) && r.get.tour == expTour && r.get.cost == expCost && mstWeight(pts) == expMst
  }

  // ==========================================================================
  // Algorithm A: MST Double Tree
  // ==========================================================================

  def testAlgoA01Empty(): Boolean =
    try { mstWeight(Empty) == 0 && doubleTree(Empty).isEmpty } catch { case _: Throwable => false }

  def testAlgoA02SinglePoint(): Boolean =
    try { exactDoubleTree(Single, Vector(0), 0, 0) } catch { case _: Throwable => false }

  def testAlgoA03TwoPoints(): Boolean =
    try { exactDoubleTree(Two, Vector(0, 1), 14, 7) } catch { case _: Throwable => false }

  def testAlgoA04CollinearUnsorted(): Boolean =
    try { exactDoubleTree(Collinear, Vector(0, 2, 1, 4, 3), 18, 9) } catch { case _: Throwable => false }

  def testAlgoA05Square(): Boolean =
    try { exactDoubleTree(Square, Vector(0, 1, 2, 3), 8, 6) } catch { case _: Throwable => false }

  def testAlgoA06ParentTieBreaking(): Boolean =
    try { exactDoubleTree(ParentTie, Vector(0, 2, 1, 4, 3), 14, 9) } catch { case _: Throwable => false }

  def testAlgoA07GridTies(): Boolean =
    try { exactDoubleTree(Grid, Vector(0, 1, 2, 5, 8, 4, 7, 3, 6), 12, 8) } catch { case _: Throwable => false }

  def testAlgoA08DuplicatePoints(): Boolean =
    try { exactDoubleTree(Dup, Vector(0, 1, 2, 3), 12, 6) } catch { case _: Throwable => false }

  def testAlgoA09ClustersTwoApprox(): Boolean =
    try {
      exactDoubleTree(Clusters, Vector(0, 1, 3, 5, 7, 2, 4, 6), 128, 68) &&
        doubleTree(Clusters).get.cost <= 2 * 88
    } catch { case _: Throwable => false }

  def testAlgoA10Stress(): Boolean =
    try {
      val r = doubleTree(S40)
      mstWeight(S40) == 503 && validTour(S40, r) && r.get.cost == 832
    } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: Christofides
  // ==========================================================================

  def testAlgoB01Empty(): Boolean =
    try { matchingWeight(Empty) == 0 && christofides(Empty).isEmpty } catch { case _: Throwable => false }

  def testAlgoB02TwoPointsDoubleEdge(): Boolean =
    try {
      val r = christofides(Two)
      matchingWeight(Two) == 7 && validTour(Two, r) && r.get.tour == Vector(0, 1) && r.get.cost == 14
    } catch { case _: Throwable => false }

  def testAlgoB03StarParallelEdges(): Boolean =
    try {
      val r = christofides(Star)
      matchingWeight(Star) == 15 && validTour(Star, r) && r.get.cost == 30
    } catch { case _: Throwable => false }

  def testAlgoB04Collinear(): Boolean =
    try {
      val r = christofides(Collinear)
      matchingWeight(Collinear) == 9 && validTour(Collinear, r) && r.get.cost == 18
    } catch { case _: Throwable => false }

  def testAlgoB05Grid(): Boolean =
    try {
      val r = christofides(Grid)
      matchingWeight(Grid) == 4 && validTour(Grid, r) && r.get.cost <= 12
    } catch { case _: Throwable => false }

  def testAlgoB06BeatsDoubleTree(): Boolean =
    try {
      val r = christofides(Clusters)
      matchingWeight(Clusters) == 24 && validTour(Clusters, r) && r.get.cost <= 92
    } catch { case _: Throwable => false }

  def testAlgoB07SpiralBound(): Boolean =
    try {
      val r = christofides(Spiral)
      matchingWeight(Spiral) == 20 && validTour(Spiral, r) &&
        r.get.cost <= 52 && 2 * r.get.cost <= 3 * 44
    } catch { case _: Throwable => false }

  def testAlgoB08GreedyMatchingTrap(): Boolean =
    try {
      val r = christofides(S12)
      matchingWeight(S12) == 163 && validTour(S12, r) &&
        r.get.cost <= 440 && 2 * r.get.cost <= 3 * 396
    } catch { case _: Throwable => false }

  def testAlgoB09DuplicatePoints(): Boolean =
    try {
      val r = christofides(Dup)
      matchingWeight(Dup) == 6 && validTour(Dup, r) && r.get.cost == 12
    } catch { case _: Throwable => false }

  def testAlgoB10Stress(): Boolean =
    try {
      val r = christofides(S20)
      matchingWeight(S20) == 211 && validTour(S20, r) &&
        r.get.cost <= 608 && 2 * r.get.cost <= 3 * 540
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Empty)", () => testAlgoA01Empty()),
    ("Test A02 (Single Point)", () => testAlgoA02SinglePoint()),
    ("Test A03 (Two Points)", () => testAlgoA03TwoPoints()),
    ("Test A04 (Collinear Unsorted)", () => testAlgoA04CollinearUnsorted()),
    ("Test A05 (Square)", () => testAlgoA05Square()),
    ("Test A06 (Parent Tie Breaking)", () => testAlgoA06ParentTieBreaking()),
    ("Test A07 (Grid Ties)", () => testAlgoA07GridTies()),
    ("Test A08 (Duplicate Points)", () => testAlgoA08DuplicatePoints()),
    ("Test A09 (Clusters Two Approx)", () => testAlgoA09ClustersTwoApprox()),
    ("Test A10 (Stress)", () => testAlgoA10Stress()),
    ("Test B01 (Empty)", () => testAlgoB01Empty()),
    ("Test B02 (Two Points Double Edge)", () => testAlgoB02TwoPointsDoubleEdge()),
    ("Test B03 (Star Parallel Edges)", () => testAlgoB03StarParallelEdges()),
    ("Test B04 (Collinear)", () => testAlgoB04Collinear()),
    ("Test B05 (Grid)", () => testAlgoB05Grid()),
    ("Test B06 (Beats Double Tree)", () => testAlgoB06BeatsDoubleTree()),
    ("Test B07 (Spiral Bound)", () => testAlgoB07SpiralBound()),
    ("Test B08 (Greedy Matching Trap)", () => testAlgoB08GreedyMatchingTrap()),
    ("Test B09 (Duplicate Points)", () => testAlgoB09DuplicatePoints()),
    ("Test B10 (Stress)", () => testAlgoB10Stress())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: MST Double Tree ---")
    val resultsA = tests.take(10).map { case (name, test) => check(name)(test()) }
    println()
    println("--- Algorithm B: Christofides ---")
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
