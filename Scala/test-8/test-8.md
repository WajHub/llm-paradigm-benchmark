# Test 8

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement two approximation algorithms for the metric Travelling Salesman
Problem in Scala 2.11 in the object TspApprox (file TspApprox.scala): the MST
double-tree 2-approximation and Christofides' 1.5-approximation. The object
already defines TourResult(tour: Vector[Int], cost: Int); implement mstWeight,
doubleTree, matchingWeight and christofides.

Input and common definitions:
  * points: Vector[(Int, Int)] of (x, y) integer coordinates, n = points.length,
    0 <= n <= 40, |coordinate| < 10000. Points may coincide (distance 0).
  * Vertex i is points(i); vertices are numbered 0..n-1 in input order.
  * Distance is the Manhattan distance d(p, q) = |px - qx| + |py - qy| (Int).
  * A tour is a Vector[Int] that is a permutation of 0..n-1 and STARTS WITH 0.
    It is a closed cycle: its cost is the sum of d(tour(i), tour(i+1)) for
    i = 0..n-2 plus d(tour(n-1), tour(0)).
    n = 1: tour Vector(0), cost 0. n = 2: cost = 2 * d(0, 1).
  * TourResult.cost must equal the cost of TourResult.tour by this definition.
  * The input must not be modified.

The MST (unique by these rules) - Prim's algorithm started at vertex 0:
  Repeat n-1 times: among the vertices v not yet in the tree, choose the one
  with the smallest key(v) = min over tree vertices u of d(u, v); on ties choose
  the SMALLEST index v. Its parent is the tree vertex u with d(u, v) = key(v);
  if several tree vertices are at that distance, the parent is the one with the
  SMALLEST index u (not the first one reached, not the most recently added).
  The MST edges are (v, parent(v)) for every v != 0.

- Implement `mstWeight(points): Int`: the sum of the MST edge weights.
  Return 0 for n = 0 or n = 1.

- Implement `doubleTree(points): Option[TourResult]`:
  * None for n = 0.
  * Otherwise the tour is the preorder DFS sequence of the MST above, rooted at
    vertex 0, where the children of every vertex are visited in ASCENDING index
    order. The tour is unique and the tests compare it exactly.

- Implement `matchingWeight(points): Int`:
  * Let O be the set of vertices with odd degree in the MST above (|O| is
    always even; |O| <= 16 in all tests).
  * Return the MINIMUM total weight (distance d) of a perfect matching of O:
    pairs of distinct vertices of O, every vertex of O in exactly one pair.
    The result must be exact; greedy nearest-pair matching is wrong. An exact
    exponential algorithm over subsets (bitmask DP) is fine; blossom is not
    required.
  * Return 0 for n = 0 or n = 1.

- Implement `christofides(points): Option[TourResult]`:
  * None for n = 0; n = 1 gives TourResult(Vector(0), 0).
  * Build a multigraph from the MST edges plus the edges of a minimum-weight
    perfect matching of O. An edge present in both is a DOUBLE edge: keep both
    copies (parallel edges).
  * Find an Eulerian circuit of that multigraph starting at vertex 0
    (Hierholzer's algorithm; every edge copy is used exactly once).
  * Shortcut: walk the circuit and keep only the first occurrence of every
    vertex. The resulting tour starts with 0.
  * Any minimum matching and any Eulerian circuit are accepted. The tests check
    that the tour is valid (permutation of 0..n-1 starting with 0), that cost
    equals the recomputed tour cost, and that
    cost <= mstWeight(points) + matchingWeight(points)
    (guaranteed by the triangle inequality), plus the 1.5 * OPT bound.

Notes:
  - All sums fit in Int.
  - Use Scala 2.11 syntax and standard library only (no Scala 3 syntax, no
    2.12/2.13-only APIs such as LazyList or .to(List)).
```
