#include <stdlib.h>
#include <limits.h>
#include "tsp_approx.h"

static int dist_pt(const TspPoint* a, const TspPoint* b) {
    int dx = a->x - b->x;
    int dy = a->y - b->y;
    if (dx < 0) dx = -dx;
    if (dy < 0) dy = -dy;
    return dx + dy;
}

/* Tie-broken Prim's algorithm from vertex 0. Fills parent[] (parent[0] = -1).
   Requires n >= 1 and parent allocated with n entries. Returns total weight. */
static int build_mst(const TspPoint* pts, int n, int* parent) {
    int total = 0;
    parent[0] = -1;
    if (n <= 1) return 0;

    char* in = (char*)calloc((size_t)n, 1);
    int* key = (int*)malloc((size_t)n * sizeof(int));
    in[0] = 1;
    for (int v = 1; v < n; v++) {
        key[v] = dist_pt(&pts[0], &pts[v]);
        parent[v] = 0;
    }

    for (int step = 1; step < n; step++) {
        int best = -1;
        for (int v = 0; v < n; v++) {
            if (!in[v] && (best < 0 || key[v] < key[best])) best = v;
        }
        in[best] = 1;
        total += key[best];
        for (int v = 0; v < n; v++) {
            if (in[v]) continue;
            int d = dist_pt(&pts[best], &pts[v]);
            if (d < key[v] || (d == key[v] && best < parent[v])) {
                key[v] = d;
                parent[v] = best;
            }
        }
    }

    free(in);
    free(key);
    return total;
}

static int tour_cost(const TspPoint* pts, const int* tour, int n) {
    if (n <= 1) return 0;
    int c = 0;
    for (int i = 0; i < n; i++) {
        int j = (i + 1 == n) ? 0 : i + 1;
        c += dist_pt(&pts[tour[i]], &pts[tour[j]]);
    }
    return c;
}

static TourResult* make_result(int n) {
    TourResult* r = (TourResult*)malloc(sizeof(TourResult));
    if (!r) return NULL;
    r->tour = (int*)malloc((size_t)(n > 0 ? n : 1) * sizeof(int));
    r->n = n;
    r->cost = 0;
    return r;
}

static void preorder(int u, const int* parent, int n, int* out, int* cnt) {
    out[(*cnt)++] = u;
    for (int v = 1; v < n; v++) {
        if (parent[v] == u) preorder(v, parent, n, out, cnt);
    }
}

/* Exact minimum perfect matching on k points (k even, k <= ~20) via bitmask DP.
   If outA/outB are non-NULL, the matched pairs (as vertex indices) are stored. */
static int min_matching(const TspPoint* pts, const int* O, int k,
                        int* outA, int* outB) {
    if (k == 0) return 0;
    int full = 1 << k;
    int* dp = (int*)malloc((size_t)full * sizeof(int));
    const int INF = INT_MAX / 2;
    dp[0] = 0;
    for (int mask = 1; mask < full; mask++) {
        int i = 0;
        while (!((mask >> i) & 1)) i++;
        int best = INF;
        for (int j = i + 1; j < k; j++) {
            if (!((mask >> j) & 1)) continue;
            int sub = mask ^ (1 << i) ^ (1 << j);
            if (dp[sub] >= INF) continue;
            int c = dp[sub] + dist_pt(&pts[O[i]], &pts[O[j]]);
            if (c < best) best = c;
        }
        dp[mask] = best;
    }

    int result = dp[full - 1];

    if (outA && outB) {
        int mask = full - 1;
        int np = 0;
        while (mask) {
            int i = 0;
            while (!((mask >> i) & 1)) i++;
            int found = 0;
            for (int j = i + 1; j < k && !found; j++) {
                if (!((mask >> j) & 1)) continue;
                int sub = mask ^ (1 << i) ^ (1 << j);
                if (dp[sub] >= INF) continue;
                if (dp[sub] + dist_pt(&pts[O[i]], &pts[O[j]]) == dp[mask]) {
                    outA[np] = O[i];
                    outB[np] = O[j];
                    np++;
                    mask = sub;
                    found = 1;
                }
            }
            if (!found) break; /* should not happen */
        }
    }

    free(dp);
    return result;
}

/* Collects odd-degree vertices of the tree given by parent[]. Returns count k. */
static int odd_vertices(const int* parent, int n, int* O) {
    int* deg = (int*)calloc((size_t)n, sizeof(int));
    for (int v = 1; v < n; v++) {
        deg[v]++;
        deg[parent[v]]++;
    }
    int k = 0;
    for (int v = 0; v < n; v++) {
        if (deg[v] & 1) O[k++] = v;
    }
    free(deg);
    return k;
}

int tsp_mst_weight(const TspPoint* pts, int n) {
    if (n <= 1) return 0;
    int* parent = (int*)malloc((size_t)n * sizeof(int));
    int w = build_mst(pts, n, parent);
    free(parent);
    return w;
}

