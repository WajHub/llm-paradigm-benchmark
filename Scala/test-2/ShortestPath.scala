object ShortestPath {
  case class Edge(to: Int, weight: Double)
  case class Graph(adjacency: Vector[List[Edge]], numVertices: Int)
  case class PathResult(distances: Vector[Double], predecessors: Vector[Int], source: Int)

  def createGraph(numVertices: Int): Graph =
    sys.error("ShortestPath.createGraph not implemented")

  def addEdge(graph: Graph, from: Int, to: Int, weight: Double): Graph =
    sys.error("ShortestPath.addEdge not implemented")

  def dijkstra(graph: Option[Graph], source: Int): Option[PathResult] =
    sys.error("ShortestPath.dijkstra not implemented")

  def getShortestDistance(result: Option[PathResult], target: Int): Double =
    sys.error("ShortestPath.getShortestDistance not implemented")

  def reconstructPath(result: Option[PathResult], target: Int): Option[List[Int]] =
    sys.error("ShortestPath.reconstructPath not implemented")
}
