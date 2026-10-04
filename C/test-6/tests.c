#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "sudoku.h"

#define CELLS 81

/* Named boards, row-major, '0' / '.' = empty, spaces ignored. */
static const char* CLASSIC =
    "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079";
static const char* SOLVED =
    "534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179";
static const char* INKALA =
    "800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402";
static const char* INKALA_SOL =
    "812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452";
static const char* ANTI_BF =
    "000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009";
static const char* ANTI_BF_SOL =
    "987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219";

/* Parses a board string into out[0..80]. */
static void load(const char* s, int* out) {
    int i = 0;
    for (; *s && i < CELLS; s++) {
        if (*s >= '0' && *s <= '9') out[i++] = *s - '0';
        else if (*s == '.') out[i++] = 0;
    }
}

static void empty_grid(int* out) {
    for (int i = 0; i < CELLS; i++) out[i] = 0;
}

static bool grid_equals(const int* actual, const int* expected) {
    if (!actual) return false;
    return memcmp(actual, expected, CELLS * sizeof(int)) == 0;
}

/* Calls sudoku_solve, compares with the expected board string and frees the result. */
static bool solves_to(const int* grid, const char* expected_str) {
    int expected[CELLS];
    load(expected_str, expected);
    int* sol = sudoku_solve(grid, CELLS);
    bool ok = grid_equals(sol, expected);
    free_sudoku_grid(sol);
    return ok;
}

/* true iff sudoku_solve reports no solution (NULL). Frees any unexpected result. */
static bool solve_is_null(const int* grid, int n) {
    int* sol = sudoku_solve(grid, n);
    if (sol) {
        free_sudoku_grid(sol);
        return false;
    }
    return true;
}

static bool candidates_equal(const int* grid, int row, int col, const int* expected, int expected_n) {
    int out[9];
    int cnt = sudoku_candidates(grid, row, col, out);
    if (cnt != expected_n) return false;
    for (int i = 0; i < cnt; i++) {
        if (out[i] != expected[i]) return false;
    }
    return true;
}

static bool classic_valid(void) {
    int g[CELLS];
    load(CLASSIC, g);
    return sudoku_is_valid(g, CELLS);
}

// ============================================================================
// TESTY Algorytmu A: sudoku_is_valid / sudoku_candidates
// ============================================================================

bool test_algo_a_01_empty_grid_valid(void) {
    int g[CELLS];
    empty_grid(g);
    return sudoku_is_valid(g, CELLS) == true;
}

bool test_algo_a_02_solved_grid_valid(void) {
    int s[CELLS], c[CELLS];
    load(SOLVED, s);
    load(CLASSIC, c);
    return sudoku_is_valid(s, CELLS) == true
        && sudoku_is_valid(c, CELLS) == true;
}

bool test_algo_a_03_row_conflict(void) {
    int g[CELLS];
    load(CLASSIC, g);
    g[0 * 9 + 8] = 5;   /* row 0 already has 5 at (0,0) */
    return sudoku_is_valid(g, CELLS) == false && classic_valid();
}

bool test_algo_a_04_column_conflict(void) {
    int g[CELLS];
    load(CLASSIC, g);
    g[8 * 9 + 0] = 5;   /* column 0 already has 5 at (0,0) */
    return sudoku_is_valid(g, CELLS) == false && classic_valid();
}

bool test_algo_a_05_box_only_conflict(void) {
    int g1[CELLS], g2[CELLS];
    load(CLASSIC, g1);
    g1[1 * 9 + 1] = 8;  /* clashes only with (2,2)=8 in box 0 */
    empty_grid(g2);
    g2[0 * 9 + 0] = 1;
    g2[1 * 9 + 1] = 1;
    return sudoku_is_valid(g1, CELLS) == false
        && sudoku_is_valid(g2, CELLS) == false
        && classic_valid();
}

bool test_algo_a_06_wrong_length(void) {
    int zeros[CELLS + 1];
    memset(zeros, 0, sizeof(zeros));
    int solved_plus[CELLS + 1];
    load(SOLVED, solved_plus);
    solved_plus[CELLS] = 0;
    int solved[CELLS];
    load(SOLVED, solved);
    return sudoku_is_valid(zeros, 80) == false
        && sudoku_is_valid(zeros, 82) == false
        && sudoku_is_valid(solved_plus, 82) == false
        && sudoku_is_valid(solved, CELLS) == true;
}

