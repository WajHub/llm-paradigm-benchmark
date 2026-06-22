# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `createGraph: numVertices`: Create a DijkstraGraph with given vertices (0-indexed internally, but Smalltalk arrays are 1-indexed — handle the mapping).
- Implement `addEdge: graph from: from to: to weight: weight`: Add a directed edge. Mutate the graph's adjacency list.
- Implement `dijkstra: graph source: source`: Run Dijkstra's algorithm. Return a DijkstraResult with distances and predecessors arrays. Unreachable vertices get Float infinity. Return nil if graph is nil or source out of bounds.
- Implement `getShortestDistance: result target: target`: Return distance. Return Float infinity if nil or out of bounds.
- Implement `reconstructPath: result target: target`: Return an OrderedCollection of vertex indices (0-based) from source to target. Return nil if unreachable.
- Use the built-in Edge, DijkstraGraph, DijkstraResult classes defined in ShortestPath.st.
- Use idiomatic GNU Smalltalk.
```
