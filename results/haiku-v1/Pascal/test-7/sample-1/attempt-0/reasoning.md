I'm setting up the full Gotoh alignment unit with traceback while keeping the interface the same, and I'm planning three matrices over the two sequence lengths, starting with M for matches and X for the gap-in-B case.

Still writing the recurrences...

Still working through the boundary values, Y is handled the same way as X through the gap-in-A transition, and that path is allowed. I'm checking whether the NEG sentinel can get pushed further down as penalties keep subtracting, since X at row 1 depends on values that start out NEG.

I'm checking that the sentinel can't cause problems at the boundaries: the NEG-based candidates only exist within a single step, and every stored cell for i and j both at least 1 ends up with a real value, so the overflow risk is limited to the penalty arithmetic.

Now I'm working out how to store the three matrices in Pascal, leaning toward dynamic 2D arrays sized to (n+1) by (m+1), and checking the final score: the maximum of the three matrices at the bottom-right corner, with 0 for two empty inputs.

Still working out the traceback: I'll start from the cell with the best score and step back through the three matrices, pushing the aligned characters as I go, and treat the gap-in-B state the same way.

Still working out the traceback: from the X state I step to whichever predecessor matches the stored value, and the same goes for Y. I'm also checking that the boundary values for X along the first column are filled in correctly so the equality tests land on real numbers.

Checking the traceback edge case at the first row: if X at (1,0) matches the gap-open path back to M at the origin, the loop ends there, so that boundary holds.

Still working through the traceback: if the X state's predecessor is the gap-open path, the step lands back on M, and the equality tests are only meaningful for the real stored values, not the NEG candidates.

Still working out the traceback: I'm building the output strings by filling a character array from the end, with the total length bounded by n+m.

Still working out the traceback output: I'm storing the aligned characters in arrays and then reversing them into the final strings.

Still writing the traceback output: I'm filling a single AnsiString of length n+m from the end, moving a position index down as each column is pushed, and then taking the final substring as the result.

Still settling the memory layout: I'm using three dynamic 2D arrays for the matrices, renamed to avoid clashing with the parameters, and a small helper for the three-way maximum. For the traceback strings, I'll fill a preallocated string of length n+m from the end and then take the used portion.

Still writing the shared Fill procedure: I'm declaring its parameters so the sequences come in as constants and the scoring values as plain integers, with the three matrices passed back by reference.

Still writing the Fill procedure: I'm initializing the three tables to the sentinel value, setting the origin, and starting the boundary column for the gap-in-B state.

Still writing the Fill loop: I'm setting the interior M cell from the best of the three diagonal predecessors plus the match or mismatch score.

Still writing the max-of-three recurrences for the interior cells, and I'm checking whether a large penalty could push the sentinel value past what fits in the integer range.

Still working out the traceback: I'm setting up the final score selection by comparing the three matrices at the corner, then planning to build the aligned strings from the end.

Still writing the traceback loop: I'm stepping back through the three states, pushing the aligned characters into the preallocated strings and choosing each predecessor by matching the stored values.

Still working out the traceback loop: the state-1 check compares the stored X value against the predecessor, and since XX[0,j] is the sentinel, that branch can't match a real value.

Still working on the traceback output: I'm filling a preallocated string from the end and taking the used portion as the aligned result. Next I'll make sure the shared Fill procedure's parameter names don't clash with anything, then write out the full unit.


