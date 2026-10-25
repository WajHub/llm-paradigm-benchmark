#include "dijkstra.h"
#include <stdlib.h>
#include <math.h>

typedef struct {
    double dist;
    int vertex;
} HeapItem;

typedef struct {
    HeapItem* items;
    int size;
    int capacity;
} MinHeap;

static int heap_init(MinHeap* h, int capacity) {
    if (capacity < 1) capacity = 1;
    h->items = (HeapItem*)malloc(sizeof(HeapItem) * (size_t)capacity);
    h->size = 0;
    h->capacity = capacity;
    return h->items != NULL;
}

static void heap_free(MinHeap* h) {
    free(h->items);
    h->items = NULL;
    h->size = 0;
    h->capacity = 0;
}

static void heap_push(MinHeap* h, double dist, int vertex) {
    int i;
    if (h->size >= h->capacity) {
        return; /* capacity is sized to be sufficient; defensive guard */
    }
    i = h->size++;
    h->items[i].dist = dist;
    h->items[i].vertex = vertex;
    while (i > 0) {
        int parent = (i - 1) / 2;
        if (h->items[parent].dist <= h->items[i].dist) break;
        HeapItem tmp = h->items[parent];
        h->items[parent] = h->items[i];
        h->items[i] = tmp;
        i = parent;
    }
}

static HeapItem heap_pop(MinHeap* h) {
    HeapItem top = h->items[0];
    int i = 0;
    h->size--;
    if (h->size > 0) {
        h->items[0] = h->items[h->size];
        for (;;) {
            int l = 2 * i + 1;
            int r = 2 * i + 2;
            int smallest = i;
            if (l < h->size && h->items[l].dist < h->items[smallest].dist) smallest = l;
            if (r < h->size && h->items[r].dist < h->items[smallest].dist) smallest = r;
            if (smallest == i) break;
            HeapItem tmp = h->items[smallest];
            h->items[smallest] = h->items[i];
            h->items[i] = tmp;
            i = smallest;
        }
    }
    return top;
}

Graph* create_graph(int num_vertices) {
    Graph* graph;
    int i;

    if (num_vertices < 0) return NULL;

    graph = (Graph*)malloc(sizeof(Graph));
    if (!graph) return NULL;

    graph->num_vertices = num_vertices;
    graph->adjacency = (AdjList*)calloc(num_vertices > 0 ? (size_t)num_vertices : 1, sizeof(AdjList));
    if (!graph->adjacency) {
        free(graph);
        return NULL;
    }

    for (i = 0; i < num_vertices; i++) {
        graph->adjacency[i].edges = NULL;
        graph->adjacency[i].count = 0;
        graph->adjacency[i].capacity = 0;
    }

    return graph;
}

void graph_add_edge(Graph* graph, int from, int to, double weight) {
    AdjList* list;

    if (!graph || !graph->adjacency) return;
    if (from < 0 || from >= graph->num_vertices) return;
    if (to < 0 || to >= graph->num_vertices) return;
    if (!(weight >= 0.0)) return; /* rejects negative and NaN */

    list = &graph->adjacency[from];
    if (list->count >= list->capacity) {
        int new_cap = list->capacity == 0 ? 4 : list->capacity * 2;
        Edge* new_edges = (Edge*)realloc(list->edges, sizeof(Edge) * (size_t)new_cap);
        if (!new_edges) return;
        list->edges = new_edges;
        list->capacity = new_cap;
    }

    list->edges[list->count].to = to;
    list->edges[list->count].weight = weight;
    list->count++;
}

void free_graph(Graph* graph) {
    int i;
    if (!graph) return;

    if (graph->adjacency) {
        for (i = 0; i < graph->num_vertices; i++) {
            free(graph->adjacency[i].edges);
        }
        free(graph->adjacency);
    }
    free(graph);
}

DijkstraResult* dijkstra(const Graph* graph, int source) {
    DijkstraResult* result;
    MinHeap heap;
    bool* visited;
    long total_edges = 0;
    int i;
    int n;

    if (!graph || !graph->adjacency) return NULL;
    n = graph->num_vertices;
    if (source < 0 || source >= n) return NULL;

    result = (DijkstraResult*)malloc(sizeof(DijkstraResult));
    if (!result) return NULL;

    result->num_vertices = n;
    result->source = source;
    result->distances = (double*)malloc(sizeof(double) * (size_t)n);
    result->predecessors = (int*)malloc(sizeof(int) * (size_t)n);
    visited = (bool*)calloc((size_t)n, sizeof(bool));

    if (!result->distances || !result->predecessors || !visited) {
        free(result->distances);
        free(result->predecessors);
        free(visited);
        free(result);
        return NULL;
    }

    for (i = 0; i < n; i++) {
        result->distances[i] = INFINITY;
        result->predecessors[i] = -1;
        total_edges += graph->adjacency[i].count;
    }

    if (!heap_init(&heap, (int)(total_edges + 1))) {
        free(result->distances);
        free(result->predecessors);
        free(visited);
        free(result);
        return NULL;
    }

    result->distances[source] = 0.0;
    heap_push(&heap, 0.0, source);

    while (heap.size > 0) {
        HeapItem item = heap_pop(&heap);
        int u = item.vertex;
        const AdjList* list;
        int e;

        if (visited[u]) continue;
        if (item.dist > result->distances[u]) continue;
        visited[u] = true;

        list = &graph->adjacency[u];
        for (e = 0; e < list->count; e++) {
            int v = list->edges[e].to;
            double nd = result->distances[u] + list->edges[e].weight;
            if (!visited[v] && nd < result->distances[v]) {
                result->distances[v] = nd;
                result->predecessors[v] = u;
                heap_push(&heap, nd, v);
            }
        }
    }

    heap_free(&heap);
    free(visited);
    return result;
}

double get_shortest_distance(const DijkstraResult* result, int target) {
    if (!result || !result->distances) return INFINITY;
    if (target < 0 || target >= result->num_vertices) return INFINITY;
    return result->distances[target];
}

int* reconstruct_path(const DijkstraResult* result, int target, int* path_length) {
    int len = 0;
    int v;
    int* path;

    if (path_length) *path_length = 0;
    if (!result || !result->distances || !result->predecessors) return NULL;
    if (!path_length) return NULL;
    if (target < 0 || target >= result->num_vertices) return NULL;
    if (isinf(result->distances[target])) return NULL;

    v = target;
    while (v != -1) {
        len++;
        if (len > result->num_vertices) return NULL; /* cycle guard */
        v = result->predecessors[v];
    }

    path = (int*)malloc(sizeof(int) * (size_t)len);
    if (!path) return NULL;

    v = target;
    for (int i = len - 1; i >= 0; i--) {
        path[i] = v;
        v = result->predecessors[v];
    }

    *path_length = len;
    return path;
}

void free_result(DijkstraResult* result) {
    if (!result) return;
    free(result->distances);
    free(result->predecessors);
    free(result);
}
