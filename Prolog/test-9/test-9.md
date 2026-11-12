# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a B-tree index (CLRS, minimum degree T) with top-down insertion and
top-down deletion in SWI-Prolog in the module btree (file btree.pl).
Implement btree_insert_all/3 and btree_delete_all/4.

Tree representation: node(Keys, Children)
  * Keys is a proper list of integers in strictly ascending order.
  * Children is [] for a leaf; for an internal node with k keys it is a list of
    exactly k+1 node/2 terms (Children[i] holds the keys between Keys[i-1] and
    Keys[i]).
  * The empty tree is node([], []) - a root leaf without keys (NOT none).
  * Every node holds at most 2T-1 keys; every non-root node at least T-1 keys.
The tests compare the EXACT shape of the resulting tree (every node's keys and
children), so the algorithms below must be followed precisely. Indices are 0-based.

- Implement `btree_insert_all(+T, +Keys, -Tree)`: start from the empty tree and
  insert the integers of Keys one by one, in order. Tree = none if T < 2.
  * Duplicates: if the key is already in the tree, do nothing. Check membership
    BEFORE any splitting (a pre-emptive split caused by a duplicate would change
    the shape).
  * Insert (CLRS B-TREE-INSERT, single pass, top-down): if the root is full (2T-1
    keys), create a new root with no keys whose only child is the old root and split
    that child. Then descend from the root: at an internal node let i be the first
    index with K < Keys[i] (or the last child if there is none); if Children[i] is
    full (2T-1 keys), split it first, and then continue into the right half if K is
    greater than the key that moved up, otherwise into the left half. Finally insert
    K into the leaf at its sorted position.
  * Split of a full node Y (2T-1 keys) that is child i of X: the median key
    Y.Keys[T-1] moves up into X at key position i; Y keeps keys 0..T-2 (and, if
    internal, children 0..T-1); a new right sibling, inserted as child i+1 of X, gets
    keys T..2T-2 (and children T..2T-1).
  * Nodes are split on the way down even if the insertion would not overflow them.
    This is NOT the bottom-up "split after overflow" variant (it gives different
    trees).

- Implement `btree_delete_all(+T, +Keys, +Deletions, -Tree)`: build the tree exactly
  like btree_insert_all(T, Keys, _), then delete the keys of Deletions one by one,
  in order. Tree = none if T < 2.
  * If the key is not in the tree, the tree is left UNCHANGED (check membership
    first - a CLRS descent for an absent key would still rebalance nodes).
  * Otherwise run delete(Root, K):
    1. K is in node X and X is a leaf: remove K from X.
    2. K = X.Keys[i] in an internal node X; let Y = Children[i] (left) and
       Z = Children[i+1] (right):
       (2a) if Y has >= T keys: let K' be the predecessor of K (the maximum key in
            Y's subtree); recursively delete(Y, K'), then replace X.Keys[i] by K'.
            The predecessor is preferred whenever Y has >= T keys, even if Z also has.
       (2b) else if Z has >= T keys: symmetric with the successor K'' (the minimum key
            in Z's subtree): recursively delete(Z, K''), replace X.Keys[i] by K''.
       (2c) else (both have T-1 keys): merge Y, K and Z into one node (Y's keys, K,
            Z's keys; Y's children followed by Z's children) at position i, remove
            K and Z from X, then recursively delete K from the merged node.
    3. K is not in the internal node X: let C = Children[i] be the child whose
       subtree must contain K (i = first index with K < Keys[i], or the last child).
       If C has exactly T-1 keys, fix it BEFORE descending:
       (3a) if the LEFT sibling Children[i-1] exists and has >= T keys, rotate right:
            the separator X.Keys[i-1] moves down to the front of C, the left
            sibling's last key moves up to replace it, and the left sibling's last
            child (if it is internal) becomes C's first child. Otherwise, if the
            RIGHT sibling Children[i+1] exists and has >= T keys, rotate left
            (symmetric: separator X.Keys[i] moves to the end of C, the right
            sibling's first key replaces it, its first child becomes C's last child).
            The left sibling is always tried first.
       (3b) otherwise (no sibling with >= T keys) merge C with its RIGHT sibling (C's
            keys, separator X.Keys[i], right sibling's keys) if C has a right
            sibling; only if C is the last child, merge it into its LEFT sibling
            (left sibling's keys, separator X.Keys[i-1], C's keys).
       Then continue the deletion in the (possibly merged) child that now contains
       the range of K.
  * After each deletion, if the root has no keys but has a child, that child becomes
    the new root (the height shrinks). Deleting the last key gives the empty tree
    node([], []).

Constraints:
  - Both predicates are deterministic (a single answer).
  - Results are compared with ==: keys are integers in plain lists, leaves have
    Children = [].
  - Tests insert up to 2000 keys; each operation must be O(T log n) (no rebuilding
    of the whole tree per operation).
```
