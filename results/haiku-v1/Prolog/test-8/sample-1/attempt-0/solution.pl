:- module(tsp_approx, [
    tsp_mst_weight/2,
    tsp_double_tree/2,
    tsp_matching_weight/2,
    tsp_christofides/2
]).

:- use_module(library(assoc)).

% Metric TSP approximations on points with Manhattan distance.

dist(Pts, A, B, D) :-
    nth0(A, Pts, X1-Y1),
    nth0(B, Pts, X2-Y2),
    D is abs(X1 - X2) + abs(Y1 - Y2).

% ---------------------------------------------------------------------
% Prim's MST from vertex 0.
% Edges are edge(Parent, Child, Weight).

mst([], [], 0).
mst([_], [], 0).
mst(Pts, Edges, Total) :-
    Pts = [_, _ | _],
    length(Pts, N),
    N1 is N - 1,
    numlist(1, N1, Vs),
    maplist(init_front(Pts), Vs, Frontier),
    prim(Frontier, Pts, [], Edges, 0, Total).

init_front(Pts, V, V-K-0) :-
    dist(Pts, 0, V, K).

prim([], _, E, E, T, T).
prim(F, Pts, E0, E, T0, T) :-
    F = [X | Xs],
    pick_min(Xs, X, V-K-P),
    selectchk(V-K-P, F, Rest),
    maplist(upd_front(Pts, V), Rest, Rest1),
    T1 is T0 + K,
    prim(Rest1, Pts, [edge(P, V, K) | E0], E, T1, T).

pick_min([], M, M).
pick_min([V-K-P | T], V0-K0-P0, M) :-
    (   K < K0
    ->  pick_min(T, V-K-P, M)
    ;   pick_min(T, V0-K0-P0, M)
    ).

upd_front(Pts, V, W-K2-P2, W-K-P) :-
    dist(Pts, V, W, D),
    (   D < K2
    ->  K = D, P = V
    ;   D =:= K2, V < P2
    ->  K = K2, P = V
    ;   K = K2, P = P2
    ).

% ---------------------------------------------------------------------
% Tree utilities

neighbor(V, Es, U) :-
    (   member(edge(V, U, _), Es)
    ;   member(edge(U, V, _), Es)
    ).

children(V, P, Es, Cs) :-
    findall(U, neighbor(V, Es, U), Ns),
    exclude(==(P), Ns, Ms),
    sort(Ms, Cs).

% Preorder depth-first walk with children in ascending order.
pre(V, P, Es, [V | L1], L) :-
    children(V, P, Es, Cs),
    pre_children(Cs, V, Es, L1, L).

pre_children([], _, _, L, L).
pre_children([C | Cs], V, Es, L0, L) :-
    pre(C, V, Es, L0, L1),
    pre_children(Cs, V, Es, L1, L).

% ---------------------------------------------------------------------
% Tour cost of a closed tour given by Order.

tour_cost(Order, Pts, C) :-
    Order = [F | _],
    append(Order, [F], Cyc),
    sum_edges(Cyc, Pts, C).

sum_edges([_], _, 0) :- !.
sum_edges([A, B | T], Pts, C) :-
    dist(Pts, A, B, D),
    sum_edges([B | T], Pts, C1),
    C is C1 + D.

% ---------------------------------------------------------------------
% Odd-degree vertices of the MST.

odd_vertices(Pts, Es, Os) :-
    length(Pts, N),
    N1 is N - 1,
    findall(V,
            ( between(0, N1, V),
              aggregate_all(count,
                            ( member(edge(A, B, _), Es),
                              ( A =:= V ; B =:= V )
                            ), D),
              D mod 2 =:= 1
            ),
            Os).

% ---------------------------------------------------------------------
% Exact minimum-weight perfect matching by memoised bitmask DP.
% Memo maps Mask (over indices into Os) to Cost-Pairs.

bits_of(0, _, []) :- !.
bits_of(M, I, Bs) :-
    M1 is M >> 1,
    I1 is I + 1,
    bits_of(M1, I1, T),
    (   M /\ 1 =:= 1
    ->  Bs = [I | T]
    ;   Bs = T
    ).

min_match(0, _, _, M, M, 0-[]) :- !.
min_match(Mask, _, _, M0, M0, Best) :-
    get_assoc(Mask, M0, Best),
    !.
min_match(Mask, Os, Pts, M0, M, Best) :-
    bits_of(Mask, 0, [I | Js]),
    nth0(I, Os, VI),
    Mask1 is Mask /\ \(1 << I),
    best_pair(Js, Mask1, Os, Pts, VI, M0, M1, none, Best),
    put_assoc(Mask, M1, Best, M).

best_pair([], _, _, _, _, M, M, B, B).
best_pair([J | Js], Mask1, Os, Pts, VI, M0, M, B0, B) :-
    Mask2 is Mask1 /\ \(1 << J),
    min_match(Mask2, Os, Pts, M0, M1, C1-Ps1),
    nth0(J, Os, VJ),
    dist(Pts, VI, VJ, D),
    C is D + C1,
    P = [VI-VJ | Ps1],
    (   B0 == none
    ->  B1 = C-P
    ;   B0 = BC-_, C < BC
    ->  B1 = C-P
    ;   B1 = B0
    ),
    best_pair(Js, Mask1, Os, Pts, VI, M1, M, B1, B).

matching(Pts, Os, Best) :-
    empty_assoc(E),
    length(Os, K),
    Full is (1 << K) - 1,
    min_match(Full, Os, Pts, E, _, Best).

% ---------------------------------------------------------------------
% Eulerian circuit (Hierholzer) on a multigraph given as A-B pairs.

take_edge(V, [A-B | T], U, Rest) :-
    (   A =:= V
    ->  U = B, Rest = T
    ;   B =:= V
    ->  U = A, Rest = T
    ;   Rest = [A-B | R],
        take_edge(V, T, U, R)
    ).

hier([], _, C, C).
hier([V | S], Es, C0, C) :-
    (   take_edge(V, Es, U, Es1)
    ->  hier([U, V | S], Es1, C0, C)
    ;   hier(S, Es, [V | C0], C)
    ).

% Keep first occurrence of each vertex.
shortcut([], _, []).
shortcut([V | T], Seen, Out) :-
    (   memberchk(V, Seen)
    ->  Out = R, Seen1 = Seen
    ;   Out = [V | R], Seen1 = [V | Seen]
    ),
    shortcut(T, Seen1, R).

% ---------------------------------------------------------------------
% Public predicates

tsp_mst_weight(Points, W) :-
    mst(Points, _, W).

tsp_double_tree(Points, Result) :-
    (   Points == []
    ->  Result = none
    ;   mst(Points, Es, _),
        pre(0, -1, Es, Order, []),
        tour_cost(Order, Points, C),
        Result = tour(Order, C)
    ).

tsp_matching_weight(Points, W) :-
    mst(Points, Es, _),
    odd_vertices(Points, Es, Os),
    matching(Points, Os, W-_).

tsp_christofides(Points, Result) :-
    (   Points == []
    ->  Result = none
    ;   mst(Points, Es, _),
        odd_vertices(Points, Es, Os),
        matching(Points, Os, _-Pairs),
        findall(A-B, member(edge(A, B, _), Es), E1),
        append(E1, Pairs, Multi),
        hier([0], Multi, [], Circ),
        shortcut(Circ, [], Order),
        tour_cost(Order, Points, C),
        Result = tour(Order, C)
    ).
