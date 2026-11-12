public abstract class TspApprox {
    protected TspApprox() {}

    public static final class TourResult {
        public final int[] tour;   // permutation of 0..n-1, tour[0] == 0
        public final int cost;     // closed-tour cost (returns to tour[0])
        public TourResult(int[] tour, int cost) {
            this.tour = tour;
            this.cost = cost;
        }
    }

    // points[i] = {x, y}; distance is Manhattan |x1 - x2| + |y1 - y2|
    public abstract int mstWeight(int[][] points);
    public abstract TourResult doubleTree(int[][] points);
    public abstract int matchingWeight(int[][] points);
    public abstract TourResult christofides(int[][] points);
}
