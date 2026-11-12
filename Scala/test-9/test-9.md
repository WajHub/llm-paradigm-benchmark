# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement the exact CLRS B-tree with minimum degree t (single-pass top-down
insertion and single-pass top-down deletion) in Scala 2.11 in the object BTree
(file BTree.scala). The object already defines the node type; implement
insertAll and deleteAll. The tests compare the EXACT SHAPE of the resulting
tree, so every rule below (including which sibling is preferred) matters.

Node representation:
  * case class Node(keys: Vector[Int], children: Vector[Node])
  * keys are strictly ascending. A leaf has children == Vector.empty; an
    internal node with k keys has exactly k + 1 children.
  * The EMPTY tree is a root leaf with no keys: Node(Vector(), Vector())
    (it is NOT None).
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.
  * Persistent (immutable) rebuilding or internal mutation are both fine; only
    the returned structure matters.

- Implement `insertAll(t: Int, keys: Vector[Int]): Option[Node]`:
  * None if t < 2.
  * Otherwise start from the empty tree, insert the keys one by one in the given
    order and return Some(root).

- Implement `deleteAll(t: Int, keys: Vector[Int], deletions: Vector[Int]): Option[Node]`:
  * None if t < 2.
  * Otherwise build the tree exactly like insertAll(t, keys), then delete every
    key of deletions in the given order, and return Some(root).

Insertion of key k (CLRS B-TREE-INSERT, top-down, pre-emptive splitting):
  0. DUPLICATES: if k is already in the tree, do nothing at all. Check membership
     BEFORE any splitting (a split triggered by a duplicate would change the shape).
  1. If the root is full (2t-1 keys): create a new root with no keys whose only
     child is the old root, and split that child (see Split). The tree grows by
     one level.
  2. Descend from the root: at an internal node x let i be the first index with
     k < x.keys(i) (or i = x.keys.length if there is none). If child i is full
     (2t-1 keys), split it first; then, if k is greater than the key that moved
     up into x at position i, continue into child i+1, otherwise child i.
  3. At the leaf, insert k at its sorted position.
  Split of a full node y (2t-1 keys) that is child i of x:
    the median y.keys(t-1) (0-based) moves up into x.keys at position i;
    y keeps keys 0..t-2 (and children 0..t-1);
    a new right sibling, placed at x.children(i+1), gets keys t..2t-2 (and
    children t..2t-1).
  Nodes are split on the way down even if the insertion would not overflow
  them. Do NOT implement the bottom-up "split on overflow" variant; it gives a
  different tree.

Deletion of key k:
  0. If k is not in the tree, the tree is UNCHANGED. Check membership first (a
     CLRS descent for an absent key would still rebalance nodes).
  Otherwise run delete(root, k):
  1. k is in node x and x is a leaf: remove k from x.
  2. k = x.keys(i) in an internal node x; y = x.children(i) (left child),
     z = x.children(i+1) (right child):
     (2a) if y has >= t keys: k' = predecessor of k = the maximum key in y's
          subtree; recursively delete(y, k'), then replace x.keys(i) by k'.
          The predecessor is preferred whenever y has >= t keys, even if z
          also has >= t keys.
     (2b) else if z has >= t keys: k'' = successor = the minimum key in z's
          subtree; recursively delete(z, k''), then replace x.keys(i) by k''.
     (2c) else (both have exactly t-1 keys): merge y, k and z into y
          (y.keys ++ [k] ++ z.keys, y.children ++ z.children), remove k and z
          from x, then recursively delete(y, k).
  3. k is not in the internal node x: let c = x.children(i) be the child whose
     subtree must contain k (i = number of keys of x smaller than k). If c has
     exactly t-1 keys, fix it BEFORE descending:
     (3a) if the LEFT sibling x.children(i-1) exists and has >= t keys, rotate
          right: the separator x.keys(i-1) moves down to the front of c's keys,
          the left sibling's last key moves up to replace x.keys(i-1), and the
          left sibling's last child (if it is internal) becomes c's first child.
          Otherwise, if the RIGHT sibling x.children(i+1) exists and has >= t
          keys, rotate left (symmetric: separator x.keys(i) moves to the end of
          c, the right sibling's first key replaces it, its first child becomes
          c's last child). The LEFT sibling is always tried first.
     (3b) otherwise (no sibling with >= t keys): if c has a right sibling, merge
          c, separator x.keys(i) and the right sibling into c; only if c is the
          LAST child, merge the left sibling, separator x.keys(i-1) and c into the
          left sibling.
     Then recurse into the (possibly merged) child that now covers k.
  After each deletion: if the root has no keys but has a child, that child
  becomes the new root (the height shrinks by one). Deleting the last key
  leaves the empty tree Node(Vector(), Vector()).

Notes:
  - Inputs contain up to 2000 keys; each operation must be O(t * log_t n).
  - Keys are arbitrary Ints; keys and deletions may contain duplicates and
    keys that are absent.
  - Use Scala 2.11 syntax and standard library only (no Scala 3 syntax, no
    2.12/2.13-only APIs such as LazyList or .to(List)).
```
