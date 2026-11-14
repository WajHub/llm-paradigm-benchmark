I'm checking the initialization for the first row, where Y[0][j] needs to be filled for j>0. Working through the one-empty case, a="" and b="C", the cell Y[0][1] comes out to the gap-open value, which looks correct.

I've got the sign wrong: I'm adding gap costs where they should be subtracted, so the scores come out positive. The fix is to switch the gap transitions to `- open` and `- ext`, and the traceback equality checks need the same minus signs. The NEG sentinel drifts only slightly, so it's safe with Long.MIN_VALUE/4.

Next I'm defining the gap costs as subtracted values, with `open` set to the gap-open plus gap-extend penalty, and applying that to the traceback transitions.


