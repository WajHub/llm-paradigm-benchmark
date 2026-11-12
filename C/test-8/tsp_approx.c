#include "tsp_approx.h"
#include <stdlib.h>

int tsp_mst_weight(const TspPoint* pts, int n) {
    (void)pts; (void)n;
    return -1;
}

TourResult* tsp_double_tree(const TspPoint* pts, int n) {
    (void)pts; (void)n;
    return NULL;
}

int tsp_matching_weight(const TspPoint* pts, int n) {
    (void)pts; (void)n;
    return -1;
}

TourResult* tsp_christofides(const TspPoint* pts, int n) {
    (void)pts; (void)n;
    return NULL;
}

void free_tour_result(TourResult* result) {
    (void)result;
}
