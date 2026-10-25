import java.util.Objects;

public final class KnapsackImpl extends Knapsack {

    public KnapsackImpl() {
        super();
    }

    @Override
    public int maxValue(int[] weights, int[] values, int capacity) {
        validate(weights, values);
        if (weights.length == 0 || capacity <= 0) {
            return 0;
        }

        int[] best = new int[capacity + 1];
        for (int i = 0; i < weights.length; i++) {
            int w = weights[i];
            int v = values[i];
            if (w > capacity) {
                continue;
            }
            for (int c = capacity; c >= w; c--) {
                int candidate = best[c - w] + v;
                if (candidate > best[c]) {
                    best[c] = candidate;
                }
            }
        }
        return best[capacity];
    }

    @Override
    public Result solve(int[] weights, int[] values, int capacity) {
        validate(weights, values);
        int n = weights.length;
        if (n == 0) {
            return new Result(0, new int[0], 0);
        }
        if (capacity <= 0) {
            return new Result(0, new int[n], 0);
        }

        int[][] dp = new int[n + 1][capacity + 1];
        for (int i = 1; i <= n; i++) {
            int w = weights[i - 1];
            int v = values[i - 1];
            int[] prev = dp[i - 1];
            int[] curr = dp[i];
            for (int c = 0; c <= capacity; c++) {
                int skip = prev[c];
                if (w <= c) {
                    int take = prev[c - w] + v;
                    curr[c] = Math.max(skip, take);
                } else {
                    curr[c] = skip;
                }
            }
        }

        int[] selected = new int[n];
        int remaining = capacity;
        int totalWeight = 0;
        for (int i = n; i >= 1; i--) {
            if (dp[i][remaining] != dp[i - 1][remaining]) {
                selected[i - 1] = 1;
                remaining -= weights[i - 1];
                totalWeight += weights[i - 1];
            }
        }

        return new Result(dp[n][capacity], selected, totalWeight);
    }

    private static void validate(int[] weights, int[] values) {
        Objects.requireNonNull(weights, "weights must not be null");
        Objects.requireNonNull(values, "values must not be null");
        if (weights.length != values.length) {
            throw new IllegalArgumentException("weights and values must have the same length");
        }
    }
}
