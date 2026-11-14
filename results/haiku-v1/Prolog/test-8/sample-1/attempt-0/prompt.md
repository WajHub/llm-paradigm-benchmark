You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

Implement two approximation algorithms for the metric Travelling Salesman Problem
(MST double tree and Christofides) in SWI-Prolog in the module tsp_approx (file
tsp_approx.pl). Implement tsp_mst_weight/2, tsp_double_tree/2,
tsp_matching_weight/2 and tsp_christofides/2.

Input: Points is a list of X-Y pairs of integers, e.g. [0-0, 3-4, 1-0]
(|coordinate| < 10000, at most 40 points). Vertices are identified by their
0-based position in the list. Points may coincide (distance 0).
Distance: Manhattan, d(X1-Y1, X2-Y2) = |X1 - X2| + |Y1 - Y2| (an integer).

Tours: a tour result is the term tour(Order, Cost) where Order is a list containing
every vertex index exactly once (a permutation of 0..N-1) and starting with 0, and
Cost is the integer length of the closed tour: the sum of d over consecutive
vertices of Order plus d(last, first). For N = 1 the result is tour([0], 0); for
N = 2 the cost is 2 * d(0, 1). For an empty point list the result is the atom none.

The MST (unique by these rules) is built by Prim's algorithm starting at vertex 0:
repeat N-1 times: among the vertices not yet in the tree choose the vertex V with
the smallest key(V) = min over tree vertices U of d(U, V); ties -> the smallest
index V. Its parent is the tree vertex U with d(U, V) = key(V); ties -> the
SMALLEST index U (not the first one found, not the most recently added one).

- Implement `tsp_mst_weight(+Points, -W)`: W is the total weight of that MST
  (integer); 0 for 0 or 1 points.

- Implement `tsp_double_tree(+Points, -Result)`: Result = tour(Order, Cost) where
  Order is the preorder sequence of a depth-first walk of that MST rooted at 0 that
  visits the children of every vertex in ascending index order. This tour is unique
  and is compared exactly. Result = none for an empty list.

- Implement `tsp_matching_weight(+Points, -W)`: let O be the set of vertices with
  odd degree in that MST (always an even number of vertices). W is the minimum total
  weight (sum of d) of a perfect matching of O (pairs of distinct vertices of O,
  every vertex of O in exactly one pair). It must be exact: greedy nearest-pair
  matching is wrong. |O| <= 16 in all tests, so an exact algorithm over subsets
  (bitmask / memoised DP) is fine; blossom is not required. W = 0 for 0 or 1 points.

- Implement `tsp_christofides(+Points, -Result)`: build the multigraph made of the
  MST edges plus the edges of a minimum-weight perfect matching of O; an edge that
  is in both is a double edge (keep both copies). Find an Eulerian circuit of this
  multigraph starting at vertex 0 (Hierholzer), then shortcut it: keep only the
  first occurrence of every vertex. Result = tour(Order, Cost) with Order starting
  with 0. Result = none for an empty list; tour([0], 0) for one point.
  * Any minimum matching and any Eulerian circuit are accepted. The tests check
    that the tour is valid (permutation starting with 0, Cost equal to the
    recomputed closed-tour cost) and that Cost =< MST weight + matching weight.

Constraints:
  - All predicates are deterministic (a single answer).
  - Results are compared with == / =:=: W and Cost are integers, Order is a proper
    list of integers.

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

:- module(tsp_approx, [
    tsp_mst_weight/2,
    tsp_double_tree/2,
    tsp_matching_weight/2,
    tsp_christofides/2
]).

% Metric TSP approximations on points with Manhattan distance
%   d(X1-Y1, X2-Y2) = |X1 - X2| + |Y1 - Y2|   (integer)
%
% Points: a list of X-Y pairs of integers, e.g. [0-0, 3-4]. Vertex indices are
% 0-based positions in that list. Points may coincide.
%
% Tour result: tour(Order, Cost)
%   Order - list of all vertex indices (a permutation of 0..N-1) starting with 0
%   Cost  - integer length of the closed tour (including the edge back to 0)
% For N = 0 the result is the atom `none`; for N = 1 it is tour([0], 0).
%
% MST: Prim's algorithm from vertex 0; next vertex = smallest key, ties ->
% smallest index; parent = tree vertex at distance key with the smallest index.
%
% tsp_mst_weight(+Points, -W)
%   W = total weight of that MST (0 for 0 or 1 points).
%
% tsp_double_tree(+Points, -Result)
%   Result = tour(Order, Cost): preorder walk of the MST rooted at 0, children
%   visited in ascending index order; `none` for an empty list.
%
% tsp_matching_weight(+Points, -W)
%   W = weight of a minimum-weight perfect matching of the odd-degree vertices
%   of that MST (0 for 0 or 1 points).
%
% tsp_christofides(+Points, -Result)
%   Result = tour(Order, Cost) built by Christofides' algorithm (MST + minimum
%   matching as a multigraph, Eulerian circuit from 0, shortcutting);
%   `none` for an empty list.

tsp_mst_weight(_, _) :-
    throw(error(existence_error(procedure, tsp_mst_weight/2), _)).

tsp_double_tree(_, _) :-
    throw(error(existence_error(procedure, tsp_double_tree/2), _)).

tsp_matching_weight(_, _) :-
    throw(error(existence_error(procedure, tsp_matching_weight/2), _)).

tsp_christofides(_, _) :-
    throw(error(existence_error(procedure, tsp_christofides/2), _)).