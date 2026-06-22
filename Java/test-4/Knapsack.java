public abstract class Knapsack {
    protected Knapsack() {}

    public static final class Result {
        public final int maxValue;
        public final int[] selected;
        public final int totalWeight;
        public Result(int maxValue, int[] selected, int totalWeight) {
            this.maxValue = maxValue;
            this.selected = selected;
            this.totalWeight = totalWeight;
        }
    }

    public abstract int maxValue(int[] weights, int[] values, int capacity);
    public abstract Result solve(int[] weights, int[] values, int capacity);
}
