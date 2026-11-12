# Test 8

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement two approximation algorithms for the metric Travelling Salesman Problem in Java
in the class TspApproxImpl (file TspApproxImpl.java), which extends the abstract class
TspApprox: the MST double-tree 2-approximation and Christofides' 1.5-approximation.
The base class already defines the result type TspApprox.TourResult; implement
mstWeight, doubleTree, matchingWeight and christofides.

Input: int[][] points, where points[i] = {x, y} (integer coordinates, |coord| < 10^4,
at most 40 points). Vertex i is the point points[i]; vertices are numbered 0..n-1 in
input order. Points may coincide (distance 0). The input array must not be modified.
Distance is the Manhattan distance d(p, q) = |p.x - q.x| + |p.y - q.y| (an integer).

Tours: a tour is an int[] containing every vertex index exactly once and starting with
vertex 0. It is a closed cycle; its cost is d(tour[0], tour[1]) + ... +
d(tour[n-2], tour[n-1]) + d(tour[n-1], tour[0]). For n = 1 the tour is [0] with cost 0;
for n = 2 the tour is [0, 1] with cost 2 * d(0, 1).
TourResult(tour, cost): tour as described, cost = the cost of exactly that tour.

The MST (unique by these rules) - Prim's algorithm started from vertex 0:
  * Repeat n-1 times: among the vertices v not yet in the tree, choose the one with the
    smallest key(v) = min over tree vertices u of d(u, v); ties -> the smallest index v.
  * The parent of v is the tree vertex u with d(u, v) = key(v); if several tree vertices
    are at that distance, the parent is the one with the SMALLEST INDEX (not the first
    one found, not the most recently added).
  * The MST edges are the n-1 pairs (parent(v), v).

- Implement `int mstWeight(int[][] points)`: the total weight of that MST.
  Return 0 for 0 or 1 points.

- Implement `TourResult doubleTree(int[][] points)`: the tour is the preorder sequence of
  a depth-first traversal of that MST rooted at vertex 0, visiting the children of every
  vertex in ASCENDING index order. The tour is unique and is compared exactly.
  Return null for 0 points.

- Implement `int matchingWeight(int[][] points)`: let O be the set of vertices that have
  odd degree in that MST (|O| is always even). Return the MINIMUM total weight (distance d)
  of a perfect matching of O (O partitioned into pairs of distinct vertices). The result
  must be exact - greedy nearest-pair matching is wrong. |O| <= 16 in all inputs, so an
  exact bitmask DP over subsets is fine (a blossom algorithm is not required).
  Return 0 for 0 or 1 points.

- Implement `TourResult christofides(int[][] points)`:
  1. Build a MULTIGRAPH from the MST edges plus the edges of a minimum-weight perfect
     matching of O. If an edge is present in both, keep BOTH copies (parallel edges).
  2. Find an Eulerian circuit of that multigraph starting at vertex 0 (e.g. Hierholzer),
     using every edge copy exactly once.
  3. Shortcut: keep only the first occurrence of each vertex in the circuit; the result
     is the tour (it starts with 0).
  Return null for 0 points; n = 1 gives tour [0], cost 0.
  Any minimum matching and any Eulerian circuit are accepted. By the triangle inequality
  the cost never exceeds mstWeight + matchingWeight.

Keep the contract in TspApprox.java; put the solution in TspApproxImpl.java.
```
