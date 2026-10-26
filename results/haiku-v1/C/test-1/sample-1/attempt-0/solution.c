#include <stdlib.h>
#include <string.h>
#include "spatial_logic.h"

#define GEO_EPS 1e-9

static double geo_abs(double v)
{
    return v < 0.0 ? -v : v;
}

static double geo_cross(Point o, Point a, Point b)
{
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
}

static void geo_copy_name(char* dst, size_t cap, const char* src)
{
    if (!dst || cap == 0) {
        return;
    }
    dst[0] = '\0';
    if (src) {
        strncpy(dst, src, cap - 1);
        dst[cap - 1] = '\0';
    }
}

static int geo_cmp_points(const void* a, const void* b)
{
    const Point* p = (const Point*)a;
    const Point* q = (const Point*)b;
    if (p->x < q->x) return -1;
    if (p->x > q->x) return 1;
    if (p->y < q->y) return -1;
    if (p->y > q->y) return 1;
    return 0;
}

static bool geo_on_segment(Point a, Point b, Point p)
{
    double minx = a.x < b.x ? a.x : b.x;
    double maxx = a.x > b.x ? a.x : b.x;
    double miny = a.y < b.y ? a.y : b.y;
    double maxy = a.y > b.y ? a.y : b.y;
    return (p.x >= minx - GEO_EPS) && (p.x <= maxx + GEO_EPS) &&
           (p.y >= miny - GEO_EPS) && (p.y <= maxy + GEO_EPS);
}

static bool geo_segments_intersect(Point p1, Point p2, Point q1, Point q2)
{
    double d1 = geo_cross(q1, q2, p1);
    double d2 = geo_cross(q1, q2, p2);
    double d3 = geo_cross(p1, p2, q1);
    double d4 = geo_cross(p1, p2, q2);

    if (((d1 > GEO_EPS && d2 < -GEO_EPS) || (d1 < -GEO_EPS && d2 > GEO_EPS)) &&
        ((d3 > GEO_EPS && d4 < -GEO_EPS) || (d3 < -GEO_EPS && d4 > GEO_EPS))) {
        return true;
    }

    if (geo_abs(d1) <= GEO_EPS && geo_on_segment(q1, q2, p1)) return true;
    if (geo_abs(d2) <= GEO_EPS && geo_on_segment(q1, q2, p2)) return true;
    if (geo_abs(d3) <= GEO_EPS && geo_on_segment(p1, p2, q1)) return true;
    if (geo_abs(d4) <= GEO_EPS && geo_on_segment(p1, p2, q2)) return true;

    return false;
}

Polygon* create_polygon(int num_vertices, const char* name)
{
    Polygon* poly = (Polygon*)calloc(1, sizeof(Polygon));
    if (!poly) {
        return NULL;
    }

    if (num_vertices < 0) {
        num_vertices = 0;
    }

    poly->num_vertices = num_vertices;
    poly->is_convex = true;
    poly->vertices = NULL;

    if (num_vertices > 0) {
        poly->vertices = (Point*)calloc((size_t)num_vertices, sizeof(Point));
        if (!poly->vertices) {
            free(poly);
            return NULL;
        }
    }

    geo_copy_name(poly->zone_name, sizeof(poly->zone_name), name);
    return poly;
}

void free_polygon(Polygon* poly)
{
    if (!poly) {
        return;
    }
    free(poly->vertices);
    poly->vertices = NULL;
    free(poly);
}

SpatialLayer* create_layer(const char* name)
{
    SpatialLayer* layer = (SpatialLayer*)calloc(1, sizeof(SpatialLayer));
    if (!layer) {
        return NULL;
    }
    layer->polygons = NULL;
    layer->polygon_count = 0;
    geo_copy_name(layer->layer_name, sizeof(layer->layer_name), name);
    return layer;
}

void free_layer(SpatialLayer* layer)
{
    if (!layer) {
        return;
    }
    if (layer->polygons) {
        for (int i = 0; i < layer->polygon_count; i++) {
            free_polygon(layer->polygons[i]);
            layer->polygons[i] = NULL;
        }
        free(layer->polygons);
        layer->polygons = NULL;
    }
    layer->polygon_count = 0;
    free(layer);
}

