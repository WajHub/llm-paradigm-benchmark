object Sudoku {
  def isValid(grid: Vector[Int]): Boolean =
    sys.error("Sudoku.isValid not implemented")

  def candidates(grid: Vector[Int], row: Int, col: Int): List[Int] =
    sys.error("Sudoku.candidates not implemented")

  def solve(grid: Vector[Int]): Option[Vector[Int]] =
    sys.error("Sudoku.solve not implemented")

  def countSolutions(grid: Vector[Int], limit: Int): Int =
    sys.error("Sudoku.countSolutions not implemented")
}
