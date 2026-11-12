#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "btree.h"

#define COUNT(arr) ((int)(sizeof(arr) / sizeof((arr)[0])))
#define MAX_DEPTH 64
#define DUMP_CAP 8192

/* ---------------------------------------------------------------------------
 * Serialisation: leaf = "(k0 k1 ...)", internal = "(c0 k0 c1 k1 ... ck)",
 * empty tree = "()". Returns false for malformed nodes or buffer overflow.
 * ------------------------------------------------------------------------- */
static bool append(char* buf, size_t cap, size_t* pos, const char* s) {
    size_t len = strlen(s);
    if (*pos + len + 1 > cap) return false;
    memcpy(buf + *pos, s, len + 1);
    *pos += len;
    return true;
}

static bool dump_rec(const BTreeNode* x, char* buf, size_t cap, size_t* pos, int depth) {
    if (!x || depth > MAX_DEPTH || x->num_keys < 0) return false;
    if (x->num_keys > 0 && !x->keys) return false;
    bool leaf = x->num_children == 0;
    if (!leaf && (x->num_children != x->num_keys + 1 || !x->children)) return false;
    char num[32];
    if (!append(buf, cap, pos, "(")) return false;
    if (leaf) {
        for (int i = 0; i < x->num_keys; i++) {
            snprintf(num, sizeof num, i == 0 ? "%d" : " %d", x->keys[i]);
            if (!append(buf, cap, pos, num)) return false;
        }
    } else {
        for (int i = 0; i < x->num_children; i++) {
            if (!dump_rec(x->children[i], buf, cap, pos, depth + 1)) return false;
            if (i < x->num_keys) {
                snprintf(num, sizeof num, " %d ", x->keys[i]);
                if (!append(buf, cap, pos, num)) return false;
            }
        }
    }
    return append(buf, cap, pos, ")");
}

static bool dump_equals(const BTreeNode* root, const char* expected) {
    char buf[DUMP_CAP];
    size_t pos = 0;
    buf[0] = '\0';
    if (!dump_rec(root, buf, sizeof buf, &pos, 0)) return false;
    return strcmp(buf, expected) == 0;
}

/* ---------------------------------------------------------------------------
 * Invariant checker: key counts, strictly sorted keys, separator ranges,
 * child count = keys + 1, all leaves at the same depth. Computes height
 * (levels; empty tree = 1), node count and the in-order key list.
 * ------------------------------------------------------------------------- */
typedef struct {
    int t;
    int leaf_depth;     /* -1 until the first leaf is seen */
    int nodes;
    int* inorder;
    int cap;
    int count;
} CheckState;

static bool check_rec(const BTreeNode* x, CheckState* s, int depth, bool has_lo, int lo,
                      bool has_hi, int hi, bool is_root) {
    if (!x || depth > MAX_DEPTH) return false;
    int n = x->num_keys;
    if (n < 0 || n > 2 * s->t - 1) return false;
    if (!is_root && n < s->t - 1) return false;
    if (n > 0 && !x->keys) return false;
    s->nodes++;
    for (int i = 0; i < n; i++) {
        if (i > 0 && x->keys[i] <= x->keys[i - 1]) return false;
        if (has_lo && x->keys[i] <= lo) return false;
        if (has_hi && x->keys[i] >= hi) return false;
    }
    if (x->num_children == 0) {
        if (s->leaf_depth < 0) s->leaf_depth = depth;
        else if (s->leaf_depth != depth) return false;
        for (int i = 0; i < n; i++) {
            if (s->count >= s->cap) return false;
            s->inorder[s->count++] = x->keys[i];
        }
        return true;
    }
    if (n < 1 || x->num_children != n + 1 || !x->children) return false;
    for (int i = 0; i <= n; i++) {
        bool clo = i > 0 ? true : has_lo;
        int vlo = i > 0 ? x->keys[i - 1] : lo;
        bool chi = i < n ? true : has_hi;
        int vhi = i < n ? x->keys[i] : hi;
        if (!check_rec(x->children[i], s, depth + 1, clo, vlo, chi, vhi, false)) return false;
        if (i < n) {
            if (s->count >= s->cap) return false;
            s->inorder[s->count++] = x->keys[i];
        }
    }
    return true;
}

/* Validates root against expected in-order keys, height and node count.
   If root_keys != NULL the root must hold exactly those keys. */
static bool check_tree(const BTreeNode* root, int t, const int* expected, int expected_n,
                       int height, int nodes, const int* root_keys, int root_n) {
    if (!root) return false;
    CheckState s = { t, -1, 0, NULL, expected_n + 1, 0 };
    s.inorder = malloc((size_t)s.cap * sizeof(int));
    if (!s.inorder) return false;
    bool ok = check_rec(root, &s, 1, false, 0, false, 0, true)
        && s.count == expected_n
        && memcmp(s.inorder, expected, (size_t)expected_n * sizeof(int)) == 0
        && s.leaf_depth == height
        && s.nodes == nodes;
    free(s.inorder);
    if (ok && root_keys) {
        ok = root->num_keys == root_n
            && memcmp(root->keys, root_keys, (size_t)root_n * sizeof(int)) == 0;
    }
    return ok;
}

