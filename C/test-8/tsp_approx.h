#ifndef TSP_APPROX_H
#define TSP_APPROX_H

/*
 * Metric TSP approximation on points with Manhattan distance
 * d(p, q) = |p.x - q.x| + |p.y - q.y|.
 * Vertices are the indices 0..n-1 of pts in input order. Points may coincide.
 */

typedef struct {
    int x;
    int y;
} TspPoint;

typedef struct {
    int* tour;   /* length n; permutation of 0..n-1 starting with 0; heap */
    int n;
    int cost;    /* closed-tour cost, including the edge back to tour[0] */
} TourResult;

/* Total weight of the MST built by the tie-broken Prim's algorithm; 0 if n <= 1. */
int tsp_mst_weight(const TspPoint* pts, int n);

/* Preorder walk of that MST (root 0, children in ascending index order).
   NULL if n == 0. Caller frees with free_tour_result. */
TourResult* tsp_double_tree(const TspPoint* pts, int n);

/* Minimum-weight perfect matching on the odd-degree vertices of that MST; 0 if n <= 1. */
int tsp_matching_weight(const TspPoint* pts, int n);

/* Christofides tour (MST + min matching, Eulerian circuit from 0, shortcut).
   NULL if n == 0. Caller frees with free_tour_result. */
TourResult* tsp_christofides(const TspPoint* pts, int n);

/* Frees the result and its tour array. Accepts NULL. */
void free_tour_result(TourResult* result);

#endif
