object Sudoku {

  private val units: Vector[Vector[Int]] = {
    val rows = (0 until 9).map(r => (0 until 9).map(c => r * 9 + c))
    val cols = (0 until 9).map(c => (0 until 9).map(r => r * 9 + c))
    val boxes = for {
      br <- 0 until 9 by 3
      bc <- 0 until 9 by 3
    } yield (0 until 9).map(k => (br + k / 3) * 9 + bc + k % 3)
    (rows ++ cols ++ boxes).map(_.toVector).toVector
  }

  def isValid(grid: Vector[Int]): Boolean =
    grid.size == 81 &&
      grid.forall(v => v >= 0 && v <= 9) &&
      units.forall { unit =>
        val vals = unit.map(grid).filter(_ != 0)
        vals.distinct.size == vals.size
      }

  def candidates(grid: Vector[Int], row: Int, col: Int): List[Int] = {
    val idx = row * 9 + col
    if (grid(idx) != 0) Nil
    else {
      val br = row / 3 * 3
      val bc = col / 3 * 3
      val used = (0 until 9).flatMap { k =>
        List(
          grid(row * 9 + k),
          grid(k * 9 + col),
          grid((br + k / 3) * 9 + bc + k % 3)
        )
      }.toSet
      (1 to 9).filterNot(used.contains).toList
    }
  }

  // None: no empty cells (complete board).
  // Some((idx, Nil)): dead end.
  // Some((idx, cands)): empty cell with fewest candidates.
  private def mrv(grid: Vector[Int]): Option[(Int, List[Int])] = {
    val empties = (0 until 81).iterator
      .filter(i => grid(i) == 0)
      .map(i => (i, candidates(grid, i / 9, i % 9)))
      .toList
    if (empties.isEmpty) None
    else Some(empties.minBy(_._2.size))
  }

  def solve(grid: Vector[Int]): Option[Vector[Int]] = {
    def search(g: Vector[Int]): Option[Vector[Int]] = mrv(g) match {
      case None => Some(g)
      case Some((_, Nil)) => None
      case Some((idx, cands)) =>
        cands.iterator
          .map(d => search(g.updated(idx, d)))
          .collectFirst { case Some(s) => s }
    }

    if (!isValid(grid)) None
    else search(grid)
  }

  def countSolutions(grid: Vector[Int], limit: Int): Int = {
    def count(g: Vector[Int], remaining: Int): Int =
      if (remaining <= 0) 0
      else mrv(g) match {
        case None => 1
        case Some((_, Nil)) => 0
        case Some((idx, cands)) =>
          cands.foldLeft(0) { (acc, d) =>
            if (acc >= remaining) acc
            else acc + count(g.updated(idx, d), remaining - acc)
          }
      }

    if (limit <= 0 || !isValid(grid)) 0
    else count(grid, limit)
  }
}
