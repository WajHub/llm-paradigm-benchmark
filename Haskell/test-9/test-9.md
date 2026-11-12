# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a B-tree with minimum degree t (exactly as in CLRS: single-pass
top-down insertion and single-pass top-down deletion) in Haskell in the module
BTree (file BTree.hs). The module already defines
  data BNode = BNode { nodeKeys :: [Int], nodeChildren :: [BNode] }
implement insertAll and deleteAll. Build the trees persistently (pure
functions that return new nodes); the tests compare the EXACT SHAPE of the
resulting tree, so every rule below matters.

Representation:
  * nodeKeys is strictly ascending. A leaf has nodeChildren == []. An internal
    node with k keys has exactly k+1 children; all keys in children[i] lie
    between keys[i-1] and keys[i].
  * The empty tree is a root leaf with no keys: BNode [] [] (NOT Nothing).
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.

- Implement `insertAll :: Int -> [Int] -> Maybe BNode` (`insertAll t keys`):
  Nothing if t < 2. Otherwise start from the empty tree and insert the keys
  one by one, in list order, with the insertion below; return the root.

- Implement `deleteAll :: Int -> [Int] -> [Int] -> Maybe BNode`
  (`deleteAll t keys deletions`): Nothing if t < 2. Otherwise build the tree
  exactly like `insertAll t keys`, then delete the keys of `deletions` one by
  one, in list order, with the deletion below; return the root.

Insertion of k (CLRS B-TREE-INSERT, top-down, pre-emptive splitting):
  0. If k is already in the tree, do nothing. Check membership BEFORE any
     splitting (a split triggered by a duplicate would change the shape).
  1. If the root is full (2t-1 keys): create a new root with no keys whose only
     child is the old root, and split that child (rule below).
  2. Descend from the root: at an internal node x find the child index i =
     the first index with k < keys[i] (or the last child if there is none).
     If children[i] is full (2t-1 keys), split it first, and then go to the
     right half if k is greater than the key that moved up into x.
     Nodes are split on the way down even if they would not overflow -- this is
     NOT the bottom-up "split on overflow" variant (it gives different trees).
  3. At the leaf, insert k at its sorted position.
  Split of a full node y (2t-1 keys) that is child i of x: the median key
  y.keys[t-1] (0-based) moves up into x at key position i; y keeps keys
  0..t-2 (and children 0..t-1), a new right sibling z placed at child
  position i+1 gets keys t..2t-2 (and children t..2t-1).

Deletion of k:
  0. If k is not in the tree, the tree is returned UNCHANGED. Check
     membership first (a CLRS descent for an absent key would still
     rebalance nodes).
  Otherwise run delete(root, k):
  1. k is in node x and x is a leaf: remove k from x.
  2. k = x.keys[i] in internal node x; y = children[i] (left of k),
     z = children[i+1] (right of k):
     (2a) if y has >= t keys: k' = predecessor of k (the maximum key in y's
          subtree); recursively delete(y, k'), then replace x.keys[i] by k'.
          The predecessor is preferred whenever y has >= t keys, even if z
          also has >= t keys.
     (2b) else if z has >= t keys: symmetric with the successor k'' (the
          minimum key in z's subtree): delete(z, k''), replace x.keys[i] by k''.
     (2c) else (both have t-1 keys): merge y, k and z into one node in place
          of y (k and z are removed from x), then delete(merged node, k).
  3. k is not in internal node x: let c = children[i] be the child whose
     subtree must contain k. If c has exactly t-1 keys, fix it BEFORE
     descending:
     (3a) if the LEFT sibling children[i-1] exists and has >= t keys: rotate
          right -- the separator x.keys[i-1] moves down to the front of c,
          the left sibling's last key moves up to replace it in x, and the
          left sibling's last child (if any) becomes c's first child.
          Otherwise, if the RIGHT sibling children[i+1] exists and has >= t
          keys: rotate left (symmetric: separator x.keys[i] moves to the end
          of c, the right sibling's first key moves up, its first child (if
          any) becomes c's last child). The LEFT sibling is tried first.
     (3b) otherwise (no sibling has >= t keys): merge c with its RIGHT
          sibling (c, separator x.keys[i], right sibling -> one node at
          position i) if a right sibling exists; only if c is the last child,
          merge it into its LEFT sibling (left sibling, x.keys[i-1], c -> one
          node at position i-1).
     Then recurse into the (possibly merged) child that now contains the
     range of k.
  After each deletion, if the root has no keys but has a child, that child
  becomes the new root (the height shrinks). Deleting the last key gives the
  empty tree BNode [] [].

Requirements:
  - O(t * log_t n) per operation; tests insert up to 2000 keys.
  - Only the libraries shipped with GHC (base, containers, array).
```
