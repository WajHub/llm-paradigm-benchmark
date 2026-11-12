#include "btree.h"
#include <stdlib.h>

BTreeNode* btree_insert_all(int t, const int* keys, int n) {
    (void)t; (void)keys; (void)n;
    return NULL;
}

BTreeNode* btree_delete_all(int t, const int* keys, int n, const int* deletions, int m) {
    (void)t; (void)keys; (void)n; (void)deletions; (void)m;
    return NULL;
}

void free_btree(BTreeNode* root) {
    (void)root;
}
