I'm writing C code for Gotoh's alignment with traceback, and I'll include the header "sequence_alignment.h" since the file gets saved directly. I'm setting up three matrices for the sequence lengths: M for alignments ending in a match or mismatch, X for alignments ending in a gap that consumes a character from one sequence, and Y for the gap in the other direction.

Still writing the recurrences...

Still working out the boundary values, the first row and column where the gap states start: X down the first column and Y across the first row, with M and the other state set to a large negative sentinel.

Now I'm working out the traceback: starting from the best state at the final cell, I step back through the matrices, emitting a match or mismatch pair for M, a character over a gap for X, and a gap over a character for Y, and I'll need to make sure the boundary states are handled correctly.

I'm checking the boundary cases now: X at row zero and Y at column zero are both NEG, so a traceback can never step into them with a finite score, and the equality test rules those paths out. I'm also confirming the loop ends at (0,0) in the M state, since M[i][0] and M[0][j] are NEG for any nonzero index.

Still writing the allocation and helper code for the DP matrices...

Still writing the DP table fill loop...

Still working out the DP table fill, guarding the sentinel values so the traceback only ever steps through finite states.

Still working out the boundary cases for the X and Y matrices, where the gap states start from the first column and row.

Still writing the traceback loop, checking which matrix state each step came from by matching the stored scores exactly.

Still working out the traceback's tie-breaking order: I check M first when stepping back from X, then the gap-extension option, and I'm making sure the fallback always lands on the right state.

Still working out the result allocation and how the traceback buffer gets filled and reversed.


