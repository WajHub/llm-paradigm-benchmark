# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in Free Pascal in the unit sudoku
(file sudoku.pas). The unit already declares the type and the four functions; keep the
interface unchanged and implement SudokuIsValid, SudokuCandidates, SudokuSolve and
SudokuCountSolutions in the implementation section.

Board representation:
  * A board is a TIntArray (array of LongInt) of 81 cells in row-major order:
    index = Row * 9 + Col, Row and Col are 0-based (0..8). 0 means an empty cell,
    1..9 is a filled cell.
  * Boxes are the nine 3x3 blocks whose top-left corners are at rows/cols 0, 3, 6.

- Implement `SudokuIsValid(const Grid: TIntArray): Boolean`: Return True iff
  * Length(Grid) = 81, and
  * every cell value is in 0..9 (anything else, e.g. 10 or -1, makes the board invalid), and
  * no digit 1..9 appears more than once in any row, any column or any 3x3 box.
  Zeros are ignored (an empty board is valid; a complete correct board is valid).
  Validity does NOT imply solvability.

- Implement `SudokuCandidates(const Grid: TIntArray; Row, Col: LongInt): TIntArray`:
  Precondition: Length(Grid) = 81 and Row, Col in 0..8.
  * If Grid[Row * 9 + Col] <> 0, return an empty array (Length 0).
  * Otherwise return the digits 1..9 that do not appear in that row, that column or that
    cell's 3x3 box, in ascending order.
  * Only the cell's own row, column and box matter; the rest of the board does not have
    to be valid.

- Implement `SudokuSolve(const Grid: TIntArray): TIntArray`: Return a NEW array of 81
  cells holding a complete board (no zeros, valid) in which every non-zero input cell is
  unchanged.
  * Return an empty array (Length 0) if SudokuIsValid(Grid) is False or the board has no
    completion.
  * If the input is already complete and valid, return an equal board.
  * The caller's array must NOT be modified. Note that `const` on a dynamic array
    parameter does not protect its elements, and assigning one dynamic array variable to
    another shares the same storage: work on a copy (e.g. Copy(Grid, 0, 81)).
  * If several solutions exist any one is acceptable.

- Implement `SudokuCountSolutions(const Grid: TIntArray; Limit: LongInt): LongInt`:
  Return the number of distinct complete valid boards extending Grid, but stop searching
  as soon as Limit solutions have been found, so the result is min(total, Limit).
  * Return 0 if Limit <= 0 or SudokuIsValid(Grid) is False.
  * An empty board with Limit 2 returns 2 (the search must cut off early).
  * The caller's array must not be modified.

Search requirements:
  - Use recursive backtracking that always branches on the empty cell with the FEWEST
    candidates (MRV heuristic). An empty cell with zero candidates is a dead end
    (backtrack immediately).
  - Naive first-empty-cell (row-major) backtracking is too slow for some test puzzles.
    Additional constraint propagation is allowed.

Memory:
  - All results are managed dynamic arrays (TIntArray); no pointers, New/Dispose or
    GetMem are needed. The program is run under valgrind and must not leak.
```
