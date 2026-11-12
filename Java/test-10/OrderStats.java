public abstract class OrderStats {
    protected OrderStats() {}

    public static final class SelectResult {
        public final int value;       // the k-th smallest element
        public final int[] pivots;    // top-level BFPRT pivots, in the order they were chosen
        public SelectResult(int value, int[] pivots) {
            this.value = value;
            this.pivots = pivots;
        }
    }

    /** Read-only sorted (non-decreasing) sequence; get(index) is valid for 0 <= index < length(). */
    public interface SortedSource {
        int length();
        int get(int index);
    }

    public abstract Integer medianOfMedians(int[] xs);
    public abstract SelectResult selectKth(int[] xs, int k);
    public abstract Double medianTwoSorted(SortedSource a, SortedSource b);
}