Polygon* calculate_clean_minkowski_sum(const Polygon* poly1, const Polygon* poly2)
{
    if (!poly1 || !poly2) {
        return NULL;
    }

    int n = poly1->num_vertices;
    int m = poly2->num_vertices;

    if (n <= 0 || m <= 0 || !poly1->vertices || !poly2->vertices) {
        return create_polygon(0, "MinkowskiSum");
    }

    size_t total = (size_t)n * (size_t)m;
    Point* pts = (Point*)malloc(sizeof(Point) * total);
    if (!pts) {
        return NULL;
    }

    size_t idx = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            pts[idx].x = poly1->vertices[i].x + poly2->vertices[j].x;
            pts[idx].y = poly1->vertices[i].y + poly2->vertices[j].y;
            idx++;
        }
    }

    qsort(pts, total, sizeof(Point), geo_cmp_points);

    /* Remove duplicate points */
    size_t u = 0;
    for (size_t i = 0; i < total; i++) {
        if (u == 0 ||
            geo_abs(pts[i].x - pts[u - 1].x) > GEO_EPS ||
            geo_abs(pts[i].y - pts[u - 1].y) > GEO_EPS) {
            pts[u++] = pts[i];
        }
    }

    Point* hull = (Point*)malloc(sizeof(Point) * (2 * u + 2));
    if (!hull) {
        free(pts);
        return NULL;
    }

    size_t k = 0;
    if (u <= 2) {
        for (size_t i = 0; i < u; i++) {
            hull[k++] = pts[i];
        }
    } else {
        /* Lower hull */
        for (size_t i = 0; i < u; i++) {
            while (k >= 2 && geo_cross(hull[k - 2], hull[k - 1], pts[i]) <= GEO_EPS) {
                k--;
            }
            hull[k++] = pts[i];
        }
        /* Upper hull */
        size_t t = k + 1;
        for (size_t i = u - 1; i-- > 0; ) {
            while (k >= t && geo_cross(hull[k - 2], hull[k - 1], pts[i]) <= GEO_EPS) {
                k--;
            }
            hull[k++] = pts[i];
        }
        /* Last point equals first point */
        k--;
    }

    Polygon* result = create_polygon((int)k, "MinkowskiSum");
    if (result) {
        for (size_t i = 0; i < k; i++) {
            result->vertices[i] = hull[i];
        }
        result->is_convex = true;
    }

    free(hull);
    free(pts);
    return result;
}

bool check_dynamic_collision(const Polygon* obstacle, const Polygon* robot, Point velocity)
{
    if (!obstacle || !robot) {
        return false;
    }
    if (obstacle->num_vertices <= 0 || robot->num_vertices <= 0 ||
        !obstacle->vertices || !robot->vertices) {
        return false;
    }

    /* Negate robot (180-degree rotation keeps CCW ordering) */
    Polygon* neg = create_polygon(robot->num_vertices, "NegRobot");
    if (!neg) {
        return false;
    }
    for (int i = 0; i < robot->num_vertices; i++) {
        neg->vertices[i].x = -robot->vertices[i].x;
        neg->vertices[i].y = -robot->vertices[i].y;
    }

    /* Configuration space obstacle: C = O (+) (-R) */
    Polygon* cspace = calculate_clean_minkowski_sum(obstacle, neg);
    free_polygon(neg);
    if (!cspace) {
        return false;
    }

    int k = cspace->num_vertices;
    if (k <= 0) {
        free_polygon(cspace);
        return false;
    }

    Point origin = {0.0, 0.0};
    Point tip = velocity;
    bool hit = false;

    /* Robot already overlapping at t = 0 */
    if (k >= 3) {
        bool inside = true;
        for (int i = 0; i < k; i++) {
            Point a = cspace->vertices[i];
            Point b = cspace->vertices[(i + 1) % k];
            if (geo_cross(a, b, origin) < -GEO_EPS) {
                inside = false;
                break;
            }
        }
        if (inside) {
            hit = true;
        }
    }

    /* Path segment [0, v] intersects boundary of C */
    if (!hit) {
        for (int i = 0; i < k; i++) {
            Point a = cspace->vertices[i];
            Point b = cspace->vertices[(i + 1) % k];
            if (geo_segments_intersect(origin, tip, a, b)) {
                hit = true;
                break;
            }
        }
    }

    free_polygon(cspace);
    return hit;
}
