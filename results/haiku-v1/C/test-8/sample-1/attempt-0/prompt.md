You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

Implement two approximation algorithms for the metric Travelling Salesman Problem
(MST double tree and Christofides) in C using the header file tsp_approx.h.

Input: an array `pts` of `n` points (`TspPoint {int x; int y;}`), 0 <= n <= 40,
|coordinate| < 10^4. When n == 0, `pts` may be NULL. Vertex i is pts[i] (0-based,
input order). Points may coincide (distance 0). The input is never modified.
Distance is Manhattan: d(p, q) = |p.x - q.x| + |p.y - q.y| (an integer metric).

Tour: a TourResult whose `tour` is a permutation of all vertex indices 0..n-1
starting with vertex 0, `n` is its length, and `cost` is the closed-tour cost
  d(tour[0], tour[1]) + ... + d(tour[n-2], tour[n-1]) + d(tour[n-1], tour[0]).
For n == 1 the tour is [0] with cost 0; for n == 2 the cost is 2 * d(0, 1).

The MST (unique by these rules) - Prim's algorithm starting from vertex 0:
  repeat n-1 times: among the non-tree vertices v choose the one with the smallest
  key(v) = min over tree vertices u of d(u, v); ties -> the smallest index v.
  Its parent is the tree vertex u with d(u, v) == key(v); ties -> the SMALLEST
  index u (not the first one found, not the most recently added one).
  Add v to the tree with the edge (parent, v).

- Implement `tsp_mst_weight`: Return the sum of the weights of that MST's edges.
  Return 0 for n <= 1.

- Implement `tsp_double_tree`: Return the preorder (DFS) sequence of that MST
  rooted at vertex 0, visiting the children of every vertex in ASCENDING index
  order, together with its closed-tour cost. The answer is unique and compared
  exactly. Return NULL for n == 0; for n == 1 return tour [0], cost 0.

- Implement `tsp_matching_weight`: Let O be the set of vertices with odd degree in
  that MST (|O| is even). Return the MINIMUM total weight (distance d) of a perfect
  matching of O (pairs of distinct vertices of O, every vertex of O in exactly one
  pair). It must be exact - greedy nearest-pair matching is wrong. |O| <= 16 in all
  tests, so an exact bitmask DP over subsets is fine (blossom not required).
  Return 0 for n <= 1.

- Implement `tsp_christofides`: Build the multigraph consisting of the MST edges
  plus the edges of a minimum-weight perfect matching of O. If an edge is both an
  MST edge and a matching edge it is a DOUBLE edge - keep both copies (parallel
  edges). Find an Eulerian circuit of this multigraph starting at vertex 0
  (Hierholzer), then shortcut it: keep only the first occurrence of every vertex.
  The resulting tour starts with 0. Its cost never exceeds
  tsp_mst_weight + tsp_matching_weight. Any minimum matching and any Eulerian
  circuit are accepted. Return NULL for n == 0; for n == 1 return tour [0], cost 0.

- Implement `free_tour_result`: Free the result and its `tour` array.
  `free_tour_result(NULL)` is a no-op.

Ownership: every returned TourResult and its `tour` array are fresh heap
allocations owned by the caller (released with `free_tour_result`).

Constraints:
  - No memory leaks (verified by valgrind); free every temporary allocation.
  - All functions must handle their edge cases (n == 0, 1, 2, coinciding points)
    without crashing.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

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