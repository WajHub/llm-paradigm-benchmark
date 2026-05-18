#include "spatial_logic.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#define EPS 1e-9
static double cross(Point a, Point b) { return a.x * b.y - a.y * b.x; }
static Point sub(Point a, Point b) { return (Point){a.x - b.x, a.y - b.y}; }
static Point add(Point a, Point b) { return (Point){a.x + b.x, a.y + b.y}; }

static int cmp_points(const void *a, const void *b)
{
    const Point *pa = (const Point *)a;
    const Point *pb = (const Point *)b;
    if (pa->x < pb->x)
        return -1;
    if (pa->x > pb->x)
        return 1;
    if (pa->y < pb->y)
        return -1;
    if (pa->y > pb->y)
        return 1;
    return 0;
}
Polygon *calculate_clean_minkowski_sum(const Polygon *poly1, const Polygon *poly2)
{
    if (!poly1 || !poly2)
        return NULL;
    if (poly1->num_vertices == 0 || poly2->num_vertices == 0)
    {
        Polygon *res = calloc(1, sizeof(Polygon));
        res->vertices = NULL;
        res->num_vertices = 0;
        res->is_convex = true;
        strncpy(res->zone_name, "mink_sum", 31);
        res->zone_name[31] = '\0';
        return res;
    }

    int n = poly1->num_vertices;
    int m = poly2->num_vertices;
    int total = n * m;
    Point *pts = malloc(total * sizeof(Point));
    int k = 0;
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            pts[k++] = add(poly1->vertices[i], poly2->vertices[j]);
        }
    }

    qsort(pts, total, sizeof(Point), cmp_points);

    Point *hull = malloc((total + 1) * sizeof(Point));
    int h = 0;

    for (int i = 0; i < total; i++)
    {
        while (h >= 2)
        {
            double cp = cross(sub(hull[h - 1], hull[h - 2]), sub(pts[i], hull[h - 2]));
            if (cp <= EPS)
                h--;
            else
                break;
        }
        hull[h++] = pts[i];
    }

    for (int i = total - 2, t = h + 1; i >= 0; i--)
    {
        while (h >= t)
        {
            double cp = cross(sub(hull[h - 1], hull[h - 2]), sub(pts[i], hull[h - 2]));
            if (cp <= EPS)
                h--;
            else
                break;
        }
        hull[h++] = pts[i];
    }

    if (h > 1 && hull[h - 1].x == hull[0].x && hull[h - 1].y == hull[0].y)
    {
        h--;
    }

    Polygon *res = malloc(sizeof(Polygon));
    if (h > 0)
    {
        res->vertices = malloc(h * sizeof(Point));
        memcpy(res->vertices, hull, h * sizeof(Point));
    }
    else
    {
        res->vertices = NULL;
    }
    res->num_vertices = h;
    res->is_convex = true;
    memset(res->zone_name, 0, sizeof(res->zone_name));
    strncpy(res->zone_name, "mink_sum", 31);
    res->zone_name[31] = '\0';

    free(pts);
    free(hull);
    return res;
}
void free_polygon(Polygon *poly)
{
    if (poly)
    {
        free(poly->vertices);
        free(poly);
    }
}
static bool point_in_convex(const Polygon *poly, Point p)
{
    int n = poly->num_vertices;
    if (n < 3)
        return false;
    for (int i = 0; i < n; i++)
    {
        Point a = poly->vertices[i];
        Point b = poly->vertices[(i + 1) % n];
        if (cross(sub(b, a), sub(p, a)) < -EPS)
            return false;
    }
    return true;
}
static bool segments_intersect(Point p1, Point p2, Point q1, Point q2)
{
    double d1 = cross(sub(p2, p1), sub(q1, p1));
    double d2 = cross(sub(p2, p1), sub(q2, p1));
    double d3 = cross(sub(q2, q1), sub(p1, q1));
    double d4 = cross(sub(q2, q1), sub(p2, q1));
    bool s1 = ((d1 > -EPS && d2 < EPS) || (d1 < EPS && d2 > -EPS));
    bool s2 = ((d3 > -EPS && d4 < EPS) || (d3 < EPS && d4 > -EPS));
    return s1 && s2;
}
bool check_dynamic_collision(const Polygon *obstacle, const Polygon *robot, Point velocity)
{
    if (!obstacle || !robot || obstacle->num_vertices == 0 || robot->num_vertices == 0)
        return false;

    int n = robot->num_vertices;
    Point *neg_v = malloc(n * sizeof(Point));
    for (int i = 0; i < n; i++)
    {
        neg_v[i] = (Point){-robot->vertices[i].x, -robot->vertices[i].y};
    }
    Polygon neg_r;
    neg_r.vertices = neg_v;
    neg_r.num_vertices = n;
    neg_r.is_convex = true;
    memset(neg_r.zone_name, 0, sizeof(neg_r.zone_name));

    Polygon *cspace = calculate_clean_minkowski_sum(obstacle, &neg_r);
    free(neg_v);

    if (!cspace || cspace->num_vertices == 0)
    {
        free_polygon(cspace);
        return false;
    }

    Point origin = {0.0, 0.0};
    bool collides = false;

    if (point_in_convex(cspace, origin) || point_in_convex(cspace, velocity))
    {
        collides = true;
    }
    else
    {
        int nv = cspace->num_vertices;
        for (int i = 0; i < nv; i++)
        {
            Point a = cspace->vertices[i];
            Point b = cspace->vertices[(i + 1) % nv];
            if (segments_intersect(origin, velocity, a, b))
            {
                collides = true;
                break;
            }
        }
    }

    free_polygon(cspace);
    return collides;
}
Polygon *create_polygon(int num_vertices, const char *name)
{
    Polygon *p = calloc(1, sizeof(Polygon));
    if (num_vertices > 0)
    {
        p->vertices = calloc(num_vertices, sizeof(Point));
    }
    p->num_vertices = num_vertices;
    p->is_convex = false;
    if (name)
    {
        strncpy(p->zone_name, name, 31);
        p->zone_name[31] = '\0';
    }
    return p;
}
SpatialLayer *create_layer(const char *name)
{
    SpatialLayer *l = calloc(1, sizeof(SpatialLayer));
    l->polygons = NULL;
    l->polygon_count = 0;
    if (name)
    {
        strncpy(l->layer_name, name, 63);
        l->layer_name[63] = '\0';
    }
    return l;
}
void free_layer(SpatialLayer *layer)
{
    if (layer)
    {
        for (int i = 0; i < layer->polygon_count; i++)
        {
            free_polygon(layer->polygons[i]);
        }
        free(layer->polygons);
        free(layer);
    }
}