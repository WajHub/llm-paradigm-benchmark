# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in Java in the class SudokuImpl
(file SudokuImpl.java), which extends the abstract class Sudoku.

Board representation: a Sudoku board is an int[] of 81 cells in row-major order,
index = row * 9 + col (row and col are 0-based, 0..8). The value 0 means an empty
cell, 1..9 are digits. The nine 3x3 boxes start at rows/columns 0, 3 and 6.

- Implement `boolean isValid(int[] grid)`: return true iff
  * grid.length == 81, and
  * every cell is in 0..9, and
  * no digit 1..9 appears more than once in any row, any column, or any of the
    nine 3x3 boxes. Zeros (empty cells) are ignored.
  Return false otherwise (wrong length, a value outside 0..9, or a duplicate digit).
  An empty board (all zeros) is valid. A complete, correct board is valid.
  Validity does NOT imply solvability.

- Implement `int[] candidates(int[] grid, int row, int col)`: precondition: grid has
  81 cells and row, col are in 0..8.
  * If grid[row * 9 + col] != 0 (the cell is filled), return an empty array.
  * Otherwise return the digits 1..9 that do not appear in that cell's row, column,
    or 3x3 box, in ascending order.
  * Only the cell's row, column and box matter; the rest of the grid does not have
    to be valid.
  * Never return null (use an empty int[] when there are no candidates).

- Implement `int[] solve(int[] grid)`: return a NEW complete board (81 cells, no
  zeros, valid) in which every non-zero cell of the input is unchanged.
  * Return null if isValid(grid) is false or the board has no solution.
  * If the input is already complete and valid, return an equal board.
  * The input array must NOT be modified.
  * If the puzzle has several solutions, any one of them is acceptable.

- Implement `int countSolutions(int[] grid, int limit)`: return the number of
  distinct complete valid boards extending grid, but stop searching as soon as
  `limit` solutions have been found, so the result is min(total, limit).
  * Return 0 if limit <= 0 or isValid(grid) is false.
  * The input array must not be modified.
  * Example: an empty board with limit 2 gives 2 (the search must stop early).

Search requirements (solve and countSolutions):
  - Use recursive backtracking that always branches on the empty cell with the
    FEWEST candidates (MRV heuristic). An empty cell with zero candidates is a dead
    end: backtrack immediately.
  - Naive backtracking that fills cells in row-major order is too slow for some of
    the test puzzles. Additional constraint propagation is allowed.

Keep the contract in Sudoku.java; put the solution in SudokuImpl.java.
```