/* ---------------------------------------------------------------------------
 * Generator G(seed, count, mod) and set helpers.
 * ------------------------------------------------------------------------- */
static int* gen_keys(long long seed, int count, int mod) {
    int* out = malloc((size_t)count * sizeof(int));
    if (!out) return NULL;
    long long x = seed;
    for (int i = 0; i < count; i++) {
        x = (x * 1103515245LL + 12345LL) % 2147483648LL;
        out[i] = (int)((x / 65536) % mod);
    }
    return out;
}

static int cmp_int(const void* a, const void* b) {
    int x = *(const int*)a, y = *(const int*)b;
    return (x > y) - (x < y);
}

/* Returns a fresh sorted array of the distinct values of src that do not occur
   in excl (excl may be NULL); *out_n receives its length. */
static int* sorted_distinct_minus(const int* src, int n, const int* excl, int m, int* out_n) {
    int* out = malloc((size_t)(n > 0 ? n : 1) * sizeof(int));
    if (!out) return NULL;
    memcpy(out, src, (size_t)n * sizeof(int));
    qsort(out, (size_t)n, sizeof(int), cmp_int);
    int k = 0;
    for (int i = 0; i < n; i++) {
        if (k > 0 && out[k - 1] == out[i]) continue;
        bool removed = false;
        for (int j = 0; j < m && !removed; j++) removed = excl[j] == out[i];
        if (!removed) out[k++] = out[i];
    }
    *out_n = k;
    return out;
}

static bool insert_dumps_to(int t, const int* keys, int n, const char* expected) {
    BTreeNode* r = btree_insert_all(t, keys, n);
    bool ok = dump_equals(r, expected);
    free_btree(r);
    return ok;
}

static bool delete_dumps_to(int t, const int* keys, int n, const int* dels, int m,
                            const char* expected) {
    BTreeNode* r = btree_delete_all(t, keys, n, dels, m);
    bool ok = dump_equals(r, expected);
    free_btree(r);
    return ok;
}

static const int ASC10[] = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100 };

// ============================================================================
// TESTY Algorytmu A: btree_insert_all
// ============================================================================

bool test_algo_a_01_empty(void) {
    return insert_dumps_to(2, NULL, 0, "()");
}

bool test_algo_a_02_invalid_degree(void) {
    const int k[] = { 1, 2, 3 };
    BTreeNode* r = btree_insert_all(1, k, COUNT(k));
    if (r) {
        free_btree(r);
        return false;
    }
    return true;
}

bool test_algo_a_03_single_leaf(void) {
    const int k[] = { 5, 1, 3 };
    return insert_dumps_to(3, k, COUNT(k), "(1 3 5)");
}

bool test_algo_a_04_root_split(void) {
    const int k[] = { 1, 2, 3, 4 };
    return insert_dumps_to(2, k, COUNT(k), "((1) 2 (3 4))");
}

bool test_algo_a_05_duplicate_on_full_root(void) {
    const int k[] = { 1, 2, 3, 2 };
    return insert_dumps_to(2, k, COUNT(k), "(1 2 3)");
}

bool test_algo_a_06_ascending(void) {
    return insert_dumps_to(2, ASC10, COUNT(ASC10),
        "(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))");
}

bool test_algo_a_07_proactive_split(void) {
    const int k[] = { 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 };
    return insert_dumps_to(2, k, COUNT(k), "(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))");
}

bool test_algo_a_08_textbook_t3(void) {
    const int k[] = { 8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18 };
    return insert_dumps_to(3, k, COUNT(k),
        "((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))");
}

bool test_algo_a_09_invariants(void) {
    int* keys = gen_keys(7, 100, 1000);
    if (!keys) return false;
    int en = 0;
    int* expected = sorted_distinct_minus(keys, 100, NULL, 0, &en);
    BTreeNode* r = btree_insert_all(3, keys, 100);
    bool ok = expected && en == 95 && check_tree(r, 3, expected, en, 3, 28, NULL, 0);
    free_btree(r);
    free(expected);
    free(keys);
    return ok;
}

bool test_algo_a_10_stress(void) {
    int* keys = gen_keys(42, 2000, 100000);
    if (!keys) return false;
    int en = 0;
    int* expected = sorted_distinct_minus(keys, 2000, NULL, 0, &en);
    long long sum = 0;
    for (int i = 0; expected && i < en; i++) sum += expected[i];
    const int root_keys[] = { 15269 };
    BTreeNode* r = btree_insert_all(4, keys, 2000);
    bool ok = expected && en == 1937 && sum == 31779629LL
        && check_tree(r, 4, expected, en, 5, 413, root_keys, 1);
    free_btree(r);
    free(expected);
    free(keys);
    return ok;
}

// ============================================================================
// TESTY Algorytmu B: btree_delete_all
// ============================================================================

