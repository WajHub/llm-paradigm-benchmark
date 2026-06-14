object Tests {
  import SpatialLogic._

  type TestCase = (String, () => Boolean)

  def approxEq(a: Double, b: Double): Boolean = math.abs(a - b) < 0.001

  def containsPoint(poly: Polygon, x: Double, y: Double): Boolean =
    poly.polygonVertices.exists { point =>
      approxEq(point.pointX, x) && approxEq(point.pointY, y)
    }

  def polygonArea(poly: Polygon): Double = {
    val points = poly.polygonVertices
    if (points.isEmpty) {
      0.0
    } else {
      val pairs = points.zip(points.tail :+ points.head)
      0.5 * pairs.map { case (a, b) => a.pointX * b.pointY - b.pointX * a.pointY }.sum
    }
  }

  def polygonIsCCW(poly: Polygon): Boolean = polygonArea(poly) > 1e-9

  def polygonHasNoCollinear(poly: Polygon): Boolean = {
    val points = poly.polygonVertices
    if (points.length < 3) {
      true
    } else {
      points.indices.forall { index =>
        val a = points(index)
        val b = points((index + 1) % points.length)
        val c = points((index + 2) % points.length)
        math.abs((b.pointX - a.pointX) * (c.pointY - a.pointY) - (b.pointY - a.pointY) * (c.pointX - a.pointX)) > 1e-6
      }
    }
  }

  def polygonMatchesExpected(poly: Polygon, expected: Seq[Point]): Boolean = {
    val actual = poly.polygonVertices
    actual.length == expected.length && expected.forall { point =>
      actual.exists { candidate =>
        approxEq(candidate.pointX, point.pointX) && approxEq(candidate.pointY, point.pointY)
      }
    }
  }

  def makePolygon(points: Seq[Point], name: String): Polygon =
    Polygon(points.toVector, points.length, true, name)

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

  def testAlgoA01BasicSquares(): Boolean = {
    val poly1 = makePolygon(Seq(Point(0, 0), Point(2, 0), Point(2, 2), Point(0, 2)), "Z1")
    val poly2 = makePolygon(Seq(Point(0, 0), Point(2, 0), Point(2, 2), Point(0, 2)), "Z2")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        polygonMatchesExpected(result, Seq(Point(0, 0), Point(4, 0), Point(4, 4), Point(0, 4))) &&
          polygonIsCCW(result) &&
          polygonHasNoCollinear(result) &&
          result.polygonIsConvex
    }
  }

  def testAlgoA02PointAndPolygon(): Boolean = {
    val poly1 = makePolygon(Seq(Point(5, 5)), "Point")
    val poly2 = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(0, 1)), "Triangle")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        polygonMatchesExpected(result, Seq(Point(5, 5), Point(6, 5), Point(5, 6))) &&
          polygonIsCCW(result) &&
          polygonHasNoCollinear(result)
    }
  }

  def testAlgoA03CollinearSimplification(): Boolean = {
    val poly1 = makePolygon(Seq(Point(0, 0), Point(2, 0), Point(0, 2)), "Tri1")
    val poly2 = makePolygon(Seq(Point(0, 0), Point(2, 0), Point(0, 2)), "Tri2")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        polygonMatchesExpected(result, Seq(Point(0, 0), Point(4, 0), Point(0, 4))) &&
          polygonIsCCW(result) &&
          polygonHasNoCollinear(result)
    }
  }

  def testAlgoA04NegativeCoordinates(): Boolean = {
    val poly1 = makePolygon(Seq(Point(-5, -5), Point(-3, -5), Point(-3, -3), Point(-5, -3)), "NegSq")
    val poly2 = makePolygon(Seq(Point(1, 1), Point(2, 1), Point(2, 2), Point(1, 2)), "PosSq")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        result.polygonVertices.length == 4 &&
          containsPoint(result, -4, -4) &&
          containsPoint(result, -1, -1) &&
          polygonIsCCW(result) &&
          polygonHasNoCollinear(result)
    }
  }

  def testAlgoA05SinglePoints(): Boolean = {
    val poly1 = makePolygon(Seq(Point(-2.5, 3.5)), "Pt1")
    val poly2 = makePolygon(Seq(Point(2.5, -3.5)), "Pt2")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        result.polygonVertices.length == 1 && containsPoint(result, 0, 0)
    }
  }

  def testAlgoA06EmptyFirstPolygon(): Boolean = {
    val poly1 = makePolygon(Seq.empty, "Empty")
    val poly2 = makePolygon(Seq(Point(0, 0), Point(1, 1)), "Line")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) => result.polygonVertices.isEmpty
    }
  }

  def testAlgoA07EmptySecondPolygon(): Boolean = {
    val poly1 = makePolygon(Seq(Point(0, 0), Point(1, 1)), "Line")
    val poly2 = makePolygon(Seq.empty, "Empty")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) => result.polygonVertices.isEmpty
    }
  }

  def testAlgoA08NullArguments(): Boolean = {
    val poly = makePolygon(Seq(Point(0, 0)), "Pt")
    val res1 = calculateCleanMinkowskiSum(None, Some(poly))
    val res2 = calculateCleanMinkowskiSum(Some(poly), None)
    val res3 = calculateCleanMinkowskiSum(None, None)
    res1.isEmpty && res2.isEmpty && res3.isEmpty
  }

  def testAlgoA09FlatPolygon(): Boolean = {
    val poly1 = makePolygon(Seq(Point(0, 0), Point(2, 0)), "Line1")
    val poly2 = makePolygon(Seq(Point(0, 0), Point(3, 0)), "Line2")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) =>
        result.polygonVertices.length == 2 &&
          containsPoint(result, 0, 0) &&
          containsPoint(result, 5, 0)
    }
  }

  def testAlgoA10StressTest(): Boolean = {
    val size = 500
    val circlePoints = (0 until size).map { index =>
      Point(
        math.cos(2.0 * math.Pi * index.toDouble / size.toDouble),
        math.sin(2.0 * math.Pi * index.toDouble / size.toDouble)
      )
    }
    val poly1 = makePolygon(circlePoints, "Circle1")
    val poly2 = makePolygon(circlePoints, "Circle2")
    calculateCleanMinkowskiSum(Some(poly1), Some(poly2)) match {
      case None => false
      case Some(result) => result.polygonVertices.nonEmpty
    }
  }

  def testAlgoB01TunnelingCollision(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(5, 0), Point(6, 0), Point(6, 1), Point(5, 1)), "Obstacle")
    checkDynamicCollision(Some(obstacle), Some(robot), Point(10, 0))
  }

  def testAlgoB02ClearMiss(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(0, 5), Point(1, 5), Point(1, 6), Point(0, 6)), "Obstacle")
    !checkDynamicCollision(Some(obstacle), Some(robot), Point(10, 0))
  }

  def testAlgoB03StaticOverlap(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(2, 0), Point(2, 2), Point(0, 2)), "Robot")
    val obstacle = makePolygon(Seq(Point(1, 1), Point(3, 1), Point(3, 3), Point(1, 3)), "Obstacle")
    checkDynamicCollision(Some(obstacle), Some(robot), Point(0, 0))
  }

  def testAlgoB04StaticMiss(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(10, 10), Point(11, 10), Point(11, 11), Point(10, 11)), "Obstacle")
    !checkDynamicCollision(Some(obstacle), Some(robot), Point(0, 0))
  }

  def testAlgoB05MovingAway(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(-5, 0), Point(-4, 0), Point(-4, 1), Point(-5, 1)), "Obstacle")
    !checkDynamicCollision(Some(obstacle), Some(robot), Point(10, 0))
  }

  def testAlgoB06DiagonalTunneling(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(5, 5), Point(7, 5), Point(7, 7), Point(5, 7)), "Obstacle")
    checkDynamicCollision(Some(obstacle), Some(robot), Point(10, 10))
  }

  def testAlgoB07EdgeGrazing(): Boolean = {
    val robot = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Robot")
    val obstacle = makePolygon(Seq(Point(0, 1), Point(1, 1), Point(1, 2), Point(0, 2)), "Obstacle")
    checkDynamicCollision(Some(obstacle), Some(robot), Point(10, 0))
  }

  def testAlgoB08NegativeVelocity(): Boolean = {
    val robot = makePolygon(Seq(Point(10, 10), Point(11, 10), Point(11, 11), Point(10, 11)), "Robot")
    val obstacle = makePolygon(Seq(Point(4, 4), Point(6, 4), Point(6, 6), Point(4, 6)), "Obstacle")
    checkDynamicCollision(Some(obstacle), Some(robot), Point(-10, -10))
  }

  def testAlgoB09EmptyPolygons(): Boolean = {
    val emptyPoly = makePolygon(Seq.empty, "Empty")
    val obstacle = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Obstacle")
    val col1 = checkDynamicCollision(Some(obstacle), Some(emptyPoly), Point(5, 5))
    val col2 = checkDynamicCollision(Some(emptyPoly), Some(obstacle), Point(5, 5))
    !col1 && !col2
  }

  def testAlgoB10NullArguments(): Boolean = {
    val obstacle = makePolygon(Seq(Point(0, 0), Point(1, 0), Point(1, 1), Point(0, 1)), "Obstacle")
    val col1 = checkDynamicCollision(None, Some(obstacle), Point(5, 5))
    val col2 = checkDynamicCollision(Some(obstacle), None, Point(5, 5))
    val col3 = checkDynamicCollision(None, None, Point(5, 5))
    !col1 && !col2 && !col3
  }

  val tests: List[TestCase] = List(
    ("test_algo_a_01_basic_squares", () => testAlgoA01BasicSquares()),
    ("test_algo_a_02_point_and_polygon", () => testAlgoA02PointAndPolygon()),
    ("test_algo_a_03_collinear_simplification", () => testAlgoA03CollinearSimplification()),
    ("test_algo_a_04_negative_coordinates", () => testAlgoA04NegativeCoordinates()),
    ("test_algo_a_05_single_points", () => testAlgoA05SinglePoints()),
    ("test_algo_a_06_empty_first_polygon", () => testAlgoA06EmptyFirstPolygon()),
    ("test_algo_a_07_empty_second_polygon", () => testAlgoA07EmptySecondPolygon()),
    ("test_algo_a_08_null_arguments", () => testAlgoA08NullArguments()),
    ("test_algo_a_09_flat_polygon", () => testAlgoA09FlatPolygon()),
    ("test_algo_a_10_stress_test", () => testAlgoA10StressTest()),
    ("test_algo_b_01_tunneling_collision", () => testAlgoB01TunnelingCollision()),
    ("test_algo_b_02_clear_miss", () => testAlgoB02ClearMiss()),
    ("test_algo_b_03_static_overlap", () => testAlgoB03StaticOverlap()),
    ("test_algo_b_04_static_miss", () => testAlgoB04StaticMiss()),
    ("test_algo_b_05_moving_away", () => testAlgoB05MovingAway()),
    ("test_algo_b_06_diagonal_tunneling", () => testAlgoB06DiagonalTunneling()),
    ("test_algo_b_07_edge_grazing", () => testAlgoB07EdgeGrazing()),
    ("test_algo_b_08_negative_velocity", () => testAlgoB08NegativeVelocity()),
    ("test_algo_b_09_empty_polygons", () => testAlgoB09EmptyPolygons()),
    ("test_algo_b_10_null_arguments", () => testAlgoB10NullArguments())
  )

  def main(args: Array[String]): Unit = {
    val results = tests.map { case (name, test) => check(name)(test()) }
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