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

  private val Eps = 1e-9

  private def cross(o: Point, a: Point, b: Point): Double =
    (a.pointX - o.pointX) * (b.pointY - o.pointY) -
      (a.pointY - o.pointY) * (b.pointX - o.pointX)

  private def sign(d: Double): Int =
    if (d > Eps) 1 else if (d < -Eps) -1 else 0

  private def onBox(a: Point, b: Point, p: Point): Boolean =
    p.pointX >= math.min(a.pointX, b.pointX) - Eps &&
      p.pointX <= math.max(a.pointX, b.pointX) + Eps &&
      p.pointY >= math.min(a.pointY, b.pointY) - Eps &&
      p.pointY <= math.max(a.pointY, b.pointY) + Eps

  private def segmentsIntersect(p1: Point, p2: Point, q1: Point, q2: Point): Boolean = {
    val d1 = sign(cross(q1, q2, p1))
    val d2 = sign(cross(q1, q2, p2))
    val d3 = sign(cross(p1, p2, q1))
    val d4 = sign(cross(p1, p2, q2))
    (d1 * d2 < 0 && d3 * d4 < 0) ||
      (d1 == 0 && onBox(q1, q2, p1)) ||
      (d2 == 0 && onBox(q1, q2, p2)) ||
      (d3 == 0 && onBox(p1, p2, q1)) ||
      (d4 == 0 && onBox(p1, p2, q2))
  }

  private def edgesOf(poly: Vector[Point]): Vector[(Point, Point)] = {
    val n = poly.size
    poly.indices.map(i => (poly(i), poly((i + 1) % n))).toVector
  }

  private def insideConvex(poly: Vector[Point], p: Point): Boolean =
    poly.size >= 3 && edgesOf(poly).forall { case (a, b) => sign(cross(a, b, p)) >= 0 }

  private def pushHull(stack: List[Point], p: Point): List[Point] = stack match {
    case b :: a :: rest if cross(a, b, p) <= 0 => pushHull(a :: rest, p)
    case _                                     => p :: stack
  }

  private def convexHull(points: Vector[Point]): Vector[Point] = {
    val sorted = points.distinct.sortBy(p => (p.pointX, p.pointY))
    if (sorted.size < 3) sorted
    else {
      val lower = sorted.foldLeft(List.empty[Point])(pushHull)
      val upper = sorted.reverse.foldLeft(List.empty[Point])(pushHull)
      (lower.reverse.init ++ upper.reverse.init).toVector
    }
  }

  def calculateCleanMinkowskiSum(
      poly1: Option[Polygon],
      poly2: Option[Polygon]
  ): Option[Polygon] =
    for {
      p1 <- poly1
      p2 <- poly2
      sums = for {
        a <- p1.polygonVertices
        b <- p2.polygonVertices
      } yield Point(a.pointX + b.pointX, a.pointY + b.pointY)
      hull = convexHull(sums)
      if hull.nonEmpty
    } yield Polygon(
      polygonVertices = hull,
      polygonNumVertices = hull.size,
      polygonIsConvex = true,
      polygonZoneName = s"${p1.polygonZoneName}+${p2.polygonZoneName}"
    )

  def checkDynamicCollision(
      obstacle: Option[Polygon],
      robot: Option[Polygon],
      velocity: Point
  ): Boolean =
    (obstacle, robot) match {
      case (Some(o), Some(r)) =>
        val reflectedRobot = r.copy(
          polygonVertices = r.polygonVertices.map(p => Point(-p.pointX, -p.pointY))
        )
        calculateCleanMinkowskiSum(Some(o), Some(reflectedRobot)).exists { cspace =>
          val origin = Point(0.0, 0.0)
          val cs = cspace.polygonVertices
          insideConvex(cs, origin) ||
            insideConvex(cs, velocity) ||
            edgesOf(cs).exists { case (a, b) =>
              segmentsIntersect(origin, velocity, a, b)
            }
        }
      case _ => false
    }
}
