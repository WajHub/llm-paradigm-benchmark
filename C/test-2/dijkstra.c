#include "dijkstra.h"
#include <stdlib.h>

Graph* create_graph(int num_vertices) {
    (void)num_vertices;
    return NULL;
}

void graph_add_edge(Graph* graph, int from, int to, double weight) {
    (void)graph; (void)from; (void)to; (void)weight;
}

void free_graph(Graph* graph) {
    (void)graph;
}

DijkstraResult* dijkstra(const Graph* graph, int source) {
    (void)graph; (void)source;
    return NULL;
}

double get_shortest_distance(const DijkstraResult* result, int target) {
    (void)result; (void)target;
    return -1.0;
}

int* reconstruct_path(const DijkstraResult* result, int target, int* path_length) {
    (void)result; (void)target;
    if (path_length) *path_length = 0;
    return NULL;
}

void free_result(DijkstraResult* result) {
    (void)result;
}
