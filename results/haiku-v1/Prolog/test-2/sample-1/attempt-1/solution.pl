:- module(shortest_path, [
    create_graph/2,
    add_edge/5,
    dijkstra/3,
    get_shortest_distance/3,
    reconstruct_path/3
]).

:- use_module(library(assoc)).
:- use_module(library(heaps)).
:- use_module(library(lists)).

% Graph representation: graph(NumVertices, Edges)
% where Edges is a list of edge(From, To, Weight)
%
% PathResult representation: path_result(Distances, Predecessors, Source)
% where Distances is a list of NumVertices numbers or inf (index = vertex)
% and Predecessors is a list of NumVertices integers (-1 for no predecessor)

create_graph(N, graph(N, [])) :-
    integer(N),
    N >= 0.

add_edge(graph(N, Edges), From, To, Weight, graph(N, [edge(From, To, Weight)|Edges])) :-
    integer(From), integer(To),
    From >= 0, From < N,
    To >= 0, To < N,
    number(Weight).

dijkstra(graph(N, Edges), Source, path_result(Dists, Preds, Source)) :-
    integer(N), N > 0,
    is_list(Edges),
    integer(Source), Source >= 0, Source < N,
    !,
    N1 is N - 1,
    numlist(0, N1, Vs),
    init_dist_pred(Vs, Source, Dist0, Pred0),
    build_adjacency(Edges, empty_assoc_adj, Adj),
    empty_heap(H0),
    add_to_heap(H0, 0, Source, H1),
    run_dijkstra(H1, Adj, Dist0, Pred0, DistF, PredF),
    assoc_to_values(DistF, Dists),
    assoc_to_values(PredF, Preds).
dijkstra(_, _, none).

init_dist_pred(Vs, Source, Dist, Pred) :-
    findall(V-D,
            (member(V, Vs), ( V =:= Source -> D = 0 ; D = inf )),
            DPs),
    list_to_assoc(DPs, Dist),
    findall(V-(-1), member(V, Vs), PPs),
    list_to_assoc(PPs, Pred).

empty_assoc_adj(Adj) :-
    empty_assoc(Adj).

build_adjacency(Edges, _, Adj) :-
    empty_assoc(A0),
    foldl(add_adj, Edges, A0, Adj).

add_adj(edge(F, T, W), A0, A1) :-
    (   get_assoc(F, A0, L)
    ->  put_assoc(F, A0, [T-W|L], A1)
    ;   put_assoc(F, A0, [T-W], A1)
    ).

run_dijkstra(Heap, Adj, Dist0, Pred0, Dist, Pred) :-
    (   get_from_heap(Heap, D, U, Heap1)
    ->  get_assoc(U, Dist0, CurD),
        (   D > CurD
        ->  run_dijkstra(Heap1, Adj, Dist0, Pred0, Dist, Pred)
        ;   (   get_assoc(U, Adj, Ns) -> true ; Ns = [] ),
            foldl(relax(U, D), Ns, Heap1-Dist0-Pred0, Heap2-Dist1-Pred1),
            run_dijkstra(Heap2, Adj, Dist1, Pred1, Dist, Pred)
        )
    ;   Dist = Dist0,
        Pred = Pred0
    ).

relax(U, D, T-W, H0-Di-Pi, H-Do-Po) :-
    NewD is D + W,
    get_assoc(T, Di, Old),
    (   ( Old == inf ; NewD < Old )
    ->  put_assoc(T, Di, NewD, Do),
        put_assoc(T, Pi, U, Po),
        add_to_heap(H0, NewD, T, H)
    ;   Do = Di, Po = Pi, H = H0
    ).

get_shortest_distance(Result, Target, Distance) :-
    (   Result = path_result(Dists, _, _),
        integer(Target),
        nth0(Target, Dists, D)
    ->  Distance = D
    ;   Distance = inf
    ).

reconstruct_path(Result, Target, Path) :-
    (   Result = path_result(Dists, Preds, _),
        integer(Target),
        nth0(Target, Dists, D),
        number(D)
    ->  walk_back(Target, Preds, [], Path)
    ;   Path = none
    ).

walk_back(V, Preds, Acc, Path) :-
    nth0(V, Preds, P),
    (   P =:= -1
    ->  Path = [V|Acc]
    ;   walk_back(P, Preds, [V|Acc], Path)
    ).
