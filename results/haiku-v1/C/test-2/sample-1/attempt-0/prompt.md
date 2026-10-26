You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

- Implement `create_graph`: Allocate a directed weighted graph with the given number of vertices (0-indexed). Use adjacency lists internally.
- Implement `graph_add_edge`: Add a directed edge from vertex `from` to vertex `to` with the given non-negative weight. Support multiple edges between the same pair of vertices.
- Implement `dijkstra`: Run Dijkstra's algorithm from the given source vertex. Return a DijkstraResult containing shortest distances to all vertices and predecessor array for path reconstruction. Unreachable vertices must have distance INFINITY (from math.h). Return NULL if graph is NULL or source is out of bounds.
- Implement `get_shortest_distance`: Return the shortest distance from the source to the target vertex. Return INFINITY if target is out of bounds or result is NULL.
- Implement `reconstruct_path`: Reconstruct the shortest path from source to target as a dynamically allocated array of vertex indices. Set *path_length to the number of vertices in the path. Return NULL if target is unreachable, out of bounds, or result is NULL.
- Implement `free_graph`, `free_result`: Safely free all allocated memory, including nested structures.
- Use a priority queue (min-heap) for O((V+E) log V) time complexity.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

#ifndef DIJKSTRA_H
#define DIJKSTRA_H

#include <stdbool.h>

typedef struct {
    int to;
    double weight;
} Edge;

typedef struct {
    Edge* edges;
    int count;
    int capacity;
} AdjList;

typedef struct {
    AdjList* adjacency;
    int num_vertices;
} Graph;

typedef struct {
    double* distances;
    int* predecessors;
    int num_vertices;
    int source;
} DijkstraResult;

Graph* create_graph(int num_vertices);
void graph_add_edge(Graph* graph, int from, int to, double weight);
void free_graph(Graph* graph);

DijkstraResult* dijkstra(const Graph* graph, int source);
double get_shortest_distance(const DijkstraResult* result, int target);
int* reconstruct_path(const DijkstraResult* result, int target, int* path_length);
void free_result(DijkstraResult* result);

#endif