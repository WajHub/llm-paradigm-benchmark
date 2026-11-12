object TspApprox {
  case class TourResult(tour: Vector[Int], cost: Int)

  def mstWeight(points: Vector[(Int, Int)]): Int =
    sys.error("TspApprox.mstWeight not implemented")

  def doubleTree(points: Vector[(Int, Int)]): Option[TourResult] =
    sys.error("TspApprox.doubleTree not implemented")

  def matchingWeight(points: Vector[(Int, Int)]): Int =
    sys.error("TspApprox.matchingWeight not implemented")

  def christofides(points: Vector[(Int, Int)]): Option[TourResult] =
    sys.error("TspApprox.christofides not implemented")
}
