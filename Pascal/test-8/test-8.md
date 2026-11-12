# Test 8

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement two approximation algorithms for the metric Travelling Salesman Problem
(MST double tree and Christofides) in Free Pascal in the unit tsp_approx (file
tsp_approx.pas). The unit already declares the types and the five routines; keep the
interface unchanged and implement TspMstWeight, TspDoubleTree, TspMatchingWeight,
TspChristofides and FreeTourResult in the implementation section.

Input and common definitions:
  * Pts: TTspPointArray; vertex i is Pts[i], i = 0..n-1 in input order. n <= 40,
    |coordinate| < 10000. Points may coincide (distance 0). Do not modify Pts.
  * Distance is Manhattan: d(p, q) = |p.X - q.X| + |p.Y - q.Y| (an integer).
  * A tour is a permutation of all vertex indices 0..n-1 that STARTS WITH 0. It is a
    closed cycle: Cost = sum of d(Tour[i], Tour[i+1]) for i = 0..n-2 plus
    d(Tour[n-1], Tour[0]). For n = 1 the tour is [0] with Cost 0; for n = 2 the
    Cost is 2*d(0,1).
  * TspDoubleTree and TspChristofides return a NEW record (New) whose Tour is a fresh
    dynamic array of length n, or nil when n = 0. The caller frees it with
    FreeTourResult.

The MST (unique by these rules - the tests depend on them):
  Prim's algorithm starting from vertex 0. Repeat n-1 times: among the vertices not yet
  in the tree choose the vertex v with the smallest key(v) = min over tree vertices u of
  d(u, v); ties -> the smallest index v. The parent of v is the tree vertex u with
  d(u, v) = key(v); if several tree vertices are at that distance, the parent is the one
  with the SMALLEST INDEX u (not the first one found, not the most recently added).

- Implement `TspMstWeight(const Pts: TTspPointArray): LongInt`: the total weight of that
  MST; 0 for n = 0 or n = 1.

- Implement `TspDoubleTree(const Pts: TTspPointArray): PTourResult`: the 2-approximation.
  The tour is the preorder DFS sequence of that MST rooted at 0, visiting the children of
  each vertex in ASCENDING index order. The resulting tour is unique and is compared
  exactly; Cost is the closed-tour cost of that tour. nil for n = 0.

- Implement `TspMatchingWeight(const Pts: TTspPointArray): LongInt`: let O be the set of
  vertices with odd degree in that MST (|O| is even). Return the MINIMUM total weight
  (distance d) of a perfect matching of O (pairs of distinct vertices of O, every vertex
  of O in exactly one pair). It must be exact: greedy nearest-pair matching is wrong.
  |O| <= 16 in all tests, so an exact bitmask DP over subsets is fine (no blossom
  needed). Return 0 for n = 0 or n = 1.

- Implement `TspChristofides(const Pts: TTspPointArray): PTourResult`:
  * build the MULTIGRAPH = MST edges + the edges of a minimum-weight perfect matching of O
    (an edge that is in both is a double edge: keep both copies - parallel edges are
    essential for the Euler circuit);
  * find an Eulerian circuit starting at vertex 0 (Hierholzer);
  * shortcut it: keep the first occurrence of every vertex. The tour starts with 0.
  * Cost is the closed-tour cost of the returned tour. By the triangle inequality it is
    <= MST weight + matching weight.
  * n = 0 -> nil; n = 1 -> Tour [0], Cost 0.
  * Any minimum matching and any Eulerian circuit are accepted; the tests check that the
    tour is a valid permutation starting with 0, that Cost equals the recomputed cost,
    and the Christofides bound.

- Implement `FreeTourResult(var R: PTourResult)`: free the record (and its Tour) and set
  R to nil. FreeTourResult(nil) is a no-op.

Pascal notes:
  - Pascal is case-insensitive: do not name variables after the record fields' types or
    after RTL routines (e.g. a variable named Max, Min or Odd shadows the RTL function),
    and do not name anything Result except the function result.
  - All values fit in LongInt.
  - The program is run under valgrind and must not leak memory.
```
