I'm planning a three-state Gotoh alignment with a traceback, starting from the match state M(i,j) and then the gap states that track a gap in each sequence.

Now I'm writing out the recurrences for the three states, with the gap-open cost charged whenever a run switches into X or Y from another state, and the base cases set so the first row and column start correctly.

Now I'm working out the base cases for the first row and column, then the final answer as the best of the three states at (n, m). Next is the traceback, which walks back from the best end state and, in the match state, picks whichever previous state explains the score.

Now I'm checking the boundary cases, making sure the first row and column are set so the traceback stays in the right state at (0,0). I'm also noting that the NEG sentinel is far enough from overflow that subtracting gap costs is safe, and that valid scores stay well above it.

Still writing the DP tables...

Still writing the DP fill routine...

Still writing the DP fill loop...

Still writing the DP fill loop...

Still writing the traceback...

Still writing the traceback...

Still writing the traceback...

Still writing the Scala code, with the NEG sentinel and tailrec traceback.


