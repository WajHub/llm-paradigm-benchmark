#include <stdlib.h>
#include "btree.h"

static BTreeNode* new_node(int t) {
    BTreeNode* n = (BTreeNode*)calloc(1, sizeof(BTreeNode));
    if (!n) return NULL;
    n->keys = (int*)calloc((size_t)(2 * t), sizeof(int));
    n->children = (BTreeNode**)calloc((size_t)(2 * t + 1), sizeof(BTreeNode*));
    n->num_keys = 0;
    n->num_children = 0;
    return n;
}

static void free_shell(BTreeNode* n) {
    if (!n) return;
    free(n->keys);
    free(n->children);
    free(n);
}

static int contains(const BTreeNode* x, int k) {
    while (x) {
        int i = 0;
        while (i < x->num_keys && k > x->keys[i]) i++;
        if (i < x->num_keys && x->keys[i] == k) return 1;
        if (x->num_children == 0) return 0;
        x = x->children[i];
    }
    return 0;
}

/* Split full child i of x (x is not full). */
static void split_child(BTreeNode* x, int i, int t) {
    BTreeNode* y = x->children[i];
    BTreeNode* z = new_node(t);
    int j;

    z->num_keys = t - 1;
    for (j = 0; j < t - 1; j++) z->keys[j] = y->keys[j + t];
    if (y->num_children > 0) {
        z->num_children = t;
        for (j = 0; j < t; j++) z->children[j] = y->children[j + t];
        y->num_children = t;
    }
    y->num_keys = t - 1;

    for (j = x->num_children - 1; j >= i + 1; j--) x->children[j + 1] = x->children[j];
    x->children[i + 1] = z;
    x->num_children++;

    for (j = x->num_keys - 1; j >= i; j--) x->keys[j + 1] = x->keys[j];
    x->keys[i] = y->keys[t - 1];
    x->num_keys++;
}

static void insert_nonfull(BTreeNode* x, int k, int t) {
    for (;;) {
        if (x->num_children == 0) {
            int i = x->num_keys;
            while (i > 0 && x->keys[i - 1] > k) {
                x->keys[i] = x->keys[i - 1];
                i--;
            }
            x->keys[i] = k;
            x->num_keys++;
            return;
        }
        int i = 0;
        while (i < x->num_keys && k > x->keys[i]) i++;
        if (x->children[i]->num_keys == 2 * t - 1) {
            split_child(x, i, t);
            if (k > x->keys[i]) i++;
        }
        x = x->children[i];
    }
}

static void insert_key(BTreeNode** rootp, int k, int t) {
    if (contains(*rootp, k)) return;
    if ((*rootp)->num_keys == 2 * t - 1) {
        BTreeNode* s = new_node(t);
        s->children[0] = *rootp;
        s->num_children = 1;
        split_child(s, 0, t);
        *rootp = s;
    }
    insert_nonfull(*rootp, k, t);
}

static int max_key(BTreeNode* x) {
    while (x->num_children > 0) x = x->children[x->num_children - 1];
    return x->keys[x->num_keys - 1];
}

static int min_key(BTreeNode* x) {
    while (x->num_children > 0) x = x->children[0];
    return x->keys[0];
}

static void remove_key_at(BTreeNode* x, int i) {
    int j;
    for (j = i; j < x->num_keys - 1; j++) x->keys[j] = x->keys[j + 1];
    x->num_keys--;
}

/* Merge child i+1 and separator x.keys[i] into child i. */
static void merge_children(BTreeNode* x, int i) {
    BTreeNode* y = x->children[i];
    BTreeNode* z = x->children[i + 1];
    int ynk = y->num_keys;
    int base = y->num_children;
    int j;

    y->keys[ynk] = x->keys[i];
    for (j = 0; j < z->num_keys; j++) y->keys[ynk + 1 + j] = z->keys[j];
    y->num_keys = ynk + 1 + z->num_keys;

    if (base > 0) {
        for (j = 0; j < z->num_children; j++) y->children[base + j] = z->children[j];
        y->num_children = base + z->num_children;
    }

    free_shell(z);

    for (j = i; j < x->num_keys - 1; j++) x->keys[j] = x->keys[j + 1];
    x->num_keys--;
    for (j = i + 1; j < x->num_children - 1; j++) x->children[j] = x->children[j + 1];
    x->num_children--;
}

