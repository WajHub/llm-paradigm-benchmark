#include "spatial_logic.h"
#include <stdlib.h>

Polygon* calculate_clean_minkowski_sum(const Polygon* poly1, const Polygon* poly2) {
    (void)poly1; (void)poly2;
    return NULL;
}

bool check_dynamic_collision(const Polygon* obstacle, const Polygon* robot, Point velocity) {
    (void)obstacle; (void)robot; (void)velocity;
    return false;
}

Polygon* create_polygon(int num_vertices, const char* name) {
    (void)num_vertices; (void)name;
    return NULL;
}

void free_polygon(Polygon* poly) {
    (void)poly;
}

SpatialLayer* create_layer(const char* name) {
    (void)name;
    return NULL;
}

void free_layer(SpatialLayer* layer) {
    (void)layer;
}
