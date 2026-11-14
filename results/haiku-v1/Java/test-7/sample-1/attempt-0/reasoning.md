I'm setting up the Gotoh recurrences with three states per cell: M for an aligned pair ending at a[i-1] and b[j-1], X for a gap in b that consumes a, and Y for a gap in a. I'm also defining n and m as the sequence lengths.

Writing the transition equations for the three states now, covering the M, X and Y recurrences and the cost of switching from a gap in a to a gap in b.

I'm settling on a sentinel value for the impossible states, using a large negative number divided by four so additions don't overflow. But the -INF entries can still drift downward as gap penalties accumulate across many cells, so I'm weighing whether a plain int is safe or whether long is the better choice.

I'm clamping the DP values to a safe range, and I'm going with a long-typed NEG of Long.MIN_VALUE/4 so the sentinels can't overflow. Next I'm working out the traceback: I'll recompute which predecessor produced each value rather than storing per-cell choices. I start from the best of M, X and Y at the final cell, and walk back until i and j reach zero.

Now I'm working through the traceback by checking which predecessor matches each value: for the M state I look for the diagonal predecessor that equals the current score minus the substitution cost, and for the gap states I test the open and extend transitions against the stored value. Each step moves the indices back and records the aligned characters or gap, and I'm also confirming that the chosen state has a finite value so the walk never enters an impossible gap at the boundary.

Still working through the traceback, and I'm confirming that each step only follows a finite state so the walk never lands in an impossible gap at the boundary. Ties between predecessors are fine, since any max choice gives a valid path.

Still writing the alignment code...

Still writing the DP fill loop...

Still writing the alignment code...


