# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `create_graph(+NumVertices, -Graph)`: Create a directed weighted graph as `graph(NumVertices, [])`.
- Implement `add_edge(+Graph, +From, +To, +Weight, -NewGraph)`: Return new graph with edge added.
- Implement `dijkstra(+Graph, +Source, -Result)`: Run Dijkstra's algorithm. Result is `path_result(Distances, Predecessors, Source)`. Unreachable vertices get `inf`. Unify Result with `none` if Graph is `none` or source out of bounds.
- Implement `get_shortest_distance(+Result, +Target, -Distance)`: Unify Distance. If Result is `none` or target out of bounds, Distance = `inf`.
- Implement `reconstruct_path(+Result, +Target, -Path)`: Unify Path with list of vertex indices, or `none` if unreachable/invalid.
- Use `none` atom for absent/null values.
- Use idiomatic SWI-Prolog.
```
