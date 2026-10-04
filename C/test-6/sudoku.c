#include "sudoku.h"
#include <stdlib.h>

bool sudoku_is_valid(const int* grid, int n) {
    (void)grid; (void)n;
    return false;
}

int sudoku_candidates(const int* grid, int row, int col, int* out) {
    (void)grid; (void)row; (void)col; (void)out;
    return -1;
}

int* sudoku_solve(const int* grid, int n) {
    (void)grid; (void)n;
    return NULL;
}

int sudoku_count_solutions(const int* grid, int n, int limit) {
    (void)grid; (void)n; (void)limit;
    return -1;
}

void free_sudoku_grid(int* grid) {
    (void)grid;
}
