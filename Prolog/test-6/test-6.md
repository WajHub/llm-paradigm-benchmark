# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in SWI-Prolog in the module sudoku
(file sudoku.pl). Implement sudoku_is_valid/1, sudoku_candidates/4, sudoku_solve/2
and sudoku_count_solutions/3.

Board representation: a Grid is a flat list of 81 integers in row-major order
(Index = Row * 9 + Col, 0-based), where 0 means an empty cell. The nine 3x3 boxes
start at rows/cols 0, 3 and 6.

- Implement `sudoku_is_valid(+Grid)`: Succeeds if and only if Grid is a list of
  exactly 81 elements, every element is an integer in 0..9, and no digit 1..9
  appears twice in any row, any column or any 3x3 box. Zeros are ignored. Fails
  (never throws) otherwise: wrong length, a value outside 0..9, or a duplicate digit.
  * An empty board (81 zeros) is valid. A complete, correct board is valid.
  * Validity does NOT imply solvability.

- Implement `sudoku_candidates(+Grid, +Row, +Col, -Digits)`: Row and Col are
  0-based (0..8); Grid has 81 cells. If the cell at Row*9+Col is non-zero, Digits
  is []. Otherwise Digits is the list of digits 1..9 that do not appear in that
  cell's row, column or 3x3 box, in ascending order. Only that row, column and box
  matter; the rest of the grid does not have to be valid. Deterministic.

- Implement `sudoku_solve(+Grid, -Solution)`: Solution is a new complete board
  (81 integers, no zeros, valid) in which every non-zero cell of Grid is unchanged.
  If Grid is already complete and valid, Solution is equal to Grid. Unify Solution
  with the atom `none` if sudoku_is_valid(Grid) fails or no completion exists.
  Deterministic (a single answer).

- Implement `sudoku_count_solutions(+Grid, +Limit, -Count)`: Count is the number of
  distinct complete valid boards extending Grid, but the search must stop as soon
  as Limit solutions have been found, so Count = min(total, Limit). Count = 0 when
  Limit =< 0 or Grid is invalid. Example: the empty board with Limit 2 gives 2.

Search requirements:
  - Use backtracking search that always branches on the empty cell with the
    fewest candidates (MRV heuristic). A cell with zero candidates is a dead end.
  - Naive first-empty-cell (row-major) backtracking is too slow for some of the
    test puzzles. Additional constraint propagation is allowed.

Constraints:
  - Results are compared with ==: Digits must be a proper list of integers in
    ascending order, Solution a list of 81 integers or the atom `none`, Count an
    integer.
```
