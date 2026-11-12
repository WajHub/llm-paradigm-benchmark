You are a Scala programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `createGraph`: Create directed weighted graph with the given vertices (0-indexed).
- Implement `addEdge`: Return a new Graph with the directed edge added. Support multiple edges.
- Implement `dijkstra`: Takes Option[Graph] and source. Return None if graph is None or source out of bounds. Unreachable vertices get Double.PositiveInfinity.
- Implement `getShortestDistance`: Takes Option[PathResult] and target. Return Double.PositiveInfinity if None or out of bounds.
- Implement `reconstructPath`: Return Option[List[Int]] — Some(path) or None if unreachable/invalid.
- Use idiomatic Scala with immutable data structures.
- Use a priority queue for efficiency.

General Requirements:
- Use idiomatic Scala.
- Prefer immutable data structures and pure functions where practical.
- Model absence with `Option` instead of null values.
- Return ONLY raw Scala code (no Markdown tags, no ```scala blocks, no side text). Your code will be directly saved to a `.scala` file and compiled.
- Do not provide test runner code.

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