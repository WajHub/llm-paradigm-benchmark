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