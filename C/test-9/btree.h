#ifndef BTREE_H
#define BTREE_H

/*
 * CLRS B-tree of int keys with minimum degree t (t >= 2).
 * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.
 *
 * keys:         strictly ascending; only the first num_keys entries count
 *               (the array may be larger, i.e. have spare capacity).
 * children:     only the first num_children entries count; may be NULL for a leaf.
 * num_children: 0 for a leaf, otherwise num_keys + 1.
 *
 * The empty tree is a root leaf with num_keys == 0 (not NULL).
 * Every node and every keys/children array is heap-allocated.
 */
typedef struct BTreeNode {
    int* keys;
    int num_keys;
    struct BTreeNode** children;
    int num_children;
} BTreeNode;

/* Starts from the empty tree and inserts keys[0..n-1] in order (top-down CLRS
   insertion; duplicates ignored). Returns the root, or NULL if t < 2.
   Caller frees with free_btree. */
BTreeNode* btree_insert_all(int t, const int* keys, int n);

/* Builds the tree exactly like btree_insert_all(t, keys, n), then deletes
   deletions[0..m-1] in order (top-down CLRS deletion; absent keys ignored).
   Returns the root, or NULL if t < 2. Caller frees with free_btree. */
BTreeNode* btree_delete_all(int t, const int* keys, int n, const int* deletions, int m);

/* Frees the whole tree (all nodes and arrays). Accepts NULL. */
void free_btree(BTreeNode* root);

#endif
