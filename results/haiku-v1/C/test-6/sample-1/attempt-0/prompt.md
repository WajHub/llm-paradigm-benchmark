You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

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

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

#ifndef SUDOKU_H
#define SUDOKU_H

#include <stdbool.h>

/*
 * A board is a flat array of n ints in row-major order (index = row * 9 + col),
 * 0 = empty cell. A well-formed board has exactly n == 81 cells.
 */

/* true iff n == 81, every cell is in 0..9 and no digit 1..9 repeats in any row,
   column or 3x3 box (zeros ignored). */
bool sudoku_is_valid(const int* grid, int n);

/* grid has 81 cells, row/col in 0..8. Writes the candidate digits of cell (row, col)
   in ascending order to out (caller buffer, capacity >= 9) and returns their count;
   returns 0 if the cell is already filled. */
int sudoku_candidates(const int* grid, int row, int col, int* out);

/* Returns a fresh malloc'd array of 81 ints holding a complete solution, or NULL if
   the board is invalid or has no solution. Does not modify grid.
   Caller frees with free_sudoku_grid. */
int* sudoku_solve(const int* grid, int n);

/* Number of solutions, capped at limit (search stops after limit solutions).
   0 if the board is invalid or limit <= 0. */
int sudoku_count_solutions(const int* grid, int n, int limit);

/* Frees a board returned by sudoku_solve. Accepts NULL. */
void free_sudoku_grid(int* grid);

#endif