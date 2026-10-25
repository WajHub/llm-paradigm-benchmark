You are a Scala programming expert. Your task is to implement the required functions in accordance with the provided module interface.

- Implement `maxValue`: Return the maximum value attainable with sum of selected weights ≤ capacity. Use DP. Return 0 if weights.isEmpty or capacity <= 0.
- Implement `solve`: Return Result(maxValue, selected, totalWeight) where selected is a Vector[Int] of 0/1 length n.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220, greedy=160).
- Selection invariants: sum(selected.zip(weights).map(p => p._1 * p._2)) ≤ capacity; sum of selected values = maxValue.
- Use idiomatic immutable Scala.

General Requirements:
- Use idiomatic Scala.
- Prefer immutable data structures and pure functions where practical.
- Model absence with `Option` instead of null values.
- Return ONLY raw Scala code (no Markdown tags, no ```scala blocks, no side text). Your code will be directly saved to a `.scala` file and compiled.
- Do not provide test runner code.

object Knapsack {
  case class Result(maxValue: Int, selected: Vector[Int], totalWeight: Int)

  def maxValue(weights: Vector[Int], values: Vector[Int], capacity: Int): Int =
    sys.error("Knapsack.maxValue not implemented")

  def solve(weights: Vector[Int], values: Vector[Int], capacity: Int): Result =
    sys.error("Knapsack.solve not implemented")
}