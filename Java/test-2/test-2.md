# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `createGraph`: Create a directed weighted graph with the given number of vertices (0-indexed).
- Implement `addEdge`: Add a directed edge from vertex `from` to vertex `to` with the given non-negative weight. Support multiple edges between the same pair.
- Implement `dijkstra`: Run Dijkstra's algorithm from the given source vertex. Return a PathResult with shortest distances and predecessor array. Unreachable vertices must have distance Double.POSITIVE_INFINITY. Return null if graph is null or source out of bounds.
- Implement `getShortestDistance`: Return shortest distance to target. Return Double.POSITIVE_INFINITY if target out of bounds or result is null.
- Implement `reconstructPath`: Return int[] of vertex indices from source to target. Return null if unreachable, out of bounds, or result is null.
- Use a priority queue for O((V+E) log V) time complexity.
- Keep the contract in `ShortestPath.java`, the concrete solution in `ShortestPathImpl.java`.
- Return only raw Java code.
```
