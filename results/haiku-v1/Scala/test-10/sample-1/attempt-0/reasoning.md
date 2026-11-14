I'm sketching a median-of-medians function in Scala 2.11: return None for an empty list, split the input into groups of five, and take the lower median of each sorted group. Then I'd compute the lower median of those medians with a sort, which is fine for now even though it's O(n log n).

Still writing selection code...

Still writing selection code...

Still working out the two-sorted-arrays median, so I'm weighing a k-th element approach with halving steps against a binary search over the partition point of the shorter array.

I'm settling on a binary search over the partition point of the shorter array, with the halves computed from the combined length, and checking that the boundary elements line up on each side.

I'm checking the bounds on the partition index: since m ≤ n, half - mid stays within [0, n] for every mid in [0, m]. If a(mid) is smaller than b(j-1), the split has to move right, so I raise lo to mid+1; otherwise I pull hi down to mid.

Still working out the median step: I'm settling the final value from the left-side maximum and right-side minimum after the search, using the odd or even total to pick between them, and handling the infinite boundaries when a side is empty.

Still working through the bounds for the two-sorted-arrays median, checking the edge case where the shorter array is empty.

I'm checking the boundary cases of the partition search, including when one side is empty or the total is 0 or 1. The loop only needs one condition: move the lower bound up when the left element of the shorter array sits below the matching element of the other side, and tighten the upper bound otherwise.

Still writing the median-of-two-sorted-arrays code...

Still refining the median-of-two-sorted-arrays code, handling the Long sentinels for empty sides and using the max and min of each partition to finish the median.

Still writing the median-of-medians helpers...


