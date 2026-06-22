object Tests {
  import ShortestPath._

  type TestCase = (String, () => Boolean)

  def distanceIs(actual: Double, expected: Double): Boolean =
    if (expected.isInfinite) actual.isInfinite && actual > 0
    else math.abs(actual - expected) < 1e-9

  def checkDistance(result: Option[PathResult], target: Int, expected: Double): Boolean =
    distanceIs(getShortestDistance(result, target), expected)

  def createLinearChain(numVertices: Int, weight: Double): Graph = {
    var graph = createGraph(numVertices)
    for (i <- 0 until numVertices - 1) {
      graph = addEdge(graph, i, i + 1, weight)
    }
    graph
  }

  def pathEquals(actual: Option[List[Int]], expected: List[Int]): Boolean =
    actual.contains(expected)

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

  def testAlgoA01LinearChain(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 1, 2, 2.0)
      g = addEdge(g, 2, 3, 3.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          checkDistance(Some(result), 0, 0.0) &&
            checkDistance(Some(result), 1, 1.0) &&
            checkDistance(Some(result), 2, 3.0) &&
            checkDistance(Some(result), 3, 6.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA02Diamond(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 0, 2, 4.0)
      g = addEdge(g, 1, 3, 6.0)
      g = addEdge(g, 2, 3, 1.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          checkDistance(Some(result), 0, 0.0) &&
            checkDistance(Some(result), 1, 1.0) &&
            checkDistance(Some(result), 2, 4.0) &&
            checkDistance(Some(result), 3, 5.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA03Disconnected(): Boolean =
    try {
      var g = createGraph(5)
      g = addEdge(g, 0, 1, 2.0)
      g = addEdge(g, 1, 2, 3.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          checkDistance(Some(result), 0, 0.0) &&
            checkDistance(Some(result), 1, 2.0) &&
            checkDistance(Some(result), 2, 5.0) &&
            checkDistance(Some(result), 3, Double.PositiveInfinity) &&
            checkDistance(Some(result), 4, Double.PositiveInfinity)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA04SingleVertex(): Boolean =
    try {
      val g = createGraph(1)
      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => checkDistance(Some(result), 0, 0.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA05ParallelEdges(): Boolean =
    try {
      var g = createGraph(2)
      g = addEdge(g, 0, 1, 5.0)
      g = addEdge(g, 0, 1, 2.0)
      g = addEdge(g, 0, 1, 8.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => checkDistance(Some(result), 1, 2.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA06ZeroWeightEdges(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 0.0)
      g = addEdge(g, 1, 2, 0.0)
      g = addEdge(g, 2, 3, 1.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          checkDistance(Some(result), 1, 0.0) &&
            checkDistance(Some(result), 2, 0.0) &&
            checkDistance(Some(result), 3, 1.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA07NullGraph(): Boolean =
    try {
      dijkstra(None, 0).isEmpty
    } catch {
      case _: Throwable => false
    }

  def testAlgoA08InvalidSource(): Boolean =
    try {
      val g = createGraph(3)
      dijkstra(Some(g), 5).isEmpty && dijkstra(Some(g), -1).isEmpty
    } catch {
      case _: Throwable => false
    }

  def testAlgoA09ComplexGraph(): Boolean =
    try {
      var g = createGraph(6)
      g = addEdge(g, 0, 1, 7.0)
      g = addEdge(g, 0, 2, 9.0)
      g = addEdge(g, 0, 5, 14.0)
      g = addEdge(g, 1, 2, 10.0)
      g = addEdge(g, 1, 3, 15.0)
      g = addEdge(g, 2, 3, 11.0)
      g = addEdge(g, 2, 5, 2.0)
      g = addEdge(g, 3, 4, 6.0)
      g = addEdge(g, 4, 5, 9.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          checkDistance(Some(result), 0, 0.0) &&
            checkDistance(Some(result), 1, 7.0) &&
            checkDistance(Some(result), 2, 9.0) &&
            checkDistance(Some(result), 3, 20.0) &&
            checkDistance(Some(result), 4, 26.0) &&
            checkDistance(Some(result), 5, 11.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoA10Stress(): Boolean =
    try {
      val g = createLinearChain(1000, 1.0)
      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => checkDistance(Some(result), 999, 999.0)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB01SimplePath(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 1, 2, 2.0)
      g = addEdge(g, 2, 3, 3.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 3), List(0, 1, 2, 3))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB02DiamondPath(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 0, 2, 4.0)
      g = addEdge(g, 1, 3, 6.0)
      g = addEdge(g, 2, 3, 1.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 3), List(0, 2, 3))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB03SelfPath(): Boolean =
    try {
      var g = createGraph(3)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 1, 2, 1.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 0), List(0))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB04Unreachable(): Boolean =
    try {
      var g = createGraph(5)
      g = addEdge(g, 0, 1, 2.0)
      g = addEdge(g, 1, 2, 3.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => reconstructPath(Some(result), 4).isEmpty
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB05LongChain(): Boolean =
    try {
      val numVertices = 10
      val g = createLinearChain(numVertices, 1.0)
      val expected = (0 until numVertices).toList

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 9), expected)
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB06Cycle(): Boolean =
    try {
      var g = createGraph(4)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 1, 2, 1.0)
      g = addEdge(g, 2, 0, 1.0)
      g = addEdge(g, 1, 3, 2.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 3), List(0, 1, 3))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB07Star(): Boolean =
    try {
      var g = createGraph(5)
      g = addEdge(g, 0, 1, 2.0)
      g = addEdge(g, 0, 2, 3.0)
      g = addEdge(g, 0, 3, 1.0)
      g = addEdge(g, 0, 4, 5.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 3), List(0, 3))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB08NullResult(): Boolean =
    try {
      reconstructPath(None, 0).isEmpty
    } catch {
      case _: Throwable => false
    }

  def testAlgoB09Bidirectional(): Boolean =
    try {
      var g = createGraph(3)
      g = addEdge(g, 0, 1, 1.0)
      g = addEdge(g, 1, 0, 10.0)
      g = addEdge(g, 1, 2, 1.0)
      g = addEdge(g, 0, 2, 5.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) => pathEquals(reconstructPath(Some(result), 2), List(0, 1, 2))
      }
    } catch {
      case _: Throwable => false
    }

  def testAlgoB10StressPath(): Boolean =
    try {
      val numVertices = 1000
      val g = createLinearChain(numVertices, 1.0)

      dijkstra(Some(g), 0) match {
        case None => false
        case Some(result) =>
          reconstructPath(Some(result), 999) match {
            case None => false
            case Some(path) =>
              path.length == numVertices && path.head == 0 && path.last == 999
          }
      }
    } catch {
      case _: Throwable => false
    }

  val tests: List[TestCase] = List(
    ("test_algo_a_01_linear_chain", () => testAlgoA01LinearChain()),
    ("test_algo_a_02_diamond", () => testAlgoA02Diamond()),
    ("test_algo_a_03_disconnected", () => testAlgoA03Disconnected()),
    ("test_algo_a_04_single_vertex", () => testAlgoA04SingleVertex()),
    ("test_algo_a_05_parallel_edges", () => testAlgoA05ParallelEdges()),
    ("test_algo_a_06_zero_weight_edges", () => testAlgoA06ZeroWeightEdges()),
    ("test_algo_a_07_null_graph", () => testAlgoA07NullGraph()),
    ("test_algo_a_08_invalid_source", () => testAlgoA08InvalidSource()),
    ("test_algo_a_09_complex_graph", () => testAlgoA09ComplexGraph()),
    ("test_algo_a_10_stress", () => testAlgoA10Stress()),
    ("test_algo_b_01_simple_path", () => testAlgoB01SimplePath()),
    ("test_algo_b_02_diamond_path", () => testAlgoB02DiamondPath()),
    ("test_algo_b_03_self_path", () => testAlgoB03SelfPath()),
    ("test_algo_b_04_unreachable", () => testAlgoB04Unreachable()),
    ("test_algo_b_05_long_chain", () => testAlgoB05LongChain()),
    ("test_algo_b_06_cycle", () => testAlgoB06Cycle()),
    ("test_algo_b_07_star", () => testAlgoB07Star()),
    ("test_algo_b_08_null_result", () => testAlgoB08NullResult()),
    ("test_algo_b_09_bidirectional", () => testAlgoB09Bidirectional()),
    ("test_algo_b_10_stress_path", () => testAlgoB10StressPath())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Shortest Distances ---")

    val algoATests = tests.take(10)
    val algoBTests = tests.drop(10)

    val resultsA = algoATests.map { case (name, test) => check(name)(test()) }

    println()
    println("--- Algorithm B: Path Reconstruction ---")

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
