# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in Scala in the object Sudoku
(file Sudoku.scala). Implement isValid, candidates, solve and countSolutions.

Board representation:
  * A board is a Vector[Int] of 81 cells in row-major order:
    index = row * 9 + col, with row and col 0-based (0..8).
  * 0 means an empty cell; 1..9 are filled cells.
  * The nine 3x3 boxes start at rows/columns 0, 3 and 6
    (the box of (row, col) starts at (row / 3 * 3, col / 3 * 3)).

- Implement `isValid(grid: Vector[Int]): Boolean`: Return true if and only if
  * grid has exactly 81 cells,
  * every cell is in 0..9, and
  * no digit 1..9 appears more than once in any row, any column or any of the
    nine 3x3 boxes. Zeros are ignored (an all-zero board is valid).
  Otherwise return false (wrong length, value outside 0..9, or a duplicate).
  A complete, correct board is valid. Validity does NOT imply solvability.

- Implement `candidates(grid: Vector[Int], row: Int, col: Int): List[Int]`:
  Precondition: grid has 81 cells and row, col are in 0..8.
  * If grid(row * 9 + col) != 0 (the cell is filled), return Nil.
  * Otherwise return the digits 1..9 that do not appear in that row, that
    column, or that cell's 3x3 box, in ascending order.
  Only that row, column and box matter; the rest of the board does not have to
  be valid.

- Implement `solve(grid: Vector[Int]): Option[Vector[Int]]`:
  * Return None if isValid(grid) is false or if the board has no completion.
  * Otherwise return Some(new board): 81 cells, no zeros, valid, and every
    non-zero cell of the input unchanged. If the input is already complete and
    valid, return Some of an equal board.
  * The input must not be modified.
  * If several solutions exist, any one of them is acceptable.

- Implement `countSolutions(grid: Vector[Int], limit: Int): Int`: Return the
  number of distinct complete valid boards extending grid, but stop searching
  as soon as `limit` solutions have been found, so the result is
  min(total number of solutions, limit).
  * Return 0 if limit <= 0 or isValid(grid) is false.
  * Example: the all-zero board with limit 2 gives 2 (the search must stop early;
    it can never enumerate all solutions of an empty board).

Search requirements:
  - Use recursive backtracking that always branches on the empty cell with the
    FEWEST candidates (MRV heuristic). An empty cell with zero candidates is a
    dead end: backtrack immediately.
  - Naive backtracking that fills cells in row-major order is too slow for some
    of the test puzzles. Additional constraint propagation is allowed.
  - Solving only by forced moves (cells with a single candidate) is not enough;
    hard puzzles require search.
```
