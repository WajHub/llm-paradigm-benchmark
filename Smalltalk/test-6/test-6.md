# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a Sudoku validator and solver in GNU Smalltalk in the class SudokuImpl
(file SudokuImpl.st), which subclasses the abstract class Sudoku. Implement
isValid:, candidates:row:col:, solve: and countSolutions:limit:.
Put the solution in SudokuImpl.st.

Board representation:
  * A board (grid) is a flat Array of 81 Integers in row-major order; 0 = empty cell.
  * Rows and columns are numbered 1..9. The cell in row r, column c is stored at
    index (r - 1) * 9 + c of the flat Array (row 1 = indices 1..9, row 2 = indices
    10..18, ..., the last cell, row 9 column 9, is index 81).
  * The nine 3x3 boxes start at rows 1, 4, 7 and columns 1, 4, 7.
  * The tests pass literal/fresh Arrays; results are compared with `asArray =`, so
    any SequenceableCollection may be returned where an Array is expected.

- Implement `isValid: grid`: Answer true or false. The grid is valid only if
  ALL of the following hold:
    * it has exactly 81 elements (answer false for 80, 82, ... elements);
    * every element is an Integer in 0..9 (answer false for e.g. 10 or -1);
    * no digit 1..9 appears twice in any row, any column, or any of the nine 3x3
      boxes. Zeros (empty cells) are ignored, so an all-zero board is valid.
  A complete, correct board is valid. Validity does NOT imply solvability: a valid
  board may have no solution.

- Implement `candidates: grid row: r col: c`: r and c are 1-BASED (1..9) row and
  column numbers; the grid itself is still the flat 81-element Array, so the cell is
  `grid at: (r - 1) * 9 + c`. Precondition: grid has 81 cells and 1 <= r, c <= 9.
    * If that cell is non-zero (already filled), answer an empty collection.
    * Otherwise answer the digits 1..9 that do not appear in row r, in column c,
      or in the 3x3 box containing (r, c), in ascending order.
  Only the cell's row, column and box matter; the rest of the grid does not need
  to be valid. Example of the box rule: the cell in row 5, column 8 belongs to the
  box spanning rows 4..6 and columns 7..9.

- Implement `solve: grid`: Answer a NEW complete board (a fresh 81-element Array
  with no zeros, valid, every non-zero input cell unchanged), or nil.
    * Answer nil if `isValid: grid` is false or if the board has no solution.
    * If the input is already complete and valid, answer an equal board.
    * Must NOT modify the argument grid (work on a copy).
    * If several solutions exist, any one of them is acceptable.

- Implement `countSolutions: grid limit: n`: Answer the number of distinct complete
  valid boards that extend grid, but stop searching as soon as n solutions have
  been found, so the answer is min(total number of solutions, n).
    * Answer 0 if n <= 0 or if `isValid: grid` is false.
    * An empty (all-zero) board with limit 2 answers 2 - this is only possible
      with an early cut-off, the full count would never finish.

Search requirements:
  - Use recursive backtracking that always branches on the empty cell with the
    FEWEST candidates (MRV heuristic). A cell with zero candidates is a dead end:
    backtrack immediately.
  - Naive backtracking over cells in row-major order is far too slow for some of
    the test puzzles. Additional constraint propagation is allowed.
```
