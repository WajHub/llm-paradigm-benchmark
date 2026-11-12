# Test 8

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement two approximation algorithms for the metric Travelling Salesman Problem (MST
double tree and Christofides) in GNU Smalltalk in the class TspApproxImpl (file
TspApproxImpl.st), which subclasses the abstract class TspApprox. The result class
TspTourResult (class-side constructor `TspTourResult tour: anArray cost: anInteger`,
accessors tour and cost) is already defined. Implement mstWeight:, doubleTree:,
matchingWeight: and christofides:. Put the solution in TspApproxImpl.st.

Input and conventions:
  * points is an Array of 2-element Arrays #(x y) of Integers, e.g. #(#(0 0) #(3 4)).
    0 <= points size <= 40. Points may coincide (distance 0).
  * Vertices are numbered 1..n (1-BASED): vertex i is `points at: i`.
  * Distance is Manhattan: d(p, q) = |px - qx| + |py - qy| (an Integer).
  * A tour is an Array (any SequenceableCollection is accepted) containing every vertex
    number 1..n exactly once and STARTING WITH 1. It is a closed cycle; its cost is
    the sum of d(tour at: i, tour at: i + 1) for i = 1..n-1 plus d(tour at: n, tour at: 1).
    For n = 1 the tour is #(1) with cost 0; for n = 2 the cost is 2 * d(1, 2).
  * The cost stored in TspTourResult must equal the cost of its tour (Integer).

The MST (unique by these rules) - Prim's algorithm started from vertex 1:
  repeat n-1 times: among the vertices v not yet in the tree choose the one with the
  smallest key(v) = min over tree vertices u of d(u, v); ties -> the SMALLEST vertex
  number v. Its parent is the tree vertex u with d(u, v) = key(v); ties -> the SMALLEST
  vertex number u (not the first one found, not the most recently added).

- Implement `mstWeight: points`: the sum of the MST edge weights. Answer 0 for 0 or 1
  points.

- Implement `doubleTree: points`: answer nil for an empty Array. Otherwise answer a
  TspTourResult whose tour is the PREORDER of the MST rooted at vertex 1, visiting the
  children of every vertex in ASCENDING vertex-number order (a vertex is listed before
  its children). The tour is unique and is compared exactly.

- Implement `matchingWeight: points`: let O be the vertices of odd degree in that MST
  (always an even number of them). Answer the MINIMUM total weight (distance d) of a
  perfect matching of O (pairs of distinct vertices of O, every vertex of O in exactly
  one pair). It must be exact - greedy nearest-pair matching is wrong. At most 16 odd
  vertices occur, so an exact bitmask DP over subsets is fine (no blossom needed).
  Answer 0 for 0 or 1 points.

- Implement `christofides: points`: answer nil for an empty Array; for one point the
  tour #(1) with cost 0. Otherwise:
    1. build the multigraph = the MST edges + the edges of a minimum-weight perfect
       matching of O. An edge present in both is a DOUBLE edge - keep both copies
       (parallel edges must be traversed separately);
    2. find an Eulerian circuit of that multigraph starting at vertex 1 (Hierholzer);
    3. shortcut it: keep only the first occurrence of every vertex.
  The tour must start with 1. Any minimum matching and any Eulerian circuit are
  accepted; the tests check that the tour is valid, that cost equals the cost of the
  tour, that cost <= mstWeight + matchingWeight and the 1.5-approximation bound.

Constraints:
  - Integer arithmetic only; do not modify the input Array.
```