bool test_algo_a_07_value_out_of_range(void) {
    int g1[CELLS], g2[CELLS];
    load(CLASSIC, g1);
    load(CLASSIC, g2);
    g1[0 * 9 + 2] = 10;
    g2[0 * 9 + 2] = -1;
    return sudoku_is_valid(g1, CELLS) == false
        && sudoku_is_valid(g2, CELLS) == false
        && classic_valid();
}

bool test_algo_a_08_candidates_basic(void) {
    int g[CELLS];
    load(CLASSIC, g);
    const int e1[] = { 1, 2, 4 };
    const int e2[] = { 5 };
    const int e3[] = { 1, 2, 3 };
    return candidates_equal(g, 0, 2, e1, 3)
        && candidates_equal(g, 4, 4, e2, 1)
        && candidates_equal(g, 8, 0, e3, 3);
}

bool test_algo_a_09_candidates_edge_cells(void) {
    int c[CELLS], e[CELLS];
    load(CLASSIC, c);
    empty_grid(e);
    const int all[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    return candidates_equal(c, 0, 0, NULL, 0)
        && candidates_equal(c, 8, 8, NULL, 0)
        && candidates_equal(e, 8, 8, all, 9);
}

bool test_algo_a_10_candidates_sweep(void) {
    int s[CELLS], c[CELLS];
    load(SOLVED, s);
    load(CLASSIC, c);
    bool ok = true;
    for (int r = 0; r < 9; r++) {
        for (int col = 0; col < 9; col++) {
            int g[CELLS];
            memcpy(g, s, sizeof(g));
            int digit = g[r * 9 + col];
            g[r * 9 + col] = 0;
            if (!candidates_equal(g, r, col, &digit, 1)) ok = false;
        }
    }
    int sum = 0;
    for (int r = 0; r < 9; r++) {
        for (int col = 0; col < 9; col++) {
            int out[9];
            sum += sudoku_candidates(c, r, col, out);
        }
    }
    return ok && sum == 153;
}

// ============================================================================
// TESTY Algorytmu B: sudoku_solve / sudoku_count_solutions
// ============================================================================

bool test_algo_b_01_already_solved(void) {
    int g[CELLS];
    load(SOLVED, g);
    return solves_to(g, SOLVED);
}

bool test_algo_b_02_classic_puzzle(void) {
    int g[CELLS], orig[CELLS];
    load(CLASSIC, g);
    load(CLASSIC, orig);
    bool solved = solves_to(g, SOLVED);
    return solved && grid_equals(g, orig);
}

bool test_algo_b_03_invalid_grid(void) {
    int box[CELLS], zeros[CELLS], range[CELLS];
    load(CLASSIC, box);
    box[1 * 9 + 1] = 8;
    memset(zeros, 0, sizeof(zeros));
    load(CLASSIC, range);
    range[0 * 9 + 2] = 10;
    bool a = solve_is_null(box, CELLS);
    bool b = solve_is_null(zeros, 80);
    bool c = solve_is_null(range, CELLS);
    return a && b && c
        && sudoku_count_solutions(box, CELLS, 5) == 0
        && sudoku_count_solutions(zeros, 80, 5) == 0;
}

bool test_algo_b_04_dead_cell(void) {
    int g[CELLS];
    empty_grid(g);
    for (int c = 0; c < 8; c++) g[c] = c + 1;   /* row 0 = 1 2 3 4 5 6 7 8 0 */
    g[4 * 9 + 8] = 9;                           /* (0,8) has no candidate */
    bool a = solve_is_null(g, CELLS);
    return a && sudoku_count_solutions(g, CELLS, 5) == 0;
}

bool test_algo_b_05_hidden_contradiction(void) {
    int g[CELLS];
    load(CLASSIC, g);
    g[0 * 9 + 2] = 1;
    bool a = solve_is_null(g, CELLS);
    return a && sudoku_count_solutions(g, CELLS, 5) == 0;
}

bool test_algo_b_06_backtracking_required(void) {
    int g[CELLS];
    load(INKALA, g);
    return solves_to(g, INKALA_SOL);
}

bool test_algo_b_07_count_unique(void) {
    int c[CELLS], s[CELLS];
    load(CLASSIC, c);
    load(SOLVED, s);
    return sudoku_count_solutions(c, CELLS, 2) == 1
        && sudoku_count_solutions(s, CELLS, 2) == 1;
}

bool test_algo_b_08_count_multiple(void) {
    int g[CELLS];
    load(CLASSIC, g);
    g[2 * 9 + 2] = 0;   /* MULTI: exactly 8 solutions */
    return sudoku_count_solutions(g, CELLS, 100) == 8
        && sudoku_count_solutions(g, CELLS, 5) == 5
        && sudoku_count_solutions(g, CELLS, 1) == 1;
}

bool test_algo_b_09_count_empty_grid_limit(void) {
    int g[CELLS];
    empty_grid(g);
    return sudoku_count_solutions(g, CELLS, 2) == 2
        && sudoku_count_solutions(g, CELLS, 1) == 1
        && sudoku_count_solutions(g, CELLS, 0) == 0
        && sudoku_count_solutions(g, CELLS, -3) == 0;
}

bool test_algo_b_10_stress_anti_brute_force(void) {
    int g[CELLS];
    load(ANTI_BF, g);
    return solves_to(g, ANTI_BF_SOL);
}

int main() {
    int failed_count = 0;
    const char* failed_tests[50];
    int total_tests = 0;

    #define RUN_TEST(func, name) \
        do { \
            total_tests++; \
            if (func()) { \
                printf("[PASS] %s\n", name); \
            } else { \
                printf("[FAIL] %s\n", name); \
                failed_tests[failed_count++] = name; \
            } \
        } while (0)

    printf("=== START ===\n");

    printf("\n--- Algorithm A: Validation and Candidates ---\n");
    RUN_TEST(test_algo_a_01_empty_grid_valid,        "Test A01 (Empty Grid Valid)");
    RUN_TEST(test_algo_a_02_solved_grid_valid,       "Test A02 (Solved Grid Valid)");
    RUN_TEST(test_algo_a_03_row_conflict,            "Test A03 (Row Conflict)");
    RUN_TEST(test_algo_a_04_column_conflict,         "Test A04 (Column Conflict)");
    RUN_TEST(test_algo_a_05_box_only_conflict,       "Test A05 (Box Only Conflict)");
    RUN_TEST(test_algo_a_06_wrong_length,            "Test A06 (Wrong Length)");
    RUN_TEST(test_algo_a_07_value_out_of_range,      "Test A07 (Value Out Of Range)");
    RUN_TEST(test_algo_a_08_candidates_basic,        "Test A08 (Candidates Basic)");
    RUN_TEST(test_algo_a_09_candidates_edge_cells,   "Test A09 (Candidates Edge Cells)");
    RUN_TEST(test_algo_a_10_candidates_sweep,        "Test A10 (Candidates Sweep)");

    printf("\n--- Algorithm B: Solving ---\n");
    RUN_TEST(test_algo_b_01_already_solved,          "Test B01 (Already Solved)");
    RUN_TEST(test_algo_b_02_classic_puzzle,          "Test B02 (Classic Puzzle)");
    RUN_TEST(test_algo_b_03_invalid_grid,            "Test B03 (Invalid Grid)");
    RUN_TEST(test_algo_b_04_dead_cell,               "Test B04 (Dead Cell)");
    RUN_TEST(test_algo_b_05_hidden_contradiction,    "Test B05 (Hidden Contradiction)");
    RUN_TEST(test_algo_b_06_backtracking_required,          "Test B06 (Backtracking Required)");
    RUN_TEST(test_algo_b_07_count_unique,            "Test B07 (Count Unique)");
    RUN_TEST(test_algo_b_08_count_multiple,          "Test B08 (Count Multiple)");
    RUN_TEST(test_algo_b_09_count_empty_grid_limit,  "Test B09 (Count Empty Grid Limit)");
    RUN_TEST(test_algo_b_10_stress_anti_brute_force, "Test B10 (Stress Anti Brute Force)");

    printf("\n=== BENCHMARK RESULTS ===\n");
    printf("Completed %d tests.\n", total_tests);

    if (failed_count == 0) {
        printf("All tests passed!\n");
        return 0;
    } else {
        printf("Tests that failed (%d):\n", failed_count);
        for (int i = 0; i < failed_count; i++) {
            printf(" - %s\n", failed_tests[i]);
        }
        return 1;
    }
}
