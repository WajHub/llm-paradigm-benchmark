#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include "spatial_logic.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

// ============================================================================
// FUNKCJE POMOCNICZE
// ============================================================================

bool contains_point(const Polygon* poly, double x, double y) {
    if (!poly || !poly->vertices) return false;
    for (int i = 0; i < poly->num_vertices; i++) {
        if (fabs(poly->vertices[i].x - x) < 0.001 &&
            fabs(poly->vertices[i].y - y) < 0.001) {
            return true;
        }
    }
    return false;
}

// ============================================================================
// TESTY Algorytmu: calculate_clean_minkowski_sum (Convex Hull)
// ============================================================================

bool test_algo_a_01_basic_squares() {
    Point p1_pts[] = {{0,0}, {2,0}, {2,2}, {0,2}};
    Polygon poly1 = {p1_pts, 4, true, "Z1"};
    Point p2_pts[] = {{0,0}, {2,0}, {2,2}, {0,2}};
    Polygon poly2 = {p2_pts, 4, true, "Z2"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 4) passed = false;
    if (!contains_point(result, 0, 0)) passed = false;
    if (!contains_point(result, 4, 0)) passed = false;
    if (!contains_point(result, 4, 4)) passed = false;
    if (!contains_point(result, 0, 4)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_02_point_and_polygon() {
    Point p1_pts[] = {{5, 5}};
    Polygon poly1 = {p1_pts, 1, true, "Point"};
    Point p2_pts[] = {{0,0}, {1,0}, {0,1}};
    Polygon poly2 = {p2_pts, 3, true, "Triangle"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 3) passed = false;
    if (!contains_point(result, 5, 5)) passed = false;
    if (!contains_point(result, 6, 5)) passed = false;
    if (!contains_point(result, 5, 6)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_03_collinear_simplification() {
    Point p1_pts[] = {{0,0}, {2,0}, {0,2}};
    Polygon poly1 = {p1_pts, 3, true, "Tri1"};
    Point p2_pts[] = {{0,0}, {2,0}, {0,2}};
    Polygon poly2 = {p2_pts, 3, true, "Tri2"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 3) passed = false;
    if (!contains_point(result, 0, 0)) passed = false;
    if (!contains_point(result, 4, 0)) passed = false;
    if (!contains_point(result, 0, 4)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_04_negative_coordinates() {
    Point p1_pts[] = {{-5,-5}, {-3,-5}, {-3,-3}, {-5,-3}};
    Polygon poly1 = {p1_pts, 4, true, "NegSq"};
    Point p2_pts[] = {{1,1}, {2,1}, {2,2}, {1,2}};
    Polygon poly2 = {p2_pts, 4, true, "PosSq"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 4) passed = false;
    if (!contains_point(result, -4, -4)) passed = false;
    if (!contains_point(result, -1, -1)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_05_single_points() {
    Point p1_pts[] = {{-2.5, 3.5}};
    Polygon poly1 = {p1_pts, 1, true, "Pt1"};
    Point p2_pts[] = {{2.5, -3.5}};
    Polygon poly2 = {p2_pts, 1, true, "Pt2"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 1) passed = false;
    if (!contains_point(result, 0.0, 0.0)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_06_empty_first_polygon() {
    Polygon poly1 = {NULL, 0, true, "Empty"};
    Point p2_pts[] = {{0,0}, {1,1}};
    Polygon poly2 = {p2_pts, 2, true, "Line"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = (result->num_vertices == 0);
    free_polygon(result);
    return passed;
}

bool test_algo_a_07_empty_second_polygon() {
    Point p1_pts[] = {{0,0}, {1,1}};
    Polygon poly1 = {p1_pts, 2, true, "Line"};
    Polygon poly2 = {NULL, 0, true, "Empty"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = (result->num_vertices == 0);
    free_polygon(result);
    return passed;
}

bool test_algo_a_08_null_arguments() {
    Point p1_pts[] = {{0,0}};
    Polygon poly1 = {p1_pts, 1, true, "Pt"};

    Polygon* result1 = calculate_clean_minkowski_sum(NULL, &poly1);
    Polygon* result2 = calculate_clean_minkowski_sum(&poly1, NULL);
    Polygon* result3 = calculate_clean_minkowski_sum(NULL, NULL);

    bool passed = true;
    if (result1 != NULL) { free_polygon(result1); passed = false; }
    if (result2 != NULL) { free_polygon(result2); passed = false; }
    if (result3 != NULL) { free_polygon(result3); passed = false; }

    return passed;
}

bool test_algo_a_09_flat_polygon() {
    Point p1_pts[] = {{0,0}, {2,0}};
    Polygon poly1 = {p1_pts, 2, true, "Line1"};
    Point p2_pts[] = {{0,0}, {3,0}};
    Polygon poly2 = {p2_pts, 2, true, "Line2"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    if (!result) return false;

    bool passed = true;
    if (result->num_vertices != 2) passed = false;
    if (!contains_point(result, 0, 0)) passed = false;
    if (!contains_point(result, 5, 0)) passed = false;

    free_polygon(result);
    return passed;
}

bool test_algo_a_10_stress_test() {
    int size = 500;
    Point* large_arr = (Point*)malloc(size * sizeof(Point));
    for (int i = 0; i < size; i++) {
        large_arr[i].x = cos(2.0 * M_PI * i / size);
        large_arr[i].y = sin(2.0 * M_PI * i / size);
    }

    Polygon poly1 = {large_arr, size, true, "Circle1"};
    Polygon poly2 = {large_arr, size, true, "Circle2"};

    Polygon* result = calculate_clean_minkowski_sum(&poly1, &poly2);
    bool passed = true;
    if (!result) {
        passed = false;
    } else {
        if (result->num_vertices <= 0) passed = false;
        free_polygon(result);
    }

    free(large_arr);
    return passed;
}

// ============================================================================
// TESTY Algorytmu: check_dynamic_collision (Bullet-Tunneling Prevention)
// ============================================================================

bool test_algo_b_01_tunneling_collision() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{5,0}, {6,0}, {6,1}, {5,1}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {10.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == true;
}

bool test_algo_b_02_clear_miss() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{0,5}, {1,5}, {1,6}, {0,6}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {10.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == false;
}

bool test_algo_b_03_static_overlap() {
    Point rob_pts[] = {{0,0}, {2,0}, {2,2}, {0,2}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{1,1}, {3,1}, {3,3}, {1,3}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {0.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == true;
}

bool test_algo_b_04_static_miss() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{10,10}, {11,10}, {11,11}, {10,11}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {0.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == false;
}

bool test_algo_b_05_moving_away() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{-5,0}, {-4,0}, {-4,1}, {-5,1}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {10.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == false;
}

bool test_algo_b_06_diagonal_tunneling() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{5,5}, {7,5}, {7,7}, {5,7}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {10.0, 10.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == true;
}

bool test_algo_b_07_edge_grazing() {
    Point rob_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{0,1}, {1,1}, {1,2}, {0,2}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {10.0, 0.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == true;
}

bool test_algo_b_08_negative_velocity() {
    Point rob_pts[] = {{10,10}, {11,10}, {11,11}, {10,11}};
    Polygon robot = {rob_pts, 4, true, "Robot"};
    Point obs_pts[] = {{4,4}, {6,4}, {6,6}, {4,6}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {-10.0, -10.0};

    return check_dynamic_collision(&obstacle, &robot, velocity) == true;
}

bool test_algo_b_09_empty_polygons() {
    Polygon empty_poly = {NULL, 0, true, "Empty"};
    Point obs_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {5.0, 5.0};

    bool col1 = check_dynamic_collision(&obstacle, &empty_poly, velocity);
    bool col2 = check_dynamic_collision(&empty_poly, &obstacle, velocity);
    
    return (col1 == false && col2 == false);
}

bool test_algo_b_10_null_arguments() {
    Point obs_pts[] = {{0,0}, {1,0}, {1,1}, {0,1}};
    Polygon obstacle = {obs_pts, 4, true, "Obstacle"};
    Point velocity = {5.0, 5.0};

    bool col1 = check_dynamic_collision(NULL, &obstacle, velocity);
    bool col2 = check_dynamic_collision(&obstacle, NULL, velocity);
    bool col3 = check_dynamic_collision(NULL, NULL, velocity);

    return (col1 == false && col2 == false && col3 == false);
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
    printf("\n--- Algorithm A: Clean Minkowski Sum (Convex Hull) ---\n");
    RUN_TEST(test_algo_a_01_basic_squares, "Test A01 (Basic Squares Hull)");
    RUN_TEST(test_algo_a_02_point_and_polygon, "Test A02 (Point and Polygon)");
    RUN_TEST(test_algo_a_03_collinear_simplification, "Test A03 (Collinear Simplification)");
    RUN_TEST(test_algo_a_04_negative_coordinates, "Test A04 (Negative Coordinates)");
    RUN_TEST(test_algo_a_05_single_points, "Test A05 (Single Points)");
    RUN_TEST(test_algo_a_06_empty_first_polygon, "Test A06 (Empty First Polygon)");
    RUN_TEST(test_algo_a_07_empty_second_polygon, "Test A07 (Empty Second Polygon)");
    RUN_TEST(test_algo_a_08_null_arguments, "Test A08 (Null Arguments)");
    RUN_TEST(test_algo_a_09_flat_polygon, "Test A09 (Flat Polygons / Lines)");
    RUN_TEST(test_algo_a_10_stress_test, "Test A10 (Stress Test 500x500)");

    printf("\n--- Algorithm B: Dynamic Collision Detection ---\n");
    RUN_TEST(test_algo_b_01_tunneling_collision, "Test B01 (Tunneling Collision)");
    RUN_TEST(test_algo_b_02_clear_miss, "Test B02 (Clear Miss)");
    RUN_TEST(test_algo_b_03_static_overlap, "Test B03 (Static Overlap)");
    RUN_TEST(test_algo_b_04_static_miss, "Test B04 (Static Miss)");
    RUN_TEST(test_algo_b_05_moving_away, "Test B05 (Moving Away)");
    RUN_TEST(test_algo_b_06_diagonal_tunneling, "Test B06 (Diagonal Tunneling)");
    RUN_TEST(test_algo_b_07_edge_grazing, "Test B07 (Edge Grazing)");
    RUN_TEST(test_algo_b_08_negative_velocity, "Test B08 (Negative Velocity)");
    RUN_TEST(test_algo_b_09_empty_polygons, "Test B09 (Empty Polygons)");
    RUN_TEST(test_algo_b_10_null_arguments, "Test B10 (NULL Arguments)");

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