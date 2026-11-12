public class SequenceAlignmentImpl extends SequenceAlignment {
    @Override
    public int alignmentScore(String a, String b, int matchScore, int mismatchPenalty,
                              int gapOpen, int gapExtend) {
        throw new UnsupportedOperationException("alignmentScore not implemented");
    }

    @Override
    public AlignResult align(String a, String b, int matchScore, int mismatchPenalty,
                             int gapOpen, int gapExtend) {
        throw new UnsupportedOperationException("align not implemented");
    }
}
