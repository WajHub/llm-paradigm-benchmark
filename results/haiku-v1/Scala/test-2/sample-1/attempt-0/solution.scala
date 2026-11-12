object ShortestPath {
  import scala.annotation.tailrec
  import scala.collection.immutable.TreeSet

  case class Edge(to: Int, weight: Double)
  case class Graph(adjacency: Vector[List[Edge]], numVertices: Int)
  case class PathResult(distances: Vector[Double], predecessors: Vector[Int], source: Int)

  def createGraph(numVertices: Int): Graph = {
    val n = math.max(0, numVertices)
    Graph(Vector.fill(n)(List.empty[Edge]), n)
  }

  def addEdge(graph: Graph, from: Int, to: Int, weight: Double): Graph =
    if (from < 0 || from >= graph.numVertices || to < 0 || to >= graph.numVertices) graph
    else {
      val updatedList = graph.adjacency(from) :+ Edge(to, weight)
      graph.copy(adjacency = graph.adjacency.updated(from, updatedList))
    }

  def dijkstra(graph: Option[Graph], source: Int): Option[PathResult] =
    graph.flatMap { g =>
      if (source < 0 || source >= g.numVertices) None
      else {
        val initDist = Vector.fill(g.numVertices)(Double.PositiveInfinity).updated(source, 0.0)
        val initPred = Vector.fill(g.numVertices)(-1)
        val initFrontier = TreeSet((0.0, source))

        @tailrec
        def loop(
          frontier: TreeSet[(Double, Int)],
          dist: Vector[Double],
          pred: Vector[Int]
        ): (Vector[Double], Vector[Int]) =
          frontier.headOption match {
            case None => (dist, pred)
            case Some(item @ (d, u)) =>
              val rest = frontier - item
              if (d > dist(u)) loop(rest, dist, pred)
              else {
                val (nf, nd, np) = g.adjacency(u).foldLeft((rest, dist, pred)) {
                  case ((f, dd, pp), Edge(v, w)) =>
                    val candidate = d + w
                    if (candidate < dd(v))
                      (f + ((candidate, v)), dd.updated(v, candidate), pp.updated(v, u))
                    else (f, dd, pp)
                }
                loop(nf, nd, np)
              }
          }

        val (finalDist, finalPred) = loop(initFrontier, initDist, initPred)
        Some(PathResult(finalDist, finalPred, source))
      }
    }

  def getShortestDistance(result: Option[PathResult], target: Int): Double =
    result match {
      case Some(r) if target >= 0 && target < r.distances.length => r.distances(target)
      case _ => Double.PositiveInfinity
    }

  def reconstructPath(result: Option[PathResult], target: Int): Option[List[Int]] =
    result.flatMap { r =>
      if (target < 0 || target >= r.distances.length) None
      else if (r.distances(target).isPosInfinity) None
      else {
        @tailrec
        def walk(v: Int, acc: List[Int]): Option[List[Int]] =
          if (v == r.source) Some(v :: acc)
          else {
            val p = r.predecessors(v)
            if (p < 0) None else walk(p, v :: acc)
          }
        walk(target, Nil)
      }
    }
}
