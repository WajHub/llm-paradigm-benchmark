You are a Scala programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `calculateCleanMinkowskiSum`: Calculate the Minkowski sum of two convex polygons (`poly1` and `poly2`), and return a new polygon representing ONLY the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points (collinear points on the edges must be removed) and ordered counter-clockwise.
- Implement `checkDynamicCollision`: Determine if a moving robot polygon intersects with a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum Configuration Space approach to prevent tunneling (continuous collision detection). Return true if a collision occurs, false otherwise.
- Use immutable data structures and `Option` to represent missing values.

General Requirements:
- Use idiomatic Scala.
- Prefer immutable data structures and pure functions where practical.
- Model absence with `Option` instead of null values.
- Return ONLY raw Scala code (no Markdown tags, no ```scala blocks, no side text). Your code will be directly saved to a `.scala` file and compiled.
- Do not provide test runner code.

object SpatialLogic {
  case class Point(pointX: Double, pointY: Double)

  case class Polygon(
      polygonVertices: Vector[Point],
      polygonNumVertices: Int,
      polygonIsConvex: Boolean,
      polygonZoneName: String
  )

  case class SpatialLayer(
      layerPolygons: Vector[Polygon],
      layerPolygonCount: Int,
      layerName: String
  )

  def calculateCleanMinkowskiSum(
      poly1: Option[Polygon],
      poly2: Option[Polygon]
  ): Option[Polygon] = sys.error("SpatialLogic.calculateCleanMinkowskiSum not implemented")

  def checkDynamicCollision(
      obstacle: Option[Polygon],
      robot: Option[Polygon],
      velocity: Point
  ): Boolean = sys.error("SpatialLogic.checkDynamicCollision not implemented")
}