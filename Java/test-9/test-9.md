# Test 9

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement the CLRS B-tree with minimum degree t (single-pass top-down insertion and
single-pass top-down deletion) in Java in the class BTreeImpl (file BTreeImpl.java),
which extends the abstract class BTree. The base class already defines the node type
BTree.Node; implement insertAll and deleteAll. The tests compare the EXACT SHAPE of the
resulting tree, so follow the algorithm below precisely, including every tie rule.

Node representation: new Node(keys, children)
  * keys: the node's keys, strictly ascending (List<Integer>, non-null).
  * children: an EMPTY list (non-null) for a leaf; for an internal node with k keys
    exactly k+1 children, where every key of children[i] lies between keys[i-1] and keys[i].
  * The empty tree is a root leaf with no keys (new Node with two empty lists) - it is
    NOT null.
  * Every node holds at most 2t-1 keys; every non-root node at least t-1 keys.

- Implement `Node insertAll(int t, int[] keys)`: start from the empty tree, insert the
  keys one by one in array order, and return the root. Return null if t < 2.
- Implement `Node deleteAll(int t, int[] keys, int[] deletions)`: build the tree exactly
  like insertAll(t, keys), then delete the keys of `deletions` one by one in array order,
  and return the root. Return null if t < 2.
- Input arrays must not be modified.

Insert (CLRS B-TREE-INSERT, top-down, pre-emptive splitting):
  * Duplicates: if the key is already in the tree, do nothing. Check membership BEFORE any
    splitting (a split triggered by a duplicate would change the shape).
  * If the root is full (2t-1 keys), create a new root whose only child is the old root
    and split that child; the tree grows in height only this way.
  * Then descend from the root: at an internal node x, let i be the first index with
    k < x.keys[i] (or i = number of keys, i.e. the last child). If children[i] is full,
    split it first, and if k is greater than the key that moved up into x, continue into
    the new right half (children[i+1]), otherwise into children[i].
  * At the leaf, insert k at its sorted position.
  * Split of a full node y (2t-1 keys) that is child i of x: the median y.keys[t-1]
    (0-based) moves up into x at key position i; y keeps keys 0..t-2 (and children
    0..t-1 if internal); a new right sibling z gets keys t..2t-2 (and children t..2t-1)
    and is inserted into x as child i+1.
  * Nodes are split on the way down even if the insertion would not overflow them. Do
    NOT implement the bottom-up "split on overflow" variant - it gives different trees.

Delete (CLRS B-TREE-DELETE, top-down):
  * If the key is not in the tree, the tree is left completely UNCHANGED. Check membership
    first (a CLRS descent towards an absent key would still rebalance nodes).
  * Otherwise run delete(root, k):
    1. k is in node x and x is a leaf: remove k from x.
    2. k = x.keys[i] in an internal node x; let y = children[i] (left), z = children[i+1]
       (right):
       2a. if y has >= t keys: let k' be the predecessor of k (the maximum key in y's
           subtree); recursively delete(y, k'), then replace x.keys[i] with k'.
           The predecessor is preferred whenever y has >= t keys, even if z also has.
       2b. else if z has >= t keys: symmetric - k'' = successor (minimum key in z's
           subtree); recursively delete(z, k''), then replace x.keys[i] with k''.
       2c. else (both have t-1 keys): merge y, k and z into y (y.keys + [k] + z.keys,
           y.children + z.children), remove k and z from x, then delete(y, k).
    3. k is not in internal node x: let c = children[i] be the child whose subtree must
       contain k (i = first index with k < x.keys[i], or the last child). If c has exactly
       t-1 keys, fix it BEFORE descending:
       3a. if the LEFT sibling children[i-1] exists and has >= t keys: rotate right - the
           separator x.keys[i-1] moves down to the front of c, the left sibling's last key
           moves up to replace it, and the left sibling's last child (if any) becomes c's
           first child.
           Otherwise, if the RIGHT sibling children[i+1] exists and has >= t keys: rotate
           left - the separator x.keys[i] moves down to the end of c, the right sibling's
           first key moves up to replace it, and the right sibling's first child (if any)
           becomes c's last child.
           The left sibling is always tried first.
       3b. otherwise (no sibling with >= t keys): if c has a right sibling, merge c, the
           separator x.keys[i] and the right sibling into c; only if c is the LAST child,
           merge the left sibling, the separator x.keys[i-1] and c into the left sibling.
       Then continue delete(...) in the (possibly merged) node that now covers k.
  * After each deletion, if the root has no keys but has a child, that child becomes the
    new root (the height shrinks). Deleting the last key yields the empty tree (a root
    leaf with no keys, not null).

Complexity: O(t * log_t n) per operation; the tests insert up to 2000 keys.

Keep the contract in BTree.java; put the solution in BTreeImpl.java.
```
