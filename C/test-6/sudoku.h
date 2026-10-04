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
