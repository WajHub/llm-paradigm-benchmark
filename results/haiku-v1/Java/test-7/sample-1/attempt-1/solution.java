import java.util.ArrayDeque;
import java.util.Arrays;
import java.util.Deque;

public final class SequenceAlignmentImpl extends SequenceAlignment {

    private static final long NEG = Long.MIN_VALUE / 4;
    private static final char GAP = '-';

    private enum State { MATCH, GAP_IN_B, GAP_IN_A }

    private static final class Tables {
        final long[][] m;
        final long[][] x;
        final long[][] y;

        Tables(int n, int len) {
            m = new long[n + 1][len + 1];
            x = new long[n + 1][len + 1];
            y = new long[n + 1][len + 1];
            for (int i = 0; i <= n; i++) {
                Arrays.fill(m[i], NEG);
                Arrays.fill(x[i], NEG);
                Arrays.fill(y[i], NEG);
            }
        }
    }

    private static Tables fill(String a, String b, int matchScore, int mismatchPenalty,
                               int gapOpen, int gapExtend) {
        int n = a.length();
        int len = b.length();
        Tables t = new Tables(n, len);
        long open = (long) gapOpen + gapExtend;
        long ext = gapExtend;
        t.m[0][0] = 0;
        for (int i = 0; i <= n; i++) {
            for (int j = 0; j <= len; j++) {
                if (i == 0 && j == 0) {
                    continue;
                }
                if (i > 0 && j > 0) {
                    long s = a.charAt(i - 1) == b.charAt(j - 1) ? matchScore : -mismatchPenalty;
                    long best = Math.max(t.m[i - 1][j - 1],
                            Math.max(t.x[i - 1][j - 1], t.y[i - 1][j - 1]));
                    t.m[i][j] = best + s;
                }
                if (i > 0) {
                    t.x[i][j] = Math.max(t.m[i - 1][j] - open,
                            Math.max(t.x[i - 1][j] - ext, t.y[i - 1][j] - open));
                }
                if (j > 0) {
                    t.y[i][j] = Math.max(t.m[i][j - 1] - open,
                            Math.max(t.y[i][j - 1] - ext, t.x[i][j - 1] - open));
                }
            }
        }
        return t;
    }

    @Override
    public int alignmentScore(String a, String b, int matchScore, int mismatchPenalty,
                              int gapOpen, int gapExtend) {
        if (a.isEmpty() && b.isEmpty()) {
            return 0;
        }
        Tables t = fill(a, b, matchScore, mismatchPenalty, gapOpen, gapExtend);
        int n = a.length();
        int len = b.length();
        long best = Math.max(t.m[n][len], Math.max(t.x[n][len], t.y[n][len]));
        return (int) best;
    }

    @Override
    public AlignResult align(String a, String b, int matchScore, int mismatchPenalty,
                             int gapOpen, int gapExtend) {
        if (a.isEmpty() && b.isEmpty()) {
            return new AlignResult(0, "", "");
        }
        Tables t = fill(a, b, matchScore, mismatchPenalty, gapOpen, gapExtend);
        int n = a.length();
        int len = b.length();
        long open = (long) gapOpen + gapExtend;
        long ext = gapExtend;

        long bestScore = Math.max(t.m[n][len], Math.max(t.x[n][len], t.y[n][len]));
        State state;
        if (t.m[n][len] == bestScore) {
            state = State.MATCH;
        } else if (t.x[n][len] == bestScore) {
            state = State.GAP_IN_B;
        } else {
            state = State.GAP_IN_A;
        }

        Deque<Character> revA = new ArrayDeque<>();
        Deque<Character> revB = new ArrayDeque<>();
        int i = n;
        int j = len;

        while (i > 0 || j > 0) {
            switch (state) {
                case MATCH: {
                    long s = a.charAt(i - 1) == b.charAt(j - 1) ? matchScore : -mismatchPenalty;
                    long v = t.m[i][j];
                    long prev = v - s;
                    revA.push(a.charAt(i - 1));
                    revB.push(b.charAt(j - 1));
                    if (t.m[i - 1][j - 1] == prev) {
                        state = State.MATCH;
                    } else if (t.x[i - 1][j - 1] == prev) {
                        state = State.GAP_IN_B;
                    } else {
                        state = State.GAP_IN_A;
                    }
                    i--;
                    j--;
                    break;
                }
                case GAP_IN_B: {
                    long v = t.x[i][j];
                    revA.push(a.charAt(i - 1));
                    revB.push(GAP);
                    if (t.m[i - 1][j] - open == v) {
                        state = State.MATCH;
                    } else if (t.x[i - 1][j] - ext == v) {
                        state = State.GAP_IN_B;
                    } else {
                        state = State.GAP_IN_A;
                    }
                    i--;
                    break;
                }
                case GAP_IN_A: {
                    long v = t.y[i][j];
                    revA.push(GAP);
                    revB.push(b.charAt(j - 1));
                    if (t.m[i][j - 1] - open == v) {
                        state = State.MATCH;
                    } else if (t.y[i][j - 1] - ext == v) {
                        state = State.GAP_IN_A;
                    } else {
                        state = State.GAP_IN_B;
                    }
                    j--;
                    break;
                }
                default:
                    throw new IllegalStateException("Invalid traceback state");
            }
        }

        StringBuilder sa = new StringBuilder(revA.size());
        StringBuilder sb = new StringBuilder(revB.size());
        for (char c : revA) {
            sa.append(c);
        }
        for (char c : revB) {
            sb.append(c);
        }
        return new AlignResult((int) bestScore, sa.toString(), sb.toString());
    }
}
