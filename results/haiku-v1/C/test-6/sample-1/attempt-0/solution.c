#include "sudoku.h"
#include <stdlib.h>
#include <string.h>

typedef struct {
    int limit;
    int count;
    bool found;
    int sol[81];
} SearchCtx;

static int popcount9(unsigned m) {
    int c = 0;
    while (m) {
        m &= m - 1;
        c++;
    }
    return c;
}

static bool check_valid(const int* grid, int n) {
    unsigned rows[9] = {0}, cols[9] = {0}, boxes[9] = {0};
    if (grid == NULL || n != 81) return false;
    for (int i = 0; i < 81; i++) {
        int v = grid[i];
        if (v < 0 || v > 9) return false;
        if (v == 0) continue;
        int r = i / 9, c = i % 9, b = (r / 3) * 3 + (c / 3);
        unsigned bit = 1u << v;
        if (rows[r] & bit) return false;
        if (cols[c] & bit) return false;
        if (boxes[b] & bit) return false;
        rows[r] |= bit;
        cols[c] |= bit;
        boxes[b] |= bit;
    }
    return true;
}

static void init_masks(const int* g, unsigned* rows, unsigned* cols, unsigned* boxes) {
    for (int i = 0; i < 9; i++) {
        rows[i] = 0;
        cols[i] = 0;
        boxes[i] = 0;
    }
    for (int i = 0; i < 81; i++) {
        int v = g[i];
        if (v == 0) continue;
        int r = i / 9, c = i % 9, b = (r / 3) * 3 + (c / 3);
        unsigned bit = 1u << v;
        rows[r] |= bit;
        cols[c] |= bit;
        boxes[b] |= bit;
    }
}

static void search(SearchCtx* ctx, int* g, unsigned* rows, unsigned* cols,
                   unsigned* boxes, int empties) {
    if (empties == 0) {
        ctx->count++;
        if (!ctx->found) {
            memcpy(ctx->sol, g, sizeof(int) * 81);
            ctx->found = true;
        }
        return;
    }

    int best = -1;
    int bestc = 10;
    unsigned bestmask = 0;
    for (int i = 0; i < 81; i++) {
        if (g[i] != 0) continue;
        int r = i / 9, c = i % 9, b = (r / 3) * 3 + (c / 3);
        unsigned avail = (~(rows[r] | cols[c] | boxes[b])) & 0x3FEu;
        int pc = popcount9(avail);
        if (pc == 0) return;
        if (pc < bestc) {
            bestc = pc;
            best = i;
            bestmask = avail;
            if (pc == 1) break;
        }
    }
    if (best < 0) return;

    int r = best / 9, c = best % 9, b = (r / 3) * 3 + (c / 3);
    for (int d = 1; d <= 9; d++) {
        if (!(bestmask & (1u << d))) continue;
        unsigned bit = 1u << d;
        g[best] = d;
        rows[r] |= bit;
        cols[c] |= bit;
        boxes[b] |= bit;

        search(ctx, g, rows, cols, boxes, empties - 1);

        g[best] = 0;
        rows[r] &= ~bit;
        cols[c] &= ~bit;
        boxes[b] &= ~bit;

        if (ctx->count >= ctx->limit) return;
    }
}

bool sudoku_is_valid(const int* grid, int n) {
    return check_valid(grid, n);
}

int sudoku_candidates(const int* grid, int row, int col, int* out) {
    if (grid == NULL || out == NULL) return 0;
    if (row < 0 || row > 8 || col < 0 || col > 8) return 0;
    int idx = row * 9 + col;
    if (grid[idx] != 0) return 0;

    unsigned used = 0;
    int b = (row / 3) * 3 + (col / 3);
    int br = (row / 3) * 3, bc = (col / 3) * 3;
    for (int k = 0; k < 9; k++) {
        int v;
        v = grid[row * 9 + k];
        if (v >= 1 && v <= 9) used |= 1u << v;
        v = grid[k * 9 + col];
        if (v >= 1 && v <= 9) used |= 1u << v;
        v = grid[(br + k / 3) * 9 + (bc + k % 3)];
        if (v >= 1 && v <= 9) used |= 1u << v;
    }
    (void)b;

    int cnt = 0;
    for (int d = 1; d <= 9; d++) {
        if (!(used & (1u << d))) out[cnt++] = d;
    }
    return cnt;
}

int* sudoku_solve(const int* grid, int n) {
    if (!check_valid(grid, n)) return NULL;

    int* g = (int*)malloc(sizeof(int) * 81);
    if (!g) return NULL;
    memcpy(g, grid, sizeof(int) * 81);

    unsigned rows[9], cols[9], boxes[9];
    init_masks(g, rows, cols, boxes);
    int empties = 0;
    for (int i = 0; i < 81; i++) if (g[i] == 0) empties++;

    SearchCtx ctx;
    ctx.limit = 1;
    ctx.count = 0;
    ctx.found = false;

    search(&ctx, g, rows, cols, boxes, empties);
    free(g);

    if (!ctx.found) return NULL;

    int* result = (int*)malloc(sizeof(int) * 81);
    if (!result) return NULL;
    memcpy(result, ctx.sol, sizeof(int) * 81);
    return result;
}

int sudoku_count_solutions(const int* grid, int n, int limit) {
    if (limit <= 0) return 0;
    if (!check_valid(grid, n)) return 0;

    int g[81];
    memcpy(g, grid, sizeof(int) * 81);

    unsigned rows[9], cols[9], boxes[9];
    init_masks(g, rows, cols, boxes);
    int empties = 0;
    for (int i = 0; i < 81; i++) if (g[i] == 0) empties++;

    SearchCtx ctx;
    ctx.limit = limit;
    ctx.count = 0;
    ctx.found = false;

    search(&ctx, g, rows, cols, boxes, empties);
    return ctx.count;
}

void free_sudoku_grid(int* grid) {
    free(grid);
}
