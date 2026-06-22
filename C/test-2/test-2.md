# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
- Implement `create_graph`: Allocate a directed weighted graph with the given number of vertices (0-indexed). Use adjacency lists internally.
- Implement `graph_add_edge`: Add a directed edge from vertex `from` to vertex `to` with the given non-negative weight. Support multiple edges between the same pair of vertices.
- Implement `dijkstra`: Run Dijkstra's algorithm from the given source vertex. Return a DijkstraResult containing shortest distances to all vertices and predecessor array for path reconstruction. Unreachable vertices must have distance INFINITY (from math.h). Return NULL if graph is NULL or source is out of bounds.
- Implement `get_shortest_distance`: Return the shortest distance from the source to the target vertex. Return INFINITY if target is out of bounds or result is NULL.
- Implement `reconstruct_path`: Reconstruct the shortest path from source to target as a dynamically allocated array of vertex indices. Set *path_length to the number of vertices in the path. Return NULL if target is unreachable, out of bounds, or result is NULL.
- Implement `free_graph`, `free_result`: Safely free all allocated memory, including nested structures.
- Use a priority queue (min-heap) for O((V+E) log V) time complexity.
```
