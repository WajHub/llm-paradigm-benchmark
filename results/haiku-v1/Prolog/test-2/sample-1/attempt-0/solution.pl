:- module(shortest_path, [
    create_graph/2,
    add_edge/5,
    dijkstra/3,
    get_shortest_distance/3,
    reconstruct_path/3
]).

:- use_module(library(assoc)).
:- use_module(library(lists)).
:- use_module(library(pairs)).

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
    init_state(Vs, Source, Dist0, Pred0),
    run_dijkstra(Edges, Vs, [], Dist0, Pred0, DistF, PredF),
    assoc_to_values(DistF, Dists),
    assoc_to_values(PredF, Preds).
dijkstra(_, _, none).

init_state(Vs, Source, Dist, Pred) :-
    findall(V-D,
            (member(V, Vs), ( V =:= Source -> D = 0 ; D = inf )),
            DPs),
    list_to_assoc(DPs, Dist),
    findall(V-(-1), member(V, Vs), PPs),
    list_to_assoc(PPs, Pred).

run_dijkstra(Edges, Vs, Visited, Dist0, Pred0, Dist, Pred) :-
    findall(D-V,
            ( member(V, Vs),
              \+ memberchk(V, Visited),
              get_assoc(V, Dist0, D),
              number(D)
            ),
            Cands),
    (   Cands == []
    ->  Dist = Dist0, Pred = Pred0
    ;   keysort(Cands, [D-U|_]),
        foldl(relax_edge(U, D), Edges, Dist0-Pred0, Dist1-Pred1),
        run_dijkstra(Edges, Vs, [U|Visited], Dist1, Pred1, Dist, Pred)
    ).

relax_edge(U, D, edge(F, V, W), DIn-PIn, DOut-POut) :-
    (   F =:= U
    ->  NewD is D + W,
        get_assoc(V, DIn, Old),
        (   ( Old == inf ; NewD < Old )
        ->  put_assoc(V, DIn, NewD, DOut),
            put_assoc(V, PIn, U, POut)
        ;   DOut = DIn, POut = PIn
        )
    ;   DOut = DIn, POut = PIn
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
