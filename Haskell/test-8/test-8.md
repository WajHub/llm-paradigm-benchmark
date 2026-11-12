# Test 8

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement approximation algorithms for the metric Travelling Salesman Problem
in Haskell in the module TspApprox (file TspApprox.hs): the MST double-tree
2-approximation and Christofides' 1.5-approximation. The module already
defines TourResult { tourOrder :: [Int], tourCost :: Int }; implement
mstWeight, doubleTree, matchingWeight and christofides.

Input: a list of points `[(Int, Int)]` (x, y). Vertex i is the i-th point of
the list (0-based, input order). Points may coincide (distance 0).
|coordinate| < 10^4 and there are at most 40 points.

Distance: Manhattan, d(p, q) = |px - qx| + |py - qy| (an integer metric).

Tour: a TourResult whose tourOrder is a permutation of all vertex indices
0..n-1 that starts with vertex 0. It is a closed cycle; tourCost is
  d(t0, t1) + d(t1, t2) + ... + d(t(n-2), t(n-1)) + d(t(n-1), t0).
  * n == 0: no tour (Nothing).
  * n == 1: TourResult [0] 0.
  * n == 2: tourCost = 2 * d(0, 1).

The MST (unique by the following rules) -- Prim's algorithm from vertex 0:
  * The tree starts as {0}. Repeat n-1 times: for every non-tree vertex v let
    key(v) = minimum of d(u, v) over all tree vertices u. Add the non-tree
    vertex v with the smallest key; ties -> the smallest index v.
  * The parent of the added v is the tree vertex u with d(u, v) == key(v);
    ties -> the SMALLEST index u (not the first one found, not the most
    recently added one).
  * MST edges are the (parent(v), v) pairs.

- Implement `mstWeight :: [(Int, Int)] -> Int`: the total weight of that MST
  (sum of d(parent(v), v)). 0 for 0 or 1 points.

- Implement `doubleTree :: [(Int, Int)] -> Maybe TourResult`: Nothing for an
  empty input; otherwise the tour is the preorder sequence of a depth-first
  traversal of that MST rooted at 0, visiting the children of every vertex in
  ASCENDING index order; tourCost is the closed-tour cost of that order. The
  tests compare this tour exactly.

- Implement `matchingWeight :: [(Int, Int)] -> Int`: let O be the set of
  vertices with odd degree in that MST (|O| is always even). Return the
  MINIMUM total weight (distance d) of a perfect matching of O (O split into
  pairs of distinct vertices, each vertex of O in exactly one pair). It must be
  exact: greedy nearest-pair matching is wrong. |O| <= 16 in all tests, so an
  exact exponential algorithm over subsets (bitmask DP) is acceptable; blossom
  is not required. 0 for 0 or 1 points.

- Implement `christofides :: [(Int, Int)] -> Maybe TourResult`: Nothing for an
  empty input; TourResult [0] 0 for one point. Otherwise:
  1. Build the multigraph = all MST edges + the edges of a minimum-weight
     perfect matching of O. An edge present in both is a DOUBLE edge: keep
     both copies (parallel edges, e.g. for 2 points the graph has two edges
     0-1).
  2. Find an Eulerian circuit of that multigraph starting at vertex 0
     (Hierholzer's algorithm); every edge copy is used exactly once.
  3. Shortcut: keep only the first occurrence of every vertex in the circuit.
     The tour starts with 0; tourCost is its closed-tour cost.
  Any minimum matching and any Eulerian circuit are accepted. The tests check
  that the tour is valid (a permutation of 0..n-1 starting with 0), that
  tourCost equals the cost recomputed from the points, and that
  tourCost <= mstWeight + matchingWeight (guaranteed by the triangle
  inequality), as well as the 3/2 approximation bound.

Constraints:
  - Pure Haskell; only the libraries shipped with GHC (base, containers,
    array).
```
