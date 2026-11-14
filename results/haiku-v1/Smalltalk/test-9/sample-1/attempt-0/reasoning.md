I'm planning the BTreeImpl.st file: a BTreeImpl subclass of BTree with insertAll:degree: and deleteAll:from:degree:, leaving BTreeNode alone. I'll use OrderedCollections for keys and children, and I'm sketching private helpers, starting with a recursive contains:in: search.

Still writing the insertion code...

Still working through the split logic, checking the copy ranges and the order of reassignments so the median and the children are taken before the original node changes.

Still working through the insertion, now the non-full case: I'll walk down to a leaf, splitting any full child on the way, and I'm planning a helper to find the first key greater than the new one.

Still writing the membership search as a loop with a temporary node variable, since reassigning the method argument isn't allowed in gst.

Still writing the membership check, looking up the first key greater than the search key and stepping down the children until I either find it or reach a leaf.

Still writing the deletion, now the case where the key sits in an internal node and I'm checking whether the left child can spare a key.

Still writing the deletion, working through the case where the key is in an internal node and the replacement comes from the predecessor or successor, or a merge when neither child can spare a key.

Still working through the deletion, checking the recursive call on the predecessor and confirming that a key found in a leaf is removed directly.

Still working through the deletion: if the root ends up with no keys but one child, I'll promote that child to be the new root, though the recursion can keep going on the merged node in the meantime.

Now I'm checking whether shrinking the root matters when it briefly has no keys, since a merge at the root could leave it with one child and nothing to fix against. I'll shrink the root after each delete at the top level, so the recursion never has to handle that case.

Still writing the fixChildAt: helper, checking whether the left sibling can spare a key to rotate into the child.

Still writing the fixChildAt: helper, now the right-to-left rotation that moves a key from the parent down into the child and up from the left sibling.

Still writing the deletion helpers, checking how the merge and the pointer reassignments are ordered so the children stay correct.

Still writing the merge helper, copying the separator key and the right sibling's keys into the left child, and then the children.

Still writing the merge helper, checking how to remove the separator key and the right child from the parent, and I'm weighing which removal method gst's OrderedCollection supports.

Now I'm checking the top-level deletion loop, which the last part of the code still needs to cover.

Still writing the deletion, now the top-level loop that calls deleteKey and then shrinks the root whenever it has no keys left but still has a child.

Still writing the top-level insertion, starting from an empty root and inserting each key in turn.

Still writing the insertion, now the non-full case: walking down to a leaf and splitting any full child on the way.

Still writing the lookup helper, working out how the first-greater index behaves when a key equals the search key.

Still writing the membership search, now the lower-bound helper that finds the first key not less than the search key.

Still writing the deletion, now the case where the key sits in an internal node and the left child has enough keys to supply a replacement.

Still writing the deletion, now checking whether the child at index i has enough keys before recursing, and fixing it up first if it only has the minimum.

Still working through the deletion, now the case where the child I'm descending into has fewer keys than the minimum, so I'll need to fix it up before recursing.

Still writing the deletion helpers, now the minimum-key lookup in the subtree, and I'm settling on how the BTreeImpl subclass of BTree should be declared at the top of the file.

Still writing the deletion, now the top-level loop that runs deleteKey for each key that's in the tree and shrinks the root whenever it's left with no keys but a child.

Still writing the deletion helpers, checking the root shrink and the rotation and merge ordering in fixChildAt.

Still writing the splitChild step, copying the upper half of the keys into the new node with copyFrom:to:.

Still writing the splitChild step, now updating the children and keys of the original node after the copy.


