I'm writing out the full Haskell module now, with the header exporting the BNode type and the insertAll and deleteAll functions. The insertion logic rejects a minimum degree below 2 and otherwise folds the keys into an empty node.

Still writing the insertion helpers...

Still working through the recursive insertion, now handling the case where the child at the chosen index is full and needs splitting first.

Still working out the insertion index and how the split child gets placed back in the parent.

Still writing the deletion logic...

Still writing the deletion cases, covering when the key sits in an internal node and its predecessor or successor is borrowed from a child with enough keys.

Still working through the deletion descent, checking whether the child I'm about to enter has enough keys before recursing into it.

Still working out the rotate-right case for the deletion descent, shifting a key down from the parent and moving the left sibling's last child across.

Still working through the sibling rotation: when the right sibling has enough keys, I'm moving a key from the parent down into the child and shifting the sibling's first key up.

Still writing the merge step for when neither sibling can spare a key...

Still working out the descent helper, so the new keys and children come back together with the index to recurse into.

Still working out the deletion cases: for the descent I'm reusing the same replaceAt step on the adjusted children, and the target index drops to i-1 only when the merge happens with the left sibling.

Still working through the root-level cleanup: after a deletion, if the root is left with no keys but has a child, that child becomes the new root. I'm checking whether the root can end up empty during a merge, since that case would need the same shrinking step.

Still working through the root case: a merge that leaves the root with no keys and one child just gets rebuilt as an empty-keyed root wrapping the merged child.

Still working out the root shrink step, where the root gets replaced by its only child when it has no keys left.

Still writing the helper functions for the tree, including the key-counting and sorted-insert utilities.

Still working out the deletion for an internal key, looking at the predecessor and successor children on either side of it.

Still working through the deletion for an internal key, now checking the merge case where neither neighbouring child can spare a key.

Still working through the deletion descent, now checking the left and right siblings to see whether either can lend a key before the child is entered.

Still working through the rotate-left case for the deletion descent, borrowing the right sibling's first key and moving its first child across.

Still writing the merge-left case for the deletion descent...

Still working out the merge-left case, where the left sibling absorbs the child and the recursion continues from index i-1.

Still writing the Haskell code, now the final checks on the splitting step and the index it leaves behind...


