You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

- Implement `calculate_clean_minkowski_sum`: Calculate the Minkowski sum of two convex polygons (poly1 and poly2), and return a new polygon representing ONLY the convex hull of the resulting point cloud. The vertices of the returned polygon must be strictly extreme points (collinear points on the edges must be removed) and ordered counter-clockwise.
- Implement `check_dynamic_collision`: Determine if a moving robot polygon intersects with a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum Configuration Space approach to prevent tunneling (continuous collision detection). Return true if a collision occurs, false otherwise.
- Implement `create_polygon` & `create_layer`: Properly allocate memory for the structures and safely copy the provided strings into zone_name and layer_name.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

#ifndef SPATIAL_LOGIC_H
#define SPATIAL_LOGIC_H

#include <stdbool.h>

typedef struct {
    double x;
    double y;
} Point;

typedef struct {
    Point* vertices;
    int num_vertices;
    bool is_convex;
    char zone_name[32];
} Polygon;

typedef struct {
    Polygon** polygons;
    int polygon_count;
    char layer_name[64];
} SpatialLayer;

Polygon* calculate_clean_minkowski_sum(const Polygon* poly1, const Polygon* poly2);

bool check_dynamic_collision(const Polygon* obstacle, const Polygon* robot, Point velocity);

Polygon* create_polygon(int num_vertices, const char* name);
void free_polygon(Polygon* poly);
SpatialLayer* create_layer(const char* name);
void free_layer(SpatialLayer* layer);

#endif