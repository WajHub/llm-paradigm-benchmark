object Knapsack {
  case class Result(maxValue: Int, selected: Vector[Int], totalWeight: Int)

  // Builds the full DP table: row i holds best values using the first i items
  // for every capacity in 0..capacity.
  private def table(weights: Vector[Int], values: Vector[Int], capacity: Int): Vector[Vector[Int]] =
    weights.zip(values).foldLeft(Vector(Vector.fill(capacity + 1)(0))) { case (rows, (w, v)) =>
      val prev = rows.last
      val next = Vector.tabulate(capacity + 1) { c =>
        if (w <= c) math.max(prev(c), prev(c - w) + v) else prev(c)
      }
      rows :+ next
    }

  def maxValue(weights: Vector[Int], values: Vector[Int], capacity: Int): Int =
    if (weights.isEmpty || capacity <= 0) 0
    else table(weights, values, capacity).last.last

  def solve(weights: Vector[Int], values: Vector[Int], capacity: Int): Result =
    if (weights.isEmpty || capacity <= 0) Result(0, Vector.fill(weights.length)(0), 0)
    else {
      val dp = table(weights, values, capacity)
      val n = weights.length

      // Backtrack from the last item to the first to recover the selection.
      val (selectedRev, _) =
        (n to 1 by -1).foldLeft((List.empty[Int], capacity)) { case ((acc, c), i) =>
          val w = weights(i - 1)
          if (dp(i)(c) != dp(i - 1)(c)) (1 :: acc, c - w)
          else (0 :: acc, c)
        }

      val selected = selectedRev.toVector
      val totalWeight = selected.zip(weights).collect { case (1, w) => w }.sum

      Result(dp.last.last, selected, totalWeight)
    }
}