bool test_algo_b_01_delete_from_leaf(void) {
    const int k[] = { 5, 1, 3, 9, 7 };
    const int d[] = { 3 };
    return delete_dumps_to(3, k, COUNT(k), d, COUNT(d), "(1 5 7 9)");
}

bool test_algo_b_02_absent_key_unchanged(void) {
    const int k[] = { 10, 30, 20, 40 };
    const int d[] = { 15 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((10) 20 (30 40))");
}

bool test_algo_b_03_delete_all(void) {
    const int d[] = { 50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999 };
    return delete_dumps_to(2, ASC10, COUNT(ASC10), d, COUNT(d), "()");
}

bool test_algo_b_04_predecessor_preferred(void) {
    const int k[] = { 10, 20, 30, 40, 5 };
    const int d[] = { 20 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((5) 10 (30 40))");
}

bool test_algo_b_05_successor(void) {
    const int k[] = { 10, 20, 30, 40, 35 };
    const int d[] = { 20 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((10) 30 (35 40))");
}

bool test_algo_b_06_merge_children(void) {
    const int k[] = { 14, 3, 4, 11, 5, 15 };
    const int d[] = { 4 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((3 5) 11 (14 15))");
}

bool test_algo_b_07_borrow_left_first(void) {
    const int k[] = { 21, 12, 9, 10, 17, 23, 24 };
    const int d[] = { 17 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((9) 10 (12) 21 (23 24))");
}

bool test_algo_b_08_merge_right_first(void) {
    const int k[] = { 3, 4, 19, 12, 7, 15, 22, 28 };
    const int d[] = { 7 };
    return delete_dumps_to(2, k, COUNT(k), d, COUNT(d), "((3) 4 (12 15) 19 (22 28))");
}

bool test_algo_b_09_root_shrink(void) {
    const int d[] = { 10, 20 };
    return delete_dumps_to(2, ASC10, COUNT(ASC10), d, COUNT(d),
        "((30) 40 (50) 60 (70) 80 (90 100))");
}

bool test_algo_b_10_stress_invariants(void) {
    int* keys = gen_keys(9, 300, 500);
    int* dels = gen_keys(3, 250, 500);
    int en = 0;
    int* expected = (keys && dels) ? sorted_distinct_minus(keys, 300, dels, 250, &en) : NULL;
    long long sum = 0;
    for (int i = 0; expected && i < en; i++) sum += expected[i];
    const int root_keys[] = { 293 };
    BTreeNode* r = (keys && dels) ? btree_delete_all(3, keys, 300, dels, 250) : NULL;
    bool ok = expected && en == 150 && sum == 39704LL
        && check_tree(r, 3, expected, en, 4, 55, root_keys, 1);
    free_btree(r);
    free(expected);
    free(dels);
    free(keys);
    return ok;
}

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

    printf("\n--- Algorithm A: Insertion ---\n");
    RUN_TEST(test_algo_a_01_empty,                  "Test A01 (Empty)");
    RUN_TEST(test_algo_a_02_invalid_degree,         "Test A02 (Invalid Degree)");
    RUN_TEST(test_algo_a_03_single_leaf,            "Test A03 (Single Leaf)");
    RUN_TEST(test_algo_a_04_root_split,             "Test A04 (Root Split)");
    RUN_TEST(test_algo_a_05_duplicate_on_full_root, "Test A05 (Duplicate On Full Root)");
    RUN_TEST(test_algo_a_06_ascending,              "Test A06 (Ascending)");
    RUN_TEST(test_algo_a_07_proactive_split,        "Test A07 (Proactive Split)");
    RUN_TEST(test_algo_a_08_textbook_t3,            "Test A08 (Textbook t3)");
    RUN_TEST(test_algo_a_09_invariants,             "Test A09 (Invariants)");
    RUN_TEST(test_algo_a_10_stress,                 "Test A10 (Stress)");

    printf("\n--- Algorithm B: Deletion ---\n");
    RUN_TEST(test_algo_b_01_delete_from_leaf,       "Test B01 (Delete From Leaf)");
    RUN_TEST(test_algo_b_02_absent_key_unchanged,   "Test B02 (Absent Key Unchanged)");
    RUN_TEST(test_algo_b_03_delete_all,             "Test B03 (Delete All)");
    RUN_TEST(test_algo_b_04_predecessor_preferred,  "Test B04 (Predecessor Preferred)");
    RUN_TEST(test_algo_b_05_successor,              "Test B05 (Successor)");
    RUN_TEST(test_algo_b_06_merge_children,         "Test B06 (Merge Children)");
    RUN_TEST(test_algo_b_07_borrow_left_first,      "Test B07 (Borrow Left First)");
    RUN_TEST(test_algo_b_08_merge_right_first,      "Test B08 (Merge Right First)");
    RUN_TEST(test_algo_b_09_root_shrink,            "Test B09 (Root Shrink)");
    RUN_TEST(test_algo_b_10_stress_invariants,      "Test B10 (Stress Invariants)");

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
