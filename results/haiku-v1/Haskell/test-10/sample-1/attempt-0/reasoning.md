I'm writing out the full module now, starting with the median-of-medians pivot: groups of five, each sorted with a lower-median index, then the lower median of those medians, returning Just or Nothing for empty input. After that comes selectKth, which bounds-checks k and hands off to a loop that tracks the current list, the remaining rank, and the accumulated pivots.

Still writing loop logic...

I'm working out the binary search for the median of two sorted lists, partitioning on the shorter one, and I'll bound the number of reads so it stays within the budget. For small totals the budget still covers the iterations, and I'll guard every read so it only happens when the index is in range.

I'm setting up the partition for the median of two sorted lists: the left half holds (N+1) div 2 elements, with i taken from the shorter list and j making up the rest from the longer one. I'm binary-searching for the smallest valid i in its allowed range, using a predicate that checks whether the boundary elements are in order.

Still working through the partition search: the smallest valid i is the one where the predicate first holds, and the left-side maximum then comes from the nearest elements on either side of the cut.

I'm settling the rounding for the split: left half gets (N+1) div 2 elements, which makes the median the left maximum for odd totals and the average of the two boundary values for even ones. The final step reads at most four boundary elements, and the binary search itself never reads beyond the range, so the budget holds even for empty or one-sided inputs.

Writing the binary search helper for the median of two sorted lists now...

I'm settling the binary search for the partition point, where the predicate checks whether a's element at i sits at or above b's element just before the cut, skipping the comparison when either side is at its boundary.

Still writing the final step: I'm picking the left-side maximum from whichever boundary values are present, then working out the median from the left and right boundaries.

Still working through the final step: I'm taking the left-side maximum and the right-side minimum from whichever boundary values are present, then averaging them for even totals or using the left maximum directly for odd ones.

Next I'm finishing the base-case check: with one element on each side, the search returns immediately and the final step reads just one value. Then I'll write the median-of-medians helper, grouping the input into chunks of five, taking each group's lower median, and returning the lower median of those medians.

Still writing out selectKth: I'm guarding the case where the index is out of range, and I'll have the loop return a Maybe result so an empty median-of-medians pivot never crashes.

Still writing the selection loop: I'm checking whether the target rank falls in the lower partition, in the pivot-equal block, or in the upper partition, and recursing into the right side with an adjusted rank.

Writing out the full module now, including the required header and types.


