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
