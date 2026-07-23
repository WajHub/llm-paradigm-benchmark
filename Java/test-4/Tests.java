import java.util.Arrays;

public final class Tests {
    private static final Knapsack KS = new KnapsackImpl();

    private Tests() {
    }

    private static int referenceDp(int[] weights, int[] values, int capacity) {
        if (weights.length == 0 || capacity <= 0) {
            return 0;
        }
        int[] dp = new int[capacity + 1];
        for (int i = 0; i < weights.length; i++) {
            for (int c = capacity; c >= weights[i]; c--) {
                int cand = dp[c - weights[i]] + values[i];
                if (cand > dp[c]) {
                    dp[c] = cand;
                }
            }
        }
        return dp[capacity];
    }

    private static boolean selectedEquals(int[] actual, int[] expected) {
        return actual != null && Arrays.equals(actual, expected);
    }

    private static boolean testAlgoA01Empty() {
        try {
            return KS.maxValue(new int[0], new int[0], 10) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SingleFit() {
        try {
            return KS.maxValue(new int[]{5}, new int[]{10}, 10) == 10;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03TooHeavy() {
        try {
            return KS.maxValue(new int[]{15}, new int[]{10}, 10) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04CapZero() {
        try {
            return KS.maxValue(new int[]{1, 2, 3}, new int[]{10, 20, 30}, 0) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05ChooseBetter() {
        try {
            return KS.maxValue(new int[]{5, 6}, new int[]{10, 11}, 10) == 11;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06Textbook() {
        try {
            return KS.maxValue(new int[]{2, 3, 4, 5}, new int[]{3, 4, 5, 6}, 5) == 7;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07GreedyTrap() {
        try {
            return KS.maxValue(new int[]{10, 20, 30}, new int[]{60, 100, 120}, 50) == 220;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08SameItems() {
        try {
            return KS.maxValue(new int[]{3, 3, 3, 3}, new int[]{5, 5, 5, 5}, 10) == 15;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09TightFit() {
        try {
            return KS.maxValue(new int[]{3, 4, 5, 6}, new int[]{2, 3, 4, 5}, 10) == 8;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            int n = 50;
            int[] w = new int[n];
            int[] v = new int[n];
            for (int i = 0; i < n; i++) {
                w[i] = i + 1;
                v[i] = (i + 1) * 2;
            }
            int expected = referenceDp(w, v, 100);
            return KS.maxValue(w, v, 100) == expected;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB01SingleSelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{5}, new int[]{10}, 10);
            return r != null && r.maxValue == 10 && r.totalWeight == 5
                    && selectedEquals(r.selected, new int[]{1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02ChooseBetterSelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{5, 6}, new int[]{10, 11}, 10);
            return r != null && r.maxValue == 11 && r.totalWeight == 6
                    && selectedEquals(r.selected, new int[]{0, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03TextbookSelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{2, 3, 4, 5}, new int[]{3, 4, 5, 6}, 5);
            return r != null && r.maxValue == 7 && r.totalWeight == 5
                    && selectedEquals(r.selected, new int[]{1, 1, 0, 0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04GreedyTrapSelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{10, 20, 30}, new int[]{60, 100, 120}, 50);
            return r != null && r.maxValue == 220 && r.totalWeight == 50
                    && selectedEquals(r.selected, new int[]{0, 1, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05CapZeroSelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{1, 2, 3}, new int[]{10, 20, 30}, 0);
            return r != null && r.maxValue == 0 && r.totalWeight == 0
                    && selectedEquals(r.selected, new int[]{0, 0, 0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06TooHeavySelection() {
        try {
            Knapsack.Result r = KS.solve(new int[]{15}, new int[]{10}, 10);
            return r != null && r.maxValue == 0 && r.totalWeight == 0
                    && selectedEquals(r.selected, new int[]{0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07AllFit() {
        try {
            Knapsack.Result r = KS.solve(new int[]{1, 2, 3}, new int[]{10, 20, 30}, 10);
            return r != null && r.maxValue == 60 && r.totalWeight == 6
                    && selectedEquals(r.selected, new int[]{1, 1, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08WeightInvariant() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            int capacity = 50;
            Knapsack.Result r = KS.solve(w, v, capacity);
            if (r == null || r.selected == null) {
                return false;
            }
            int sumW = 0;
            for (int i = 0; i < w.length; i++) {
                sumW += r.selected[i] * w[i];
            }
            return sumW <= capacity && sumW == r.totalWeight;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09ValueInvariant() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            Knapsack.Result r = KS.solve(w, v, 50);
            if (r == null || r.selected == null) {
                return false;
            }
            int sumV = 0;
            for (int i = 0; i < v.length; i++) {
                sumV += r.selected[i] * v[i];
            }
            return sumV == r.maxValue;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressInvariants() {
        try {
            int n = 50;
            int capacity = 100;
            int[] w = new int[n];
            int[] v = new int[n];
            for (int i = 0; i < n; i++) {
                w[i] = i + 1;
                v[i] = (i + 1) * 2;
            }
            int expected = referenceDp(w, v, capacity);
            Knapsack.Result r = KS.solve(w, v, capacity);
            if (r == null || r.selected == null || r.selected.length != n) {
                return false;
            }
            int sumW = 0;
            int sumV = 0;
            for (int i = 0; i < n; i++) {
                if (r.selected[i] != 0 && r.selected[i] != 1) {
                    return false;
                }
                sumW += r.selected[i] * w[i];
                sumV += r.selected[i] * v[i];
            }
            return r.maxValue == expected
                    && sumW <= capacity
                    && sumW == r.totalWeight
                    && sumV == r.maxValue;
        } catch (Exception e) {
            return false;
        }
    }

    private static void runTest(String name, boolean passed, java.util.List<String> failed) {
        if (passed) {
            System.out.println("[PASS] " + name);
        } else {
            System.out.println("[FAIL] " + name);
            failed.add(name);
        }
    }

    public static void main(String[] args) {
        java.util.List<String> failed = new java.util.ArrayList<>();
        int total = 0;

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Maximum Value ---");

        total++; runTest("Test A01 (Empty)", testAlgoA01Empty(), failed);
        total++; runTest("Test A02 (Single Fit)", testAlgoA02SingleFit(), failed);
        total++; runTest("Test A03 (Too Heavy)", testAlgoA03TooHeavy(), failed);
        total++; runTest("Test A04 (Capacity Zero)", testAlgoA04CapZero(), failed);
        total++; runTest("Test A05 (Choose Better)", testAlgoA05ChooseBetter(), failed);
        total++; runTest("Test A06 (Textbook)", testAlgoA06Textbook(), failed);
        total++; runTest("Test A07 (Greedy Trap)", testAlgoA07GreedyTrap(), failed);
        total++; runTest("Test A08 (Same Items)", testAlgoA08SameItems(), failed);
        total++; runTest("Test A09 (Tight Fit)", testAlgoA09TightFit(), failed);
        total++; runTest("Test A10 (Stress 50 Items)", testAlgoA10Stress(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Item Selection ---");

        total++; runTest("Test B01 (Single Selection)", testAlgoB01SingleSelection(), failed);
        total++; runTest("Test B02 (Choose Better Selection)", testAlgoB02ChooseBetterSelection(), failed);
        total++; runTest("Test B03 (Textbook Selection)", testAlgoB03TextbookSelection(), failed);
        total++; runTest("Test B04 (Greedy Trap Selection)", testAlgoB04GreedyTrapSelection(), failed);
        total++; runTest("Test B05 (Capacity Zero Selection)", testAlgoB05CapZeroSelection(), failed);
        total++; runTest("Test B06 (Too Heavy Selection)", testAlgoB06TooHeavySelection(), failed);
        total++; runTest("Test B07 (All Fit)", testAlgoB07AllFit(), failed);
        total++; runTest("Test B08 (Weight Invariant)", testAlgoB08WeightInvariant(), failed);
        total++; runTest("Test B09 (Value Invariant)", testAlgoB09ValueInvariant(), failed);
        total++; runTest("Test B10 (Stress Invariants)", testAlgoB10StressInvariants(), failed);

        System.out.println();
        System.out.println("=== BENCHMARK RESULTS ===");
        System.out.println("Completed " + total + " tests.");

        if (failed.isEmpty()) {
            System.out.println("All tests passed!");
            System.exit(0);
        } else {
            System.out.println("Tests that failed (" + failed.size() + "):");
            for (String name : failed) {
                System.out.println(" - " + name);
            }
            System.exit(1);
        }
    }
}
