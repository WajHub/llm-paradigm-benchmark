object ShortestPath {
  case class Edge(to: Int, weight: Double)
  case class Graph(adjacency: Vector[List[Edge]], numVertices: Int)
  case class PathResult(distances: Vector[Double], predecessors: Vector[Int], source: Int)

  def createGraph(numVertices: Int): Graph =
    Graph(Vector.fill(numVertices)(List.empty[Edge]), numVertices)

  def addEdge(graph: Graph, from: Int, to: Int, weight: Double): Graph = {
    if (from < 0 || from >= graph.numVertices || to < 0 || to >= graph.numVertices) {
      throw new IllegalArgumentException(s"Invalid vertex indices: from=$from, to=$to")
    }
    val newAdjacency = graph.adjacency.updated(from, Edge(to, weight) :: graph.adjacency(from))
    Graph(newAdjacency, graph.numVertices)
  }

  def dijkstra(graph: Option[Graph], source: Int): Option[PathResult] = {
    graph match {
      case None => None
      case Some(g) =>
        if (source < 0 || source >= g.numVertices) {
          None
        } else {
          val numV = g.numVertices
          val distances = Vector.fill(numV)(Double.PositiveInfinity)
          val predecessors = Vector.fill(numV)(-1)
          val visited = Array.fill(numV)(false)

          // Use a mutable priority queue for efficiency
          val pq = scala.collection.mutable.PriorityQueue[(Double, Int)]()(Ordering.by(-_._1))
          
          val updatedDistances = distances.updated(source, 0.0)
          pq.enqueue((0.0, source))

          var currentDistances = updatedDistances
          var currentPredecessors = predecessors

          while (pq.nonEmpty) {
            val (dist, u) = pq.dequeue()
            
            if (!visited(u)) {
              visited(u) = true
              
              for (edge <- g.adjacency(u)) {
                val v = edge.to
                val newDist = dist + edge.weight
                
                if (newDist < currentDistances(v)) {
                  currentDistances = currentDistances.updated(v, newDist)
                  currentPredecessors = currentPredecessors.updated(v, u)
                  pq.enqueue((newDist, v))
                }
              }
            }
          }

          Some(PathResult(currentDistances, currentPredecessors, source))
        }
    }
  }

  def getShortestDistance(result: Option[PathResult], target: Int): Double = {
    result match {
      case None => Double.PositiveInfinity
      case Some(r) =>
        if (target < 0 || target >= r.distances.length) {
          Double.PositiveInfinity
        } else {
          r.distances(target)
        }
    }
  }

  def reconstructPath(result: Option[PathResult], target: Int): Option[List[Int]] = {
    result match {
      case None => None
      case Some(r) =>
        if (target < 0 || target >= r.distances.length) {
          None
        } else if (r.distances(target) == Double.PositiveInfinity) {
          None
        } else {
          // Reconstruct path by following predecessors
          var path = List.empty[Int]
          var current = target
          
          // Check if target is reachable
          if (current == r.source) {
            Some(List(r.source))
          } else {
            var visited = Set.empty[Int]
            var valid = true
            
            while (current != -1 && !visited.contains(current)) {
              path = current :: path
              visited += current
              current = r.predecessors(current)
            }
            
            if (current == -1 && path.head != r.source) {
              // Path doesn't lead back to source
              None
            } else if (current == -1) {
              // Successfully reconstructed
              Some(path)
            } else {
              // Cycle detected (shouldn't happen in valid Dijkstra result)
              None
            }
          }
        }
    }
  }
}