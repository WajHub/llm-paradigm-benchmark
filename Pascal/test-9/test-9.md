# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a CLRS B-tree with minimum degree t (top-down insertion and top-down deletion)
in Free Pascal in the unit btree (file btree.pas). The unit already declares the node
type and the three routines; keep the interface unchanged and implement BTreeInsertAll,
BTreeDeleteAll and FreeBTree in the implementation section. The tests compare the EXACT
shape of the resulting tree, so follow the algorithm below precisely.

Node representation:
  * PBTreeNode = ^TBTreeNode; TBTreeNode = record Keys: TIntArray; Children:
    TBTreeNodeArray; end;
  * Keys are strictly ascending. A leaf has Length(Children) = 0. An internal node with
    k keys has exactly k + 1 children (Children[i] holds the keys between Keys[i-1] and
    Keys[i]). Length(Keys) / Length(Children) must be exact (no spare capacity).
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.
  * The empty tree is a root LEAF WITH NO KEYS (a non-nil node), not nil.

- Implement `BTreeInsertAll(MinDegree: LongInt; const Keys: TIntArray): PBTreeNode`:
  return nil if MinDegree < 2. Otherwise start from the empty tree and insert Keys[0],
  Keys[1], ... one by one, in order, and return the root.
  Insertion of k (CLRS B-TREE-INSERT, single pass, top-down):
  * Duplicates: if k is already in the tree, do nothing. Check membership BEFORE any
    splitting (a pre-emptive split triggered by a duplicate would change the shape).
  * If the root is full (2t-1 keys): create a new root with no keys whose only child is
    the old root, and split that child.
  * Then descend from the root: at an internal node x find the child index i = the first
    index with k < x.Keys[i] (or the last child if there is none). If that child is full
    (2t-1 keys), split it first, and then go to the right half if k is greater than the
    key that moved up into x. Finally insert k into the leaf at its sorted position.
  * Split of a full node y (2t-1 keys) that is child i of x: the median key y.Keys[t-1]
    (0-based) moves up into x at key position i; y keeps keys 0..t-2 (and children
    0..t-1); a new right sibling z, inserted as child i+1 of x, gets keys t..2t-2 (and
    children t..2t-1).
  * Full nodes are split on the way down even if the new key would not make them
    overflow. This is NOT the bottom-up "split on overflow" variant (the two give
    different trees).

- Implement `BTreeDeleteAll(MinDegree: LongInt; const Keys, Deletions: TIntArray):
  PBTreeNode`: return nil if MinDegree < 2. Otherwise build the tree exactly like
  BTreeInsertAll(MinDegree, Keys), then delete Deletions[0], Deletions[1], ... in order,
  and return the root.
  Deletion of k:
  * If k is not in the tree, the tree is left UNCHANGED. Check membership first (a CLRS
    descent for an absent key would still rebalance nodes).
  * Otherwise run delete(root, k) (CLRS B-TREE-DELETE, single pass, top-down):
    1. k is in node x and x is a leaf: remove it from x.
    2. k = x.Keys[i] in an internal node x; let y = x.Children[i] (left) and
       z = x.Children[i+1] (right):
       2a. if y has >= t keys: let k' = the predecessor of k (the maximum key in y's
           subtree); recursively delete k' starting at y, then replace x.Keys[i] by k'.
           The predecessor is preferred whenever y has >= t keys, even if z also has.
       2b. else if z has >= t keys: symmetric with the successor k'' (the minimum key in
           z's subtree): delete k'' starting at z, then replace x.Keys[i] by k''.
       2c. else (both have t-1 keys): merge y, k and z into y (k and z are removed from
           x; z's keys and children are appended to y after k), free z, then delete k
           starting at y.
    3. k is not in internal node x: let c = x.Children[i] be the child whose subtree must
       contain k (i = first index with k < x.Keys[i], or the last child). If c has
       exactly t-1 keys, fix it BEFORE descending:
       3a. if the LEFT sibling x.Children[i-1] exists and has >= t keys: rotate right -
           the separator x.Keys[i-1] moves down to the front of c, the left sibling's
           last key moves up to replace it, and the left sibling's last child (if any)
           becomes c's first child.
           Otherwise, if the RIGHT sibling x.Children[i+1] exists and has >= t keys:
           rotate left - the separator x.Keys[i] moves down to the end of c, the right
           sibling's first key moves up to replace it, and the right sibling's first
           child (if any) becomes c's last child.
           The left sibling is always tried first.
       3b. otherwise (no sibling has >= t keys): if c has a right sibling, merge c, the
           separator x.Keys[i] and the right sibling into c; only if c is the LAST child,
           merge the left sibling, the separator x.Keys[i-1] and c into the left sibling.
       Then continue the deletion in the (possibly merged) child that now covers k.
  * After each deletion: if the root has no keys but has a child, that child becomes the
    new root (the old root node is freed; the height shrinks).
  * Deleting the last key yields the empty tree (a root leaf with no keys), not nil.

- Implement `FreeBTree(var Root: PBTreeNode)`: free the WHOLE tree (every node,
  recursively) and set Root to nil. FreeBTree(nil) is a no-op.

Memory:
  - Every node is allocated with New and owned by the tree; the caller frees the whole
    tree with FreeBTree. Nodes removed during deletion (merged siblings, the old root on
    a height shrink) must be disposed by your code. The program runs under valgrind and
    must not leak.
  - The input arrays Keys and Deletions must not be modified. Note that `const` on a
    dynamic array parameter does not protect its elements and assigning one dynamic
    array variable to another shares storage: copy (Copy(...)) before modifying.

Pascal notes:
  - Pascal is case-insensitive: the parameter Keys has the same name as the record field
    Keys. Always access fields qualified (Node^.Keys) and do NOT use `with Node^ do`.
    Do not name anything Result except the function result.
  - Up to 2000 keys are inserted; each operation must be O(t * log_t n).
```
