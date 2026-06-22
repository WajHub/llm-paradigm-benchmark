# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `createGraph`: Create a directed weighted graph with the given number of vertices (0-indexed). Return a Graph with empty adjacency lists.
- Implement `addEdge`: Return a new Graph with the directed edge added. Support multiple edges between same vertices.
- Implement `dijkstra`: Run Dijkstra's algorithm. Takes Maybe Graph and source Int. Return Nothing if graph is Nothing or source out of bounds. Unreachable vertices must have distance Infinity (1/0).
- Implement `getShortestDistance`: Takes Maybe PathResult and target. Return Infinity if Nothing or out of bounds.
- Implement `reconstructPath`: Return Maybe [Int] — Just path or Nothing if unreachable/invalid.
- Use a priority queue or efficient data structure.
- Use idiomatic Haskell (immutable data, pure functions where possible).
```
