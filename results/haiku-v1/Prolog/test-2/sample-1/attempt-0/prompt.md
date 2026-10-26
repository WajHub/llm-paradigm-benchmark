You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

- Implement `create_graph(+NumVertices, -Graph)`: Create a directed weighted graph as `graph(NumVertices, [])`.
- Implement `add_edge(+Graph, +From, +To, +Weight, -NewGraph)`: Return new graph with edge added.
- Implement `dijkstra(+Graph, +Source, -Result)`: Run Dijkstra's algorithm. Result is `path_result(Distances, Predecessors, Source)`. Unreachable vertices get `inf`. Unify Result with `none` if Graph is `none` or source out of bounds.
- Implement `get_shortest_distance(+Result, +Target, -Distance)`: Unify Distance. If Result is `none` or target out of bounds, Distance = `inf`.
- Implement `reconstruct_path(+Result, +Target, -Path)`: Unify Path with list of vertex indices, or `none` if unreachable/invalid.
- Use `none` atom for absent/null values.
- Use idiomatic SWI-Prolog.

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

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