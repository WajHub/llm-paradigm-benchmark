I'm tracing why deleting a key from a leaf fails, starting with how deleteAll calls containsKey and then deleteKey from the root. I'm checking the leaf branch in deleteKey and the case where the key isn't in the node, since either could be where it goes wrong.

I'm checking the "k in x" test, which looks fine, and then the removeIndex: call on the keys, which should be valid in GNU Smalltalk. Since insertion works but deletion fails, I'm wondering whether the input keys collection is being shared or modified somewhere.

Now I'm checking the rest of the deleteAll path, including the parameter signature and the degree argument. The insertion test passes, so I'm not suspecting duplicate handling anymore. I'm also reconsidering whether the root shrinking after deletion could be the cause.

I'm now wondering whether the Array-versus-OrderedCollection type of the keys is what breaks `removeIndex:`, since insertion builds them as OrderedCollections but the copy and append paths could leave an Array behind. I've checked `copyFrom:to:` and `asOrderedCollection` on the children, and those look fine to me.

I'm now testing whether the failure lies in how the keys collection is shared with the insertion path, or in the removeIndex: call itself. I'm also weighing whether the internal-node branch could affect B01 at all, and I'm judging that it probably doesn't.

I'm checking the rest of the deleteAll path, including the leaf handling and how the root gets rebuilt after removals. I'm also wondering whether the Array-versus-OrderedCollection key types could matter here, and I'll look at deleteKey more closely next.

I'm now checking whether redefining the BTree class at the top of my file, which is a `subclass:` declaration, might be overriding the class that BTree.st already provides.

I'm wondering whether redeclaring BTree at the top of the file could matter, though it probably doesn't since insertion already works. I'm also checking how `removeIndex:` behaves in GNU Smalltalk, since that's the remaining suspect for the leaf deletion failure.

I'm now checking whether `removeIndex:` behaves as expected in GNU Smalltalk, since I half-remember it returning the removed element in some versions. I'm also going over the other small suspects, like `removeLast`, `keyList`, and whether the `keys` argument name clashes with anything in `deleteAll`, but none of them look wrong so far. The thought I was following when it cut off was about `fixChildAt`.

I'm now wondering whether redeclaring `BTree` with `Object subclass: BTree [ ]` at the top of my file could be the problem, though insertion already works so it's probably harmless. I'll check `removeIndex:` in GNU Smalltalk, since it's still my main suspect for the leaf deletion failure.

I'm going over the BTree redeclaration and the merge logic, then working through a small B01-style case with degree 2 to see where a deletion from a leaf goes wrong.

I'm checking the leaf case of `deleteKey`, where `removeIndex:` should take the key out, and tracing through a small degree-2 example that comes out correct. I'm still not seeing what breaks deletion, and I'm starting to suspect the containsKey loop.

I'm checking whether `removeIndex:` exists on GNU Smalltalk's OrderedCollection, which I believe it does. I'm also wondering whether the keys collection on `x` might be shared or an Array instead.

I'm working through the leaf-deletion path, checking the nested-tree descent and whether the merge and rotate steps match the expected behavior.

I'm following the descent through the internal node: once the child is fixed up, the recursive delete goes into the child at the same index, and the merge case just moves the index back by one. I'm checking that the lowerBound logic places the key in the right child, and it seems to hold.

I'm checking the `asOrderedCollection` and `copyFrom:to:` calls on the children's keys, since the sizes there look right. I'm also reasoning that the insertion tests pass, so the tree is built correctly and the deletion failure is probably in the deletion path rather than the structure.

I'm wondering whether gst's `OrderedCollection` actually has `removeIndex:` or only `removeAtIndex:`, since if the method name is wrong, leaf deletion would fail every time.

I'm now suspecting that `removeIndex:` may not exist on GNU Smalltalk's OrderedCollection, which would explain why every leaf deletion fails while insertion works. A manual removal helper that copies the collection without the element at that index would avoid the question entirely.

I'm now thinking the `removeIndex:` call might not exist in GNU Smalltalk, which would explain why every leaf deletion fails while insertion works. I'm considering a helper that removes the element by value with `remove:` instead, since keys and child nodes are unique enough for that to be safe.

I'm swapping the `removeIndex:` calls for a helper called `dropAt:from:`, since the name might clash with a built-in. It will go in the leaf deletion and in the merge step, where both the keys and the children get trimmed.

I'm checking whether `remove:` works safely for the children, since nodes compare by identity and the element will be there. I'll also keep the other collection operations as they are, since they look fine. Then I'll write out the revised file.


