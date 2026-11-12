public abstract class SequenceAlignment {
    protected SequenceAlignment() {}

    public static final class AlignResult {
        public final int score;
        public final String alignedA;     // a with '-' gaps inserted
        public final String alignedB;     // b with '-' gaps inserted; same length as alignedA
        public AlignResult(int score, String alignedA, String alignedB) {
            this.score = score;
            this.alignedA = alignedA;
            this.alignedB = alignedB;
        }
    }

    public abstract int alignmentScore(String a, String b, int matchScore, int mismatchPenalty,
                                       int gapOpen, int gapExtend);

    public abstract AlignResult align(String a, String b, int matchScore, int mismatchPenalty,
                                      int gapOpen, int gapExtend);
}
