object OrderStats {
  case class SelectResult(value: Int, pivots: Vector[Int])

  // Read-only sorted (non-decreasing) sequence; get(index) is 0-based, 0 <= index < length.
  // Every get call is counted by the tests; reading length is free.
  trait SortedSource {
    def length: Int
    def get(index: Int): Int
  }

  def medianOfMedians(xs: Vector[Int]): Option[Int] =
    sys.error("OrderStats.medianOfMedians not implemented")

  def selectKth(xs: Vector[Int], k: Int): Option[SelectResult] =
    sys.error("OrderStats.selectKth not implemented")

  def medianTwoSorted(a: SortedSource, b: SortedSource): Option[Double] =
    sys.error("OrderStats.medianTwoSorted not implemented")
}
