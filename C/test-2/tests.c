#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include "dijkstra.h"

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

static bool approx_equal(double a, double b) {
    return fabs(a - b) < 1e-9;
}

static bool distance_is(double actual, double expected) {
    if (isinf(expected)) {
        return isinf(actual) && actual > 0;
    }
    return approx_equal(actual, expected);
}

static bool check_distance(const DijkstraResult* result, int target, double expected) {
    double d = get_shortest_distance(result, target);
    return distance_is(d, expected);
}

bool path_equals(int* path, int len, int* expected, int expected_len) {
    if (len != expected_len) return false;
    if (len == 0) return path == NULL && expected == NULL;
    if (!path || !expected) return false;
    for (int i = 0; i < len; i++) {
        if (path[i] != expected[i]) return false;
    }
    return true;
}

static Graph* create_linear_chain(int num_vertices, double weight) {
    Graph* graph = create_graph(num_vertices);
    if (!graph) return NULL;
    for (int i = 0; i < num_vertices - 1; i++) {
        graph_add_edge(graph, i, i + 1, weight);
    }
    return graph;
}

// ============================================================================
// ALGORITHM A: Shortest Distances
// ============================================================================

bool test_algo_a_01_linear_chain() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 1, 2, 2.0);
    graph_add_edge(graph, 2, 3, 3.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = true;
    if (!check_distance(result, 0, 0.0)) passed = false;
    if (!check_distance(result, 1, 1.0)) passed = false;
    if (!check_distance(result, 2, 3.0)) passed = false;
    if (!check_distance(result, 3, 6.0)) passed = false;

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_02_diamond() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 0, 2, 4.0);
    graph_add_edge(graph, 1, 3, 6.0);
    graph_add_edge(graph, 2, 3, 1.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = true;
    if (!check_distance(result, 0, 0.0)) passed = false;
    if (!check_distance(result, 1, 1.0)) passed = false;
    if (!check_distance(result, 2, 4.0)) passed = false;
    if (!check_distance(result, 3, 5.0)) passed = false;

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_03_disconnected() {
    Graph* graph = create_graph(5);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 2.0);
    graph_add_edge(graph, 1, 2, 3.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = true;
    if (!check_distance(result, 0, 0.0)) passed = false;
    if (!check_distance(result, 1, 2.0)) passed = false;
    if (!check_distance(result, 2, 5.0)) passed = false;
    if (!check_distance(result, 3, INFINITY)) passed = false;
    if (!check_distance(result, 4, INFINITY)) passed = false;

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_04_single_vertex() {
    Graph* graph = create_graph(1);
    if (!graph) return false;

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = check_distance(result, 0, 0.0);

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_05_parallel_edges() {
    Graph* graph = create_graph(2);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 5.0);
    graph_add_edge(graph, 0, 1, 2.0);
    graph_add_edge(graph, 0, 1, 8.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = check_distance(result, 1, 2.0);

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_06_zero_weight_edges() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 0.0);
    graph_add_edge(graph, 1, 2, 0.0);
    graph_add_edge(graph, 2, 3, 1.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = true;
    if (!check_distance(result, 1, 0.0)) passed = false;
    if (!check_distance(result, 2, 0.0)) passed = false;
    if (!check_distance(result, 3, 1.0)) passed = false;

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_07_null_graph() {
    DijkstraResult* result = dijkstra(NULL, 0);
    return result == NULL;
}

bool test_algo_a_08_invalid_source() {
    Graph* graph = create_graph(3);
    if (!graph) return false;

    DijkstraResult* result_high = dijkstra(graph, 5);
    DijkstraResult* result_low = dijkstra(graph, -1);

    bool passed = (result_high == NULL && result_low == NULL);

    if (result_high) free_result(result_high);
    if (result_low) free_result(result_low);
    free_graph(graph);
    return passed;
}

bool test_algo_a_09_complex_graph() {
    Graph* graph = create_graph(6);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 7.0);
    graph_add_edge(graph, 0, 2, 9.0);
    graph_add_edge(graph, 0, 5, 14.0);
    graph_add_edge(graph, 1, 2, 10.0);
    graph_add_edge(graph, 1, 3, 15.0);
    graph_add_edge(graph, 2, 3, 11.0);
    graph_add_edge(graph, 2, 5, 2.0);
    graph_add_edge(graph, 3, 4, 6.0);
    graph_add_edge(graph, 4, 5, 9.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = true;
    if (!check_distance(result, 0, 0.0)) passed = false;
    if (!check_distance(result, 1, 7.0)) passed = false;
    if (!check_distance(result, 2, 9.0)) passed = false;
    if (!check_distance(result, 3, 20.0)) passed = false;
    if (!check_distance(result, 4, 26.0)) passed = false;
    if (!check_distance(result, 5, 11.0)) passed = false;

    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_a_10_stress() {
    const int num_vertices = 1000;
    Graph* graph = create_linear_chain(num_vertices, 1.0);
    if (!graph) return false;

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    bool passed = check_distance(result, 999, 999.0);

    free_result(result);
    free_graph(graph);
    return passed;
}

// ============================================================================
// ALGORITHM B: Path Reconstruction
// ============================================================================

bool test_algo_b_01_simple_path() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 1, 2, 2.0);
    graph_add_edge(graph, 2, 3, 3.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 3, &path_length);
    int expected[] = {0, 1, 2, 3};

    bool passed = path_equals(path, path_length, expected, 4);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_02_diamond_path() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 0, 2, 4.0);
    graph_add_edge(graph, 1, 3, 6.0);
    graph_add_edge(graph, 2, 3, 1.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 3, &path_length);
    int expected[] = {0, 2, 3};

    bool passed = path_equals(path, path_length, expected, 3);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_03_self_path() {
    Graph* graph = create_graph(3);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 1, 2, 1.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 0, &path_length);
    int expected[] = {0};

    bool passed = path_equals(path, path_length, expected, 1);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_04_unreachable() {
    Graph* graph = create_graph(5);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 2.0);
    graph_add_edge(graph, 1, 2, 3.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = -1;
    int* path = reconstruct_path(result, 4, &path_length);

    bool passed = (path == NULL);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_05_long_chain() {
    const int num_vertices = 10;
    Graph* graph = create_linear_chain(num_vertices, 1.0);
    if (!graph) return false;

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 9, &path_length);
    int expected[10];
    for (int i = 0; i < num_vertices; i++) {
        expected[i] = i;
    }

    bool passed = path_equals(path, path_length, expected, num_vertices);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_06_cycle() {
    Graph* graph = create_graph(4);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 1, 2, 1.0);
    graph_add_edge(graph, 2, 0, 1.0);
    graph_add_edge(graph, 1, 3, 2.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 3, &path_length);
    int expected[] = {0, 1, 3};

    bool passed = path_equals(path, path_length, expected, 3);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_07_star() {
    Graph* graph = create_graph(5);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 2.0);
    graph_add_edge(graph, 0, 2, 3.0);
    graph_add_edge(graph, 0, 3, 1.0);
    graph_add_edge(graph, 0, 4, 5.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 3, &path_length);
    int expected[] = {0, 3};

    bool passed = path_equals(path, path_length, expected, 2);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_08_null_result() {
    int path_length = -1;
    int* path = reconstruct_path(NULL, 0, &path_length);
    return path == NULL;
}

bool test_algo_b_09_bidirectional() {
    Graph* graph = create_graph(3);
    if (!graph) return false;

    graph_add_edge(graph, 0, 1, 1.0);
    graph_add_edge(graph, 1, 0, 10.0);
    graph_add_edge(graph, 1, 2, 1.0);
    graph_add_edge(graph, 0, 2, 5.0);

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 2, &path_length);
    int expected[] = {0, 1, 2};

    bool passed = path_equals(path, path_length, expected, 3);

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

bool test_algo_b_10_stress_path() {
    const int num_vertices = 1000;
    Graph* graph = create_linear_chain(num_vertices, 1.0);
    if (!graph) return false;

    DijkstraResult* result = dijkstra(graph, 0);
    if (!result) {
        free_graph(graph);
        return false;
    }

    int path_length = 0;
    int* path = reconstruct_path(result, 999, &path_length);

    bool passed = true;
    if (!path) {
        passed = false;
    } else {
        if (path_length != num_vertices) passed = false;
        if (path[0] != 0) passed = false;
        if (path[num_vertices - 1] != 999) passed = false;
    }

    free(path);
    free_result(result);
    free_graph(graph);
    return passed;
}

// ============================================================================
// MAIN RUNNER
// ============================================================================

int main() {
    int failed_count = 0;
    const char* failed_tests[50];
    int total_tests = 0;

    #define RUN_TEST(func, name) \
        do { \
            total_tests++; \
            if (func()) { \
                printf("[PASS] %s\n", name); \
            } else { \
                printf("[FAIL] %s\n", name); \
                failed_tests[failed_count++] = name; \
            } \
        } while (0)

    printf("=== START ===\n");
    printf("\n--- Algorithm A: Shortest Distances ---\n");
    RUN_TEST(test_algo_a_01_linear_chain, "Test A01 (Linear Chain)");
    RUN_TEST(test_algo_a_02_diamond, "Test A02 (Diamond)");
    RUN_TEST(test_algo_a_03_disconnected, "Test A03 (Disconnected)");
    RUN_TEST(test_algo_a_04_single_vertex, "Test A04 (Single Vertex)");
    RUN_TEST(test_algo_a_05_parallel_edges, "Test A05 (Parallel Edges)");
    RUN_TEST(test_algo_a_06_zero_weight_edges, "Test A06 (Zero-Weight Edges)");
    RUN_TEST(test_algo_a_07_null_graph, "Test A07 (Null Graph)");
    RUN_TEST(test_algo_a_08_invalid_source, "Test A08 (Invalid Source)");
    RUN_TEST(test_algo_a_09_complex_graph, "Test A09 (Complex Graph)");
    RUN_TEST(test_algo_a_10_stress, "Test A10 (Stress 1000-Chain)");

    printf("\n--- Algorithm B: Path Reconstruction ---\n");
    RUN_TEST(test_algo_b_01_simple_path, "Test B01 (Simple Path)");
    RUN_TEST(test_algo_b_02_diamond_path, "Test B02 (Diamond Path)");
    RUN_TEST(test_algo_b_03_self_path, "Test B03 (Self Path)");
    RUN_TEST(test_algo_b_04_unreachable, "Test B04 (Unreachable)");
    RUN_TEST(test_algo_b_05_long_chain, "Test B05 (Long Chain)");
    RUN_TEST(test_algo_b_06_cycle, "Test B06 (Cycle)");
    RUN_TEST(test_algo_b_07_star, "Test B07 (Star)");
    RUN_TEST(test_algo_b_08_null_result, "Test B08 (Null Result)");
    RUN_TEST(test_algo_b_09_bidirectional, "Test B09 (Bidirectional)");
    RUN_TEST(test_algo_b_10_stress_path, "Test B10 (Stress Path 1000-Chain)");

    printf("\n=== BENCHMARK RESULTS ===\n");
    printf("Completed %d tests.\n", total_tests);

    if (failed_count == 0) {
        printf("All tests passed!\n");
        return 0;
    } else {
        printf("Tests that failed (%d):\n", failed_count);
        for (int i = 0; i < failed_count; i++) {
            printf(" - %s\n", failed_tests[i]);
        }
        return 1;
    }
}
