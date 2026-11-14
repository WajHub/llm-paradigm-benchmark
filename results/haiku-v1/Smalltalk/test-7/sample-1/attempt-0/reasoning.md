I'm settling on the shape of the answer: a SequenceAlignmentImpl subclass of SequenceAlignment with two methods, emitted as raw Smalltalk with no markdown. I'm leaning toward leaving AlignmentResult and SequenceAlignment out and writing just the SequenceAlignmentImpl class in its own file. I'm also starting to sketch a Gotoh-style alignment using three matrices.

Still working out the three-matrix recurrences for the Gotoh alignment...

I'm defining the X-state recurrence for an alignment gap in a, where the best score comes from the M, X, or Y state at the previous row with the matching gap-open or gap-extend penalty.

Still working through the Gotoh boundary cases: the first column of X and the first row of Y, and what the recurrence gives when the sequences are empty.

Still working through the traceback: from the cell with the best score I walk back, and in the M state I step diagonally to the best predecessor and record both characters.

Still working out the traceback's predecessor choice for the X and Y states, checking which of the candidate values from the neighbouring cell matches the current score.

Still settling the value for negative infinity: I'm weighing whether a fixed large negative stays safe when the gap costs get big, and I'm leaning toward a very large negative LargeInt computed as `(10 raisedTo: 40) negated`.

Still laying out the matrix setup: I'll build the matrices as arrays of rows, each initialized to the large negative value, and I'm thinking of a helper method for creating them. Next I'm sketching how the class itself will be structured in Smalltalk.

Still writing the matrix helpers and the Smalltalk class layout...

Still writing the Smalltalk helpers for the matrices and cell access...

Still writing the matrix fill loops, initializing the first column of the X table.

Still writing the fill loop, going cell by cell: the match state from the diagonal, the gap-in-a state from above, and the gap-in-b state from the left.

Still writing the fill loop: the max-of-three and substitution scoring for each cell, and then the scoreOf and align methods that return the tables and run the traceback.

Still writing the String result and the traceback, starting from the best final state.

Still writing the traceback loop, choosing the best predecessor state in the M case.

Still writing the traceback's X-state step, picking the predecessor from the M, X, or Y cell above.

Still writing the traceback's Y-state step, checking whether the predecessor in the row to the left matches the current score.

Still checking the traceback's predecessor choices against the negative-infinity sentinel, and settling how the final alignment result gets assembled.

Still checking how `String withAll:` handles the traceback output, including the empty case.

Still writing the helper methods, checking that the parameter names don't clash with the matrix variables.

Still writing the fill method: setting up the three tables and the open-gap cost, then filling them cell by cell.

Still writing the fill loop: setting the origin cell of the match table, then for each interior cell taking the best of the three diagonal predecessors plus the substitution score.

Still writing the fill loop, with the X and Y tables filled alongside the match table.