TourResult* tsp_double_tree(const TspPoint* pts, int n) {
    if (n == 0) return NULL;
    TourResult* r = make_result(n);
    if (!r) return NULL;
    if (n == 1) {
        r->tour[0] = 0;
        r->cost = 0;
        return r;
    }
    int* parent = (int*)malloc((size_t)n * sizeof(int));
    build_mst(pts, n, parent);
    int cnt = 0;
    preorder(0, parent, n, r->tour, &cnt);
    r->cost = tour_cost(pts, r->tour, n);
    free(parent);
    return r;
}

int tsp_matching_weight(const TspPoint* pts, int n) {
    if (n <= 1) return 0;
    int* parent = (int*)malloc((size_t)n * sizeof(int));
    build_mst(pts, n, parent);
    int* O = (int*)malloc((size_t)n * sizeof(int));
    int k = odd_vertices(parent, n, O);
    int w = min_matching(pts, O, k, NULL, NULL);
    free(O);
    free(parent);
    return w;
}

TourResult* tsp_christofides(const TspPoint* pts, int n) {
    if (n == 0) return NULL;
    TourResult* r = make_result(n);
    if (!r) return NULL;
    if (n == 1) {
        r->tour[0] = 0;
        r->cost = 0;
        return r;
    }

    int* parent = (int*)malloc((size_t)n * sizeof(int));
    build_mst(pts, n, parent);

    int* O = (int*)malloc((size_t)n * sizeof(int));
    int k = odd_vertices(parent, n, O);
    int np = k / 2;
    int* pairA = (int*)malloc((size_t)(np > 0 ? np : 1) * sizeof(int));
    int* pairB = (int*)malloc((size_t)(np > 0 ? np : 1) * sizeof(int));
    min_matching(pts, O, k, pairA, pairB);

    int E = (n - 1) + np;
    int* eu = (int*)malloc((size_t)E * sizeof(int));
    int* ev = (int*)malloc((size_t)E * sizeof(int));
    for (int v = 1; v < n; v++) {
        eu[v - 1] = v;
        ev[v - 1] = parent[v];
    }
    for (int p = 0; p < np; p++) {
        eu[n - 1 + p] = pairA[p];
        ev[n - 1 + p] = pairB[p];
    }

    /* Multigraph adjacency in CSR form. */
    int* deg2 = (int*)calloc((size_t)n, sizeof(int));
    for (int e = 0; e < E; e++) {
        deg2[eu[e]]++;
        deg2[ev[e]]++;
    }
    int* start = (int*)malloc((size_t)(n + 1) * sizeof(int));
    start[0] = 0;
    for (int v = 0; v < n; v++) start[v + 1] = start[v] + deg2[v];
    int* fill = (int*)calloc((size_t)n, sizeof(int));
    int* adj = (int*)malloc((size_t)(2 * E) * sizeof(int));
    for (int e = 0; e < E; e++) {
        adj[start[eu[e]] + fill[eu[e]]++] = e;
        adj[start[ev[e]] + fill[ev[e]]++] = e;
    }

    /* Hierholzer's algorithm starting at vertex 0. */
    char* used = (char*)calloc((size_t)E, 1);
    int* ptr = (int*)calloc((size_t)n, sizeof(int));
    int* stack = (int*)malloc((size_t)(E + 2) * sizeof(int));
    int* circuit = (int*)malloc((size_t)(E + 2) * sizeof(int));
    int sp = 0, cn = 0;
    stack[sp++] = 0;
    while (sp > 0) {
        int v = stack[sp - 1];
        while (ptr[v] < deg2[v] && used[adj[start[v] + ptr[v]]]) ptr[v]++;
        if (ptr[v] < deg2[v]) {
            int e = adj[start[v] + ptr[v]];
            used[e] = 1;
            int w = (eu[e] == v) ? ev[e] : eu[e];
            stack[sp++] = w;
        } else {
            circuit[cn++] = v;
            sp--;
        }
    }

    /* Shortcut: keep first occurrence of each vertex. */
    char* visited = (char*)calloc((size_t)n, 1);
    int cnt = 0;
    for (int i = 0; i < cn && cnt < n; i++) {
        int v = circuit[i];
        if (!visited[v]) {
            visited[v] = 1;
            r->tour[cnt++] = v;
        }
    }
    /* Ensure the tour starts with 0 (it does by construction). */
    r->cost = tour_cost(pts, r->tour, n);

    free(visited);
    free(circuit);
    free(stack);
    free(ptr);
    free(used);
    free(adj);
    free(fill);
    free(start);
    free(deg2);
    free(ev);
    free(eu);
    free(pairB);
    free(pairA);
    free(O);
    free(parent);
    return r;
}

void free_tour_result(TourResult* result) {
    if (!result) return;
    free(result->tour);
    free(result);
}
