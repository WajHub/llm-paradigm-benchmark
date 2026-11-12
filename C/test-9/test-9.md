# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a CLRS B-tree of int keys (top-down insertion and top-down deletion) in C
using the header file btree.h. The tests compare the EXACT shape of the resulting
tree, so follow the algorithm and every tie rule below precisely.

Representation (BTreeNode):
  * `keys`: strictly ascending; only the first `num_keys` entries count (the array
    may have spare capacity).
  * `children`: only the first `num_children` entries count. A leaf has
    num_children == 0 (`children` may then be NULL); an internal node with k keys
    has exactly k + 1 children.
  * The EMPTY tree is a root leaf with num_keys == 0 and num_children == 0 - it is
    NOT NULL.
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys
    (t = minimum degree).
  * Every node and every keys/children array is heap-allocated.

- Implement `btree_insert_all(t, keys, n)`: Return NULL if t < 2. Otherwise start
  from the empty tree and insert keys[0..n-1] one by one, in order, and return the
  root. `keys` may be NULL when n == 0. Insertion of key k:
  * Duplicates: if k is already in the tree, do nothing. Check membership BEFORE
    any splitting (a pre-emptive split triggered by a duplicate would change the
    shape).
  * CLRS B-TREE-INSERT (top-down, pre-emptive splitting): if the root is full
    (2t-1 keys), create a new root whose only child is the old root and split that
    child. Then descend from the root: at an internal node x find the child index i
    (the first index with k < x.keys[i], or the last child if there is none); if
    that child is full (2t-1 keys), split it first, and move to the new right half
    if k is greater than the key that moved up. Finally insert k into the leaf at
    its sorted position.
  * Split of a full node y (2t-1 keys) that is child i of x: the median key
    y.keys[t-1] (0-based) moves up into x at key position i; y keeps keys 0..t-2
    (and children 0..t-1); a new right sibling, inserted as child i+1 of x, gets
    keys t..2t-2 (and children t..2t-1).
  * Full nodes are split on the way down even if they would not overflow. This is
    NOT the bottom-up "split after overflow" variant - the two give different trees.

- Implement `btree_delete_all(t, keys, n, deletions, m)`: Return NULL if t < 2.
  Otherwise build the tree exactly like btree_insert_all(t, keys, n), then delete
  deletions[0..m-1] one by one, in order, and return the root. `keys`/`deletions`
  may be NULL when n == 0 / m == 0. Deletion of key k:
  * If k is not in the tree, the tree stays UNCHANGED. Check membership first - a
    CLRS descent for an absent key would still rebalance nodes.
  * Otherwise run delete(root, k), where delete(x, k) is:
    1. k is in x and x is a leaf: remove it from x.
    2. k == x.keys[i] and x is internal; y = children[i], z = children[i+1]:
       (2a) if y has >= t keys: let k' be the predecessor of k (the maximum key in
            y's subtree); recursively delete(y, k'), then replace x.keys[i] by k'.
            The predecessor is preferred whenever y has >= t keys, even if z also
            has >= t keys.
       (2b) else if z has >= t keys: symmetric with the successor k'' (the minimum
            key in z's subtree): delete(z, k''), then replace x.keys[i] by k''.
       (2c) else (both have t-1 keys): merge y, k and z into y (k and z are
            removed from x; y's keys become y.keys + k + z.keys and its children
            y.children + z.children; z is freed), then delete(y, k).
    3. k is not in internal node x: let c = children[i] be the child whose subtree
       must contain k (i = the first index with k < x.keys[i], or the last child).
       If c has exactly t-1 keys, fix it BEFORE descending:
       (3a) if the LEFT sibling children[i-1] exists and has >= t keys: rotate
            right - the separator x.keys[i-1] moves down to the front of c, the
            left sibling's last key moves up to replace it, and the left sibling's
            last child (if it is internal) becomes c's first child.
            Otherwise, if the RIGHT sibling children[i+1] exists and has >= t keys:
            rotate left - the separator x.keys[i] moves down to the end of c, the
            right sibling's first key moves up to replace it, and the right
            sibling's first child (if internal) becomes c's last child.
            The left sibling is always tried first.
       (3b) otherwise (no sibling has >= t keys): merge c with its RIGHT sibling
            (c + separator x.keys[i] + right sibling, into c) if a right sibling
            exists; only if c is the last child, merge it into its LEFT sibling
            (left + separator x.keys[i-1] + c, into the left sibling).
       Then continue with delete(node, k) on the (possibly merged) child that now
       covers the range of k.
  * After each deletion, if the root has no keys but has a child, that child
    becomes the new root (the height shrinks) and the old root is freed.
  * Deleting the last key leaves the empty tree (a root leaf with no keys).

- Implement `free_btree`: Free the whole tree (every node and its keys/children
  arrays). `free_btree(NULL)` is a no-op.

Ownership: the returned tree is owned by the caller and released with
`free_btree`. The input arrays must not be modified.

Complexity: O(t * log_t n) per operation; up to 2000 keys are inserted.

Constraints:
  - No memory leaks (verified by valgrind), including nodes removed by merges and
    root shrinking.
  - All functions must handle their edge cases without crashing.
```
