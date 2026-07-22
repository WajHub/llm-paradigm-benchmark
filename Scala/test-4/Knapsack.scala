object Knapsack {
  case class Result(maxValue: Int, selected: Vector[Int], totalWeight: Int)

  def maxValue(weights: Vector[Int], values: Vector[Int], capacity: Int): Int =
    sys.error("Knapsack.maxValue not implemented")

  def solve(weights: Vector[Int], values: Vector[Int], capacity: Int): Result =
    sys.error("Knapsack.solve not implemented")
}
