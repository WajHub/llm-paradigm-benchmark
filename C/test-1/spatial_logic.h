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