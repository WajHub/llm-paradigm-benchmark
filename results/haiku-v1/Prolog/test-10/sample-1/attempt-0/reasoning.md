I'm writing out the full module now, swapping the stubs for real implementations, and I'll return only raw Prolog. For `median_of_medians`, an empty list gives `none`; otherwise I split the list into groups of five, sort each group and take its lower median, and then I still need to settle how to get the lower median of those medians.

Still writing the selection code...

Still writing the selection loop...

Still writing the selection code...

Still writing the median-of-two-sorted-arrays search...

Still working out the search for the k-th element across the two sorted arrays, halving the candidate range on each step.

Still working through the halving step for the k-th element: if I compare the i-th element of A against the j-th of B, whatever is smaller lets me discard that whole prefix from its array.

Still working out the halving rule: if an element's 1-based rank is at most K, it can't be the K-th element, so I'm checking when the prefix can be discarded safely.

Still working out the halving rule for the k-th element: if I take h = (K+1)//2 from each array, the pair of entries I compare can only safely discard prefixes whose total size stays within K.

Checking whether the halving step is safe when one array has fewer than h elements: if A is shorter than h, then all of A sits below B[j-1], so its ranks stay within La+h-1, and I need to confirm that still fits under K.

Still working through the halving bounds: the discarded prefix stays within rank K, so each step safely shrinks K by at least one element.

Still working through the halving step: since K drops by about h each round, and any array that runs out gets resolved directly, the search only needs a handful of steps.

Still writing the k-th element selection, using the source wrappers and a case split on the remaining lengths and K.

Still writing the k-th element search, with the recursive case that compares the two candidate entries and drops the smaller side's prefix.

Still working out the median step: for an odd total I take the middle index, and for an even total I average the two central values.

Still writing the k-th element search, so the rest of the module can be assembled around it.

Still writing out the module, checking that the built-ins I rely on, like `msort`, are available.


