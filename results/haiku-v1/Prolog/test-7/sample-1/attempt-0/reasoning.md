I'm planning a Gotoh-style alignment in SWI-Prolog with traceback, so I need to be careful about correctness. I'm setting up the indexing, with n and m as the lengths of A and B and i and j running from 0 to those lengths. I'm also defining the M and X states, where M(i,j) tracks the best score when the last column is a pair of characters.

Now I'm writing out the recurrences for the three states, with X and Y taking their gap-open and gap-extend costs from the neighboring cells, and I'm also allowing transitions between the gap states.

I'm settling on a large negative number as the sentinel instead of a special case, since SWI-Prolog integers are unbounded, so the boundary cells just take the generic recurrence. I'm also checking that the X-to-Y transition is covered, with Y picking up its gap-open cost from X's neighboring cell.

I'm checking the sentinel approach: a large negative number like -10^15 works because real scores stay far above it, and boundary cells such as X(i,0) remain finite, so the NEG values never win the max in practice. I'm also noting that the DP can be kept functional, with each row held as a nested list in Prolog.

I'm weighing how to store the DP tables for traceback: a list of rows, a destructive term with setarg, or an assoc keyed by cell coordinates. An assoc keeps things pure and gives roughly logarithmic lookups, which should be fine for matrices up to about 10^6 cells.

Now I'm settling on how to store the rows for traceback, planning to convert A and B to char lists and key the tables by cell coordinates.

Now I'm working through the traceback storage: I'll keep each row's cells and gather them into an assoc keyed by coordinates, since the pairs come out in order and that makes building it straightforward.

Now I'm working out the traceback step: from each state, I look for which predecessor value explains the current score, and that tells me the previous state and what letters to emit. For the X state I emit the A character against a gap and check the three possible predecessors in turn, and the Y state works the same way with the roles swapped. Any matching predecessor is fine since the stored values are consistent, but the scores have to match exactly.

Checking the traceback termination cases: at (0,0) in state M the walk stops, and the n=m=0 edge case returns an empty result.

Now I'm laying out the forward fill for the first row, where the boundary cell at j=0 is a sentinel and each later cell takes its best gap-open or gap-extend value from the cell to its left.

Writing row-zero code for the Gotoh fill...

Writing row-zero code for the Gotoh fill...

Writing row-step code for the Gotoh fill...

Still writing the row-step code...

Still writing the row-step predicate...

Still building the row-step code, now filling each cell from its diagonal and up-and-left neighbors and assembling the pairs into the assoc.

Still building the traceback storage, and I'm settling on an assoc keyed by (I,J) since the pairs come out in ascending order and list_to_assoc will accept them directly.

Still writing the Prolog module header and the score wrapper, so I'm settling on parameter names that won't clash with the Score output.

Still writing the fill_rows helper, collecting each row into an accumulator and reversing at the end.

Still writing the row-zero helper, where the boundary row's gap-extend cells are filled in from the cell to their left.

Still writing the row-zero helper, now sorting out how the gap-extend value carries from the previous cell in the boundary row.

Still writing the row-step predicate, now pairing each cell's diagonal and up neighbors with the left cell as the walk moves across the row.

Still writing the row-step predicate...

Still building the traceback table, now converting each row's cells into coordinate-keyed pairs for the assoc.

Still building the traceback table, now turning each row into coordinate-keyed pairs so the assoc can be built from them.

Still writing the pairing helpers, now flattening each row's cells into coordinate-keyed pairs in ascending order for the assoc.

Still writing the traceback, now working out how to build the aligned output backward from the end cell and prepend each column as it goes.

Still writing the traceback predicate, now working out how the match-state branch steps diagonally back through the table while prepending each aligned column.

Still working out the traceback, now weighing whether to index the sequences with nth1 lookups or to consume reversed lists from the front as the walk moves backward.

Still writing the traceback predicate, now working out how the match-state branch steps back diagonally through the table and consumes the head of each reversed sequence as it goes.

Still writing the traceback, now working out how the match branch steps diagonally back and how the x and y states consume the reversed sequences differently.

Still working out the traceback for the x state: I'm checking whether the gap-extend or gap-open predecessor explains the current score at (I-1,J), and that decides the next state.

Still working out the traceback for the x state: each step emits the current A character against a gap and moves up to (I-1,J) while the B sequence stays put, and I'm weighing whether the predecessor is a match, gap-extend or gap-open cell.

Still working out the traceback for the y state, where the B character is emitted against a gap and the walk moves left while the A sequence stays put, and I need to check how its predecessors at (I,J-1) line up with the current score.

Still writing the traceback for the y state, now emitting the B character against a gap while the walk moves left, and checking whether the gap-extend, match, or gap-open predecessor at (I,J-1) explains the current score.

Still working out the y-state check: I'm comparing Y(i,j) against its three predecessors, trying the gap-extend from Y(i,j-1) first, then the match from M(i,j-1), and falling back to the X state.

Still working out the traceback for the match branch: I'm checking whether the M, X, or Y predecessor explains the current score, and the choice of next state follows from which one matches.

Still writing the traceback clauses, now confirming that the m-state clause can't fire at I=0 because its reversed-list pattern fails there, and that the cut on the (0,0) base case covers the edge.

Still working through the traceback: I'm checking the empty-input case where the start state is m at (0,0) and the output should be empty, and then tracing the example with two rows against an empty second sequence.

Still working through the traceback for the x state, checking which predecessor explains the score and then confirming the walk ends in state m at (0,0). Now I'm setting up the scoring wrapper that fills the matrix and gets ready to choose the starting state.

Still writing the alignment entry point, now computing the final score from the last cell and getting ready to pick the starting state for the traceback.

Still writing the traceback helper for the start state, now passing the scoring parameters through so the match and gap clauses can compute their costs.

Still writing the Prolog helper for row zero, now setting up the start-state choice and the `row0_` clause that fills in the boundary cells.

Still writing the row-step helper, now defining the first-row fill and carrying the gap-extend values along the boundary.

Still writing the row-step clause, now destructuring the diagonal and upper neighbors and the left cell's values.

Still writing row-step, now finishing the cell updates that combine the diagonal, up, and left neighbors with the score.

Still writing the fill loop, now defining the row-by-row recursion that carries each previous row forward.

Still writing the fill helpers, now wrapping up the row-building calls and getting ready to clean out the error-throwing stubs.