/* Move separator x.keys[ci-1] down into children[ci]; left's last key up. */
static void rotate_right(BTreeNode* x, int ci) {
    BTreeNode* c = x->children[ci];
    BTreeNode* left = x->children[ci - 1];
    int j;

    for (j = c->num_keys; j > 0; j--) c->keys[j] = c->keys[j - 1];
    c->keys[0] = x->keys[ci - 1];
    x->keys[ci - 1] = left->keys[left->num_keys - 1];
    left->num_keys--;
    c->num_keys++;

    if (c->num_children > 0) {
        for (j = c->num_children; j > 0; j--) c->children[j] = c->children[j - 1];
        c->children[0] = left->children[left->num_children - 1];
        left->num_children--;
        c->num_children++;
    }
}

/* Move separator x.keys[ci] down into children[ci]; right's first key up. */
static void rotate_left(BTreeNode* x, int ci) {
    BTreeNode* c = x->children[ci];
    BTreeNode* right = x->children[ci + 1];
    int j;

    c->keys[c->num_keys] = x->keys[ci];
    c->num_keys++;
    x->keys[ci] = right->keys[0];
    for (j = 0; j < right->num_keys - 1; j++) right->keys[j] = right->keys[j + 1];
    right->num_keys--;

    if (c->num_children > 0) {
        c->children[c->num_children] = right->children[0];
        c->num_children++;
        for (j = 0; j < right->num_children - 1; j++) right->children[j] = right->children[j + 1];
        right->num_children--;
    }
}

static void delete_key(BTreeNode* x, int k, int t) {
    for (;;) {
        int i = 0;
        while (i < x->num_keys && k > x->keys[i]) i++;

        if (i < x->num_keys && x->keys[i] == k) {
            if (x->num_children == 0) {
                remove_key_at(x, i);
                return;
            }
            BTreeNode* y = x->children[i];
            BTreeNode* z = x->children[i + 1];
            if (y->num_keys >= t) {
                int kp = max_key(y);
                delete_key(y, kp, t);
                x->keys[i] = kp;
                return;
            } else if (z->num_keys >= t) {
                int kpp = min_key(z);
                delete_key(z, kpp, t);
                x->keys[i] = kpp;
                return;
            } else {
                merge_children(x, i);
                x = y;
                continue;
            }
        }

        if (x->num_children == 0) return;

        int ci = i;
        BTreeNode* c = x->children[ci];
        if (c->num_keys == t - 1) {
            BTreeNode* left = (ci > 0) ? x->children[ci - 1] : NULL;
            BTreeNode* right = (ci < x->num_keys) ? x->children[ci + 1] : NULL;
            if (left && left->num_keys >= t) {
                rotate_right(x, ci);
            } else if (right && right->num_keys >= t) {
                rotate_left(x, ci);
            } else if (right) {
                merge_children(x, ci);
            } else {
                merge_children(x, ci - 1);
                ci--;
            }
            c = x->children[ci];
        }
        x = c;
    }
}

static void free_tree_rec(BTreeNode* n) {
    int i;
    if (!n) return;
    for (i = 0; i < n->num_children; i++) free_tree_rec(n->children[i]);
    free_shell(n);
}

void free_btree(BTreeNode* root) {
    free_tree_rec(root);
}

BTreeNode* btree_insert_all(int t, const int* keys, int n) {
    BTreeNode* root;
    int i;
    if (t < 2) return NULL;
    root = new_node(t);
    if (!root) return NULL;
    for (i = 0; i < n; i++) insert_key(&root, keys[i], t);
    return root;
}

BTreeNode* btree_delete_all(int t, const int* keys, int n, const int* deletions, int m) {
    BTreeNode* root;
    int i;
    if (t < 2) return NULL;
    root = btree_insert_all(t, keys, n);
    if (!root) return NULL;
    for (i = 0; i < m; i++) {
        int k = deletions[i];
        if (!contains(root, k)) continue;
        delete_key(root, k, t);
        while (root->num_keys == 0 && root->num_children > 0) {
            BTreeNode* old = root;
            root = root->children[0];
            free_shell(old);
        }
    }
    return root;
}
