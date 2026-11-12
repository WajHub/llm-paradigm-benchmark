# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a B-tree index (CLRS B-tree with minimum degree t: single-pass top-down
insertion and single-pass top-down deletion) in GNU Smalltalk in the class BTreeImpl
(file BTreeImpl.st), which subclasses the abstract class BTree. The node class BTreeNode
is already defined in BTree.st; implement insertAll:degree: and deleteAll:from:degree:.
Put the solution in BTreeImpl.st.

Node representation (BTreeNode, created with `BTreeNode keys: k children: c`; it also
has the setters keys: and children: and the test isLeaf):
  * keys answers a sequenceable collection of Integers in strictly ascending order.
  * children answers a sequenceable collection of BTreeNodes: EMPTY for a leaf (not
    nil); an internal node with k keys has exactly k + 1 children. Child i (1-based)
    holds the keys between keys at: i - 1 and keys at: i.
  * Use OrderedCollection (or Array) for both; the tests only read them.
  * The EMPTY tree is a root leaf with no keys and no children (NOT nil).
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.
  * The tests compare the EXACT shape of the resulting tree (keys of every node and
    the parent/child structure), so follow the algorithm below exactly.

- Implement `insertAll: keys degree: t`: answer nil if t < 2. Otherwise start from the
  empty tree, insert the keys of the collection one by one in their given order
  (algorithm below) and answer the root BTreeNode.

- Implement `deleteAll: deletions from: keys degree: t`: answer nil if t < 2. Otherwise
  build the tree exactly like `insertAll: keys degree: t`, then delete every key of
  `deletions` in its given order (algorithm below) and answer the (current) root.

Insertion of key k (CLRS B-TREE-INSERT, top-down, pre-emptive splitting):
  0. Duplicates: if k is already in the tree, do NOTHING. Check membership BEFORE any
     splitting (a pre-emptive split triggered by a duplicate would change the shape).
  1. If the root is full (2t-1 keys): create a new root with no keys whose only child
     is the old root, and split that child (below). The tree grows only here.
  2. Descend from the root. At an internal node x let i be the first child position
     whose key is greater than k (i.e. child i with keys at: i - 1 < k < keys at: i;
     the last child if k is greater than all keys). If that child is full (2t-1
     keys), split it FIRST, then continue into the right half of the split if k is
     greater than the key that moved up into x, otherwise into the left half.
     Nodes are split on the way down even if inserting would not overflow them (this
     is NOT the bottom-up "split on overflow" variant; the two give different trees).
  3. At the leaf, insert k in sorted position.
  Split of a full node y (2t-1 keys) that is the child at position i of x (1-based):
  the median key (y keys at: t) moves up into x as the new key at position i; y keeps
  keys 1..t-1 (and, if internal, children 1..t); a new right sibling, inserted into x
  as child i + 1, gets keys t+1..2t-1 (and children t+1..2t).

Deletion of key k (CLRS top-down, single pass):
  0. If k is NOT in the tree, the tree is left completely unchanged (check membership
     first - a CLRS descent for an absent key would still rebalance nodes).
  Otherwise run delete(root, k), where delete(x, k) is:
  1. k is in node x and x is a leaf: remove k from x.
  2. k = x keys at: i, x internal, left child y = child i, right child z = child i + 1:
     (2a) if y has >= t keys: let k' be the predecessor of k (the maximum key in y's
          subtree: follow the last child down to a leaf, take its last key);
          recursively delete(y, k'), then replace (x keys at: i) by k'. The
          predecessor is preferred whenever y has >= t keys, even if z also has.
     (2b) else if z has >= t keys: symmetric with the successor k'' (minimum key in
          z's subtree): delete(z, k''), then replace (x keys at: i) by k''.
     (2c) else (both have t-1 keys): merge y, the key k and z into y (k and z are
          removed from x; y's keys = y keys, k, z keys; y's children = y children,
          z children), then recursively delete(y, k).
  3. k is not in the internal node x: let c = child i of x be the child whose subtree
     must contain k (same child choice as in insertion). If c has exactly t-1 keys,
     fix it BEFORE descending:
     (3a) if the LEFT sibling (child i - 1) exists and has >= t keys: rotate right -
          the separator (x keys at: i - 1) moves down to the FRONT of c, the left
          sibling's LAST key moves up to replace it, and the left sibling's last child
          (if it is internal) becomes c's first child.
          Otherwise, if the RIGHT sibling (child i + 1) exists and has >= t keys:
          rotate left - the separator (x keys at: i) moves down to the END of c, the
          right sibling's FIRST key moves up to replace it, and the right sibling's
          first child (if internal) becomes c's last child.
          The left sibling is always tried first.
     (3b) otherwise (every existing sibling has t-1 keys): merge c with its RIGHT
          sibling (c, separator, right sibling into c) if a right sibling exists;
          only if c is the LAST child, merge it into its LEFT sibling (left sibling,
          separator, c into the left sibling).
     Then recursively delete(n, k) where n is the node that now covers k's range
     (c, or the merged node).
  After each deletion: if the root has no keys but has a child, that child becomes the
  new root (the height shrinks). Deleting the last key leaves the empty tree (a root
  leaf with no keys).

Constraints:
  - Absence (nil) only for t < 2; an empty key list gives the empty tree.
  - O(t * log_t n) per operation; the tests insert up to 2000 keys and delete hundreds.
  - Keys are Integers; the input collections must not be modified.
```
