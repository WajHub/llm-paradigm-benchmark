#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "tsp_approx.h"

#define COUNT(arr) ((int)(sizeof(arr) / sizeof((arr)[0])))

static const TspPoint SINGLE[] = { {5, 5} };
static const TspPoint TWO[] = { {0, 0}, {3, 4} };
static const TspPoint COLLINEAR[] = { {0, 0}, {4, 0}, {1, 0}, {9, 0}, {6, 0} };
static const TspPoint SQUARE[] = { {0, 0}, {0, 2}, {2, 2}, {2, 0} };
static const TspPoint PARENT_TIE[] = { {2, 0}, {0, 3}, {2, 3}, {3, 4}, {1, 4} };
static const TspPoint GRID[] = {
    {0, 0}, {1, 0}, {2, 0}, {0, 1}, {1, 1}, {2, 1}, {0, 2}, {1, 2}, {2, 2}
};
static const TspPoint DUP[] = { {3, 3}, {3, 3}, {0, 0}, {3, 3} };
static const TspPoint STAR[] = { {5, 5}, {5, 0}, {0, 5}, {10, 5} };
static const TspPoint CLUSTERS[] = {
    {0, 0}, {20, 0}, {1, 1}, {21, 1}, {0, 20}, {20, 20}, {1, 21}, {21, 21}
};
static const TspPoint SPIRAL[] = {
    {0, 0}, {8, 0}, {8, 8}, {0, 8}, {2, 2}, {6, 2}, {6, 6}, {2, 6}, {4, 4}
};
static const TspPoint S12[] = {
    {81, 33}, {69, 61}, {56, 93}, {77, 0}, {65, 25}, {72, 14},
    {14, 48}, {33, 32}, {73, 63}, {71, 87}, {5, 8}, {54, 24}
};
static const TspPoint S20[] = {
    {38, 58}, {13, 15}, {51, 27}, {10, 19}, {12, 86}, {49, 67}, {84, 60}, {25, 43}, {89, 83}, {37, 66},
    {66, 78}, {95, 11}, {67, 54}, {31, 45}, {82, 36}, {24, 5}, {94, 2}, {51, 67}, {54, 53}, {61, 96}
};
static const TspPoint S40[] = {
    {81, 33}, {69, 61}, {56, 93}, {77, 0}, {65, 25}, {72, 14}, {14, 48}, {33, 32}, {73, 63}, {71, 87},
    {5, 8}, {54, 24}, {22, 71}, {51, 45}, {55, 89}, {29, 78}, {87, 65}, {32, 67}, {53, 10}, {27, 83},
    {36, 30}, {41, 96}, {2, 37}, {8, 85}, {78, 74}, {59, 59}, {76, 26}, {9, 63}, {63, 86}, {7, 17},
    {91, 65}, {27, 22}, {7, 85}, {95, 32}, {35, 71}, {7, 65}, {12, 61}, {82, 60}, {5, 35}, {74, 66}
};

static int dist(TspPoint p, TspPoint q) {
    return abs(p.x - q.x) + abs(p.y - q.y);
}

/* true iff r holds a tour over all n vertices: permutation of 0..n-1, starting
   with 0, and r->cost equals the closed-tour cost recomputed from the points. */
static bool valid_tour(const TourResult* r, const TspPoint* pts, int n) {
    if (!r || !r->tour || r->n != n || n <= 0) return false;
    if (r->tour[0] != 0) return false;
    bool seen[64] = { false };
    for (int i = 0; i < n; i++) {
        int v = r->tour[i];
        if (v < 0 || v >= n || seen[v]) return false;
        seen[v] = true;
    }
    int cost = 0;
    if (n > 1) {
        for (int i = 0; i < n; i++) cost += dist(pts[r->tour[i]], pts[r->tour[(i + 1) % n]]);
    }
    return r->cost == cost;
}

/* Double-tree tour must equal expected exactly, with the given cost, and the
   MST weight must equal mst. */
static bool double_tree_is(const TspPoint* pts, int n, const int* expected, int cost, int mst) {
    if (tsp_mst_weight(pts, n) != mst) return false;
    TourResult* r = tsp_double_tree(pts, n);
    bool ok = valid_tour(r, pts, n) && r->cost == cost
        && memcmp(r->tour, expected, (size_t)n * sizeof(int)) == 0;
    free_tour_result(r);
    return ok;
}

/* Matching weight must equal matching; the Christofides tour must be valid and
   satisfy cost <= max_cost (if exact_cost >= 0: cost == exact_cost; if opt >= 0:
   2*cost <= 3*opt). */
static bool christofides_ok(const TspPoint* pts, int n, int matching,
                            int max_cost, int exact_cost, int opt) {
    if (tsp_matching_weight(pts, n) != matching) return false;
    TourResult* r = tsp_christofides(pts, n);
    bool ok = valid_tour(r, pts, n) && r->cost <= max_cost;
    if (ok && exact_cost >= 0) ok = r->cost == exact_cost;
    if (ok && opt >= 0) ok = 2 * r->cost <= 3 * opt;
    free_tour_result(r);
    return ok;
}

// ============================================================================
// TESTY Algorytmu A: tsp_mst_weight / tsp_double_tree
// ============================================================================

bool test_algo_a_01_empty(void) {
    if (tsp_mst_weight(NULL, 0) != 0) return false;
    TourResult* r = tsp_double_tree(NULL, 0);
    if (r) {
        free_tour_result(r);
        return false;
    }
    return true;
}

bool test_algo_a_02_single_point(void) {
    const int e[] = { 0 };
    return double_tree_is(SINGLE, COUNT(SINGLE), e, 0, 0);
}

bool test_algo_a_03_two_points(void) {
    const int e[] = { 0, 1 };
    return double_tree_is(TWO, COUNT(TWO), e, 14, 7);
}

