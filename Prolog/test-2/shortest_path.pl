:- module(shortest_path, [
    create_graph/2,
    add_edge/5,
    dijkstra/3,
    get_shortest_distance/3,
    reconstruct_path/3
]).

% Graph representation: graph(NumVertices, Edges)
% where Edges is a list of edge(From, To, Weight)
%
% PathResult representation: path_result(Distances, Predecessors, Source)
% where Distances is a list of NumVertices doubles (index = vertex)
% and Predecessors is a list of NumVertices integers (-1 for no predecessor)

create_graph(_, _) :-
    throw(error(existence_error(procedure, create_graph/2), _)).

add_edge(_, _, _, _, _) :-
    throw(error(existence_error(procedure, add_edge/5), _)).

dijkstra(_, _, _) :-
    throw(error(existence_error(procedure, dijkstra/3), _)).

get_shortest_distance(_, _, _) :-
    throw(error(existence_error(procedure, get_shortest_distance/3), _)).

reconstruct_path(_, _, _) :-
    throw(error(existence_error(procedure, reconstruct_path/3), _)).
