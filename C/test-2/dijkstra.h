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