bool test_algo_a_04_collinear_unsorted(void) {
    const int e[] = { 0, 2, 1, 4, 3 };
    return double_tree_is(COLLINEAR, COUNT(COLLINEAR), e, 18, 9);
}

bool test_algo_a_05_square(void) {
    const int e[] = { 0, 1, 2, 3 };
    return double_tree_is(SQUARE, COUNT(SQUARE), e, 8, 6);
}

bool test_algo_a_06_parent_tie_breaking(void) {
    const int e[] = { 0, 2, 1, 4, 3 };
    return double_tree_is(PARENT_TIE, COUNT(PARENT_TIE), e, 14, 9);
}

bool test_algo_a_07_grid_ties(void) {
    const int e[] = { 0, 1, 2, 5, 8, 4, 7, 3, 6 };
    return double_tree_is(GRID, COUNT(GRID), e, 12, 8);
}

bool test_algo_a_08_duplicate_points(void) {
    const int e[] = { 0, 1, 2, 3 };
    return double_tree_is(DUP, COUNT(DUP), e, 12, 6);
}

bool test_algo_a_09_clusters_two_approx(void) {
    const int e[] = { 0, 1, 3, 5, 7, 2, 4, 6 };
    return double_tree_is(CLUSTERS, COUNT(CLUSTERS), e, 128, 68) && 128 <= 2 * 88;
}

bool test_algo_a_10_stress(void) {
    int n = COUNT(S40);
    if (tsp_mst_weight(S40, n) != 503) return false;
    TourResult* r = tsp_double_tree(S40, n);
    bool ok = valid_tour(r, S40, n) && r->cost == 832;
    free_tour_result(r);
    return ok;
}

// ============================================================================
// TESTY Algorytmu B: tsp_matching_weight / tsp_christofides
// ============================================================================

bool test_algo_b_01_empty(void) {
    if (tsp_matching_weight(NULL, 0) != 0) return false;
    TourResult* r = tsp_christofides(NULL, 0);
    if (r) {
        free_tour_result(r);
        return false;
    }
    return true;
}

bool test_algo_b_02_two_points_double_edge(void) {
    /* a valid tour of 2 vertices starting with 0 is exactly [0, 1] */
    return christofides_ok(TWO, COUNT(TWO), 7, 14, 14, -1);
}

bool test_algo_b_03_star_parallel_edges(void) {
    return christofides_ok(STAR, COUNT(STAR), 15, 30, 30, -1);
}

bool test_algo_b_04_collinear(void) {
    return christofides_ok(COLLINEAR, COUNT(COLLINEAR), 9, 18, 18, -1);
}

bool test_algo_b_05_grid(void) {
    return christofides_ok(GRID, COUNT(GRID), 4, 12, -1, -1);
}

bool test_algo_b_06_beats_double_tree(void) {
    return christofides_ok(CLUSTERS, COUNT(CLUSTERS), 24, 92, -1, -1);
}

bool test_algo_b_07_spiral_bound(void) {
    return christofides_ok(SPIRAL, COUNT(SPIRAL), 20, 52, -1, 44);
}

bool test_algo_b_08_greedy_matching_trap(void) {
    return christofides_ok(S12, COUNT(S12), 163, 440, -1, 396);
}

bool test_algo_b_09_duplicate_points(void) {
    return christofides_ok(DUP, COUNT(DUP), 6, 12, 12, -1);
}

bool test_algo_b_10_stress(void) {
    return christofides_ok(S20, COUNT(S20), 211, 608, -1, 540);
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

    printf("\n--- Algorithm A: MST Double Tree ---\n");
    RUN_TEST(test_algo_a_01_empty,                   "Test A01 (Empty)");
    RUN_TEST(test_algo_a_02_single_point,            "Test A02 (Single Point)");
    RUN_TEST(test_algo_a_03_two_points,              "Test A03 (Two Points)");
    RUN_TEST(test_algo_a_04_collinear_unsorted,      "Test A04 (Collinear Unsorted)");
    RUN_TEST(test_algo_a_05_square,                  "Test A05 (Square)");
    RUN_TEST(test_algo_a_06_parent_tie_breaking,     "Test A06 (Parent Tie Breaking)");
    RUN_TEST(test_algo_a_07_grid_ties,               "Test A07 (Grid Ties)");
    RUN_TEST(test_algo_a_08_duplicate_points,        "Test A08 (Duplicate Points)");
    RUN_TEST(test_algo_a_09_clusters_two_approx,     "Test A09 (Clusters Two Approx)");
    RUN_TEST(test_algo_a_10_stress,                  "Test A10 (Stress)");

    printf("\n--- Algorithm B: Christofides ---\n");
    RUN_TEST(test_algo_b_01_empty,                   "Test B01 (Empty)");
    RUN_TEST(test_algo_b_02_two_points_double_edge,  "Test B02 (Two Points Double Edge)");
    RUN_TEST(test_algo_b_03_star_parallel_edges,     "Test B03 (Star Parallel Edges)");
    RUN_TEST(test_algo_b_04_collinear,               "Test B04 (Collinear)");
    RUN_TEST(test_algo_b_05_grid,                    "Test B05 (Grid)");
    RUN_TEST(test_algo_b_06_beats_double_tree,       "Test B06 (Beats Double Tree)");
    RUN_TEST(test_algo_b_07_spiral_bound,            "Test B07 (Spiral Bound)");
    RUN_TEST(test_algo_b_08_greedy_matching_trap,    "Test B08 (Greedy Matching Trap)");
    RUN_TEST(test_algo_b_09_duplicate_points,        "Test B09 (Duplicate Points)");
    RUN_TEST(test_algo_b_10_stress,                  "Test B10 (Stress)");

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
