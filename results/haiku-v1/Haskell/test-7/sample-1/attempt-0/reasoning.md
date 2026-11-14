I'm planning a Haskell module that implements Gotoh's affine-gap alignment, with three states: M for matches, X for gaps in b, and Y for gaps in a. I'm also noting that X and Y can transition directly into each other, since consecutive gaps on opposite sides are separate gaps with their own opening cost.

Now I'm working out the transitions for the three matrices, including how X and Y can feed into each other with an opening cost, and how M takes its best value from any state.

Now I'm defining C as the best score over all states at each cell, with C[0][0] as the base, and writing M from the diagonal predecessor. I'm also checking that the X recurrence can draw on C, since its extension from X is already covered by the ext term.

Still working out whether the exact formulation needs separate M, X, and Y matrices and how to seed the start cell.

Still writing the recurrences...

Still working out the boundary cases for the X and Y recurrences, specifically how the start cell feeds into the first gap.

Still writing the recurrences, now defining the Y state and the X state's start handling using the M endpoint.

Still writing the recurrences, now settling how the cell values depend on each other and what the negative-infinity sentinel does to the sums.

Still working out the traceback, starting from the best final state and stepping back through the predecessors.

Still working out the traceback, stepping back from the best final state through the predecessors.

Still writing the traceback, now working out which predecessor state each M step came from.

Still working out the traceback, now handling the start case and which state wins at the final cell before stepping back.

Still working out the Y recurrence and the X-from-Y case, and checking that the gap-open cost is charged once per gap.

Still writing the table construction, now defining the M, X, and Y arrays over the grid bounds.

Still writing the transition functions for the Y state and the boundary checks.

Still writing the cell-value bounds, checking that the negative-infinity sentinel stays far enough below any real score that repeated subtractions can't push it up into the valid range.

Still writing the Haskell code, now making the traceback and the score use the same arrays so they stay consistent.

Still writing the helpers, now defining the best-score and end-state lookups on the table record so the traceback can share them.

Still writing the Haskell traceback, now working through the predecessor for the M state by checking which of the three matrices at the previous diagonal cell holds the best value.

Still writing the traceback, now choosing the predecessor state for each X and M step by comparing against the neighboring cell values.

Still writing the Y-state traceback and the initial state choice at the final cell.

Still working out the traceback: from the start cell, the state I pick at each step comes from comparing the stored best values at the predecessor cell. The code is the same shape as the score function, just tracking which state each step came from.

Still writing the traceback, now settling the type signatures and making the score and traceback share the same table lookups.


