# Test 6

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a 9x9 Sudoku validator and solver in C using the header file sudoku.h.

Board representation: a board is a flat `const int*` array of `n` ints in row-major
order (index = row * 9 + col), where 0 means an empty cell. A well-formed board has
exactly n == 81 cells. The nine 3x3 boxes start at rows/columns 0, 3 and 6.

- Implement `sudoku_is_valid(grid, n)`: Return true iff
  * n == 81,
  * every cell value is in 0..9, and
  * no digit 1..9 appears twice in any row, any column, or any 3x3 box.
  Zeros are ignored (an empty board is valid; a complete correct board is valid).
  Return false otherwise (wrong n, a value < 0 or > 9, or any duplicate). Check the
  length and value range before using a value as an index. Validity does NOT imply
  solvability.

- Implement `sudoku_candidates(grid, row, col, out)`: Precondition: grid has 81 cells
  and row, col are in 0..8 (0-based). If grid[row * 9 + col] != 0, return 0 and write
  nothing. Otherwise write to `out` the digits 1..9 that do not appear in that row,
  that column, or that cell's 3x3 box, in ascending order, and return how many were
  written. `out` is a caller-provided buffer with room for 9 ints. Only the row,
  column and box of that cell matter; the rest of the grid need not be valid.

- Implement `sudoku_solve(grid, n)`: Return a pointer to a freshly malloc'd array of
  81 ints containing a complete board (no zeros, valid, every non-zero input cell
  unchanged). Return NULL if `sudoku_is_valid(grid, n)` is false or no completion
  exists. If the input is already complete and valid, return an equal board (still a
  new allocation). The input `grid` must NOT be modified. If several solutions exist,
  any one is acceptable. The caller owns the result and releases it with
  `free_sudoku_grid`.

- Implement `sudoku_count_solutions(grid, n, limit)`: Return the number of distinct
  complete valid boards extending `grid`, but stop searching as soon as `limit`
  solutions have been found, so the result is min(total, limit). Return 0 if
  limit <= 0 or the board is invalid. Example: the empty board with limit 2 gives 2
  (the search must stop early; it must never try to enumerate all solutions).
  Must not modify the input.

- Implement `free_sudoku_grid`: Free a board returned by `sudoku_solve`.
  `free_sudoku_grid(NULL)` is a no-op.

Search requirement (solve and count):
  - Use recursive backtracking that always branches on the empty cell with the
    FEWEST candidates (MRV heuristic). A cell with zero candidates is a dead end
    (backtrack immediately).
  - Naive backtracking that fills cells in row-major order is too slow for some of
    the test puzzles (millions of nodes). Additional constraint propagation is
    allowed but not required.

Constraints:
  - No memory leaks (verified by valgrind); free every temporary allocation.
  - All functions must handle their edge cases without crashing.
```
