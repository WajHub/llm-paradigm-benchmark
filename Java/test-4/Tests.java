public final class Tests {
    private static final Knapsack KS = new KnapsackImpl();

    private Tests() {}

    private static int referenceDp(int[] weights, int[] values, int capacity) {
        int n = weights.length;
        if (n == 0 || capacity <= 0) {
            return 0;
        }
        int[][] dp = new int[n + 1][capacity + 1];
        for (int i = 1; i <= n; i++) {
            for (int c = 0; c <= capacity; c++) {
                dp[i][c] = dp[i - 1][c];
                if (weights[i - 1] <= c) {
                    int take = dp[i - 1][c - weights[i - 1]] + values[i - 1];
                    if (take > dp[i][c]) {
                        dp[i][c] = take;
                    }
                }
            }
        }
        return dp[n][capacity];
    }

    private static boolean selectedMatches(int[] actual, int[] expected) {
        if (actual == null || actual.length != expected.length) {
            return false;
        }
        for (int i = 0; i < expected.length; i++) {
            if (actual[i] != expected[i]) {
                return false;
            }
        }
        return true;
    }

    private static boolean testAlgoA01EmptyArrays() {
        try {
            int[] w = new int[0];
            int[] v = new int[0];
            return KS.maxValue(w, v, 10) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SingleFits() {
        try {
            int[] w = {5};
            int[] v = {10};
            return KS.maxValue(w, v, 10) == 10;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03SingleTooHeavy() {
        try {
            int[] w = {15};
            int[] v = {10};
            return KS.maxValue(w, v, 10) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04ZeroCapacity() {
        try {
            int[] w = {1, 2, 3};
            int[] v = {10, 20, 30};
            return KS.maxValue(w, v, 0) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05PickBetterSingle() {
        try {
            int[] w = {5, 6};
            int[] v = {10, 11};
            return KS.maxValue(w, v, 10) == 11;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06ClassicSmall() {
        try {
            int[] w = {2, 3, 4, 5};
            int[] v = {3, 4, 5, 6};
            return KS.maxValue(w, v, 5) == 7;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07GreedyTrap() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            return KS.maxValue(w, v, 50) == 220;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08IdenticalItems() {
        try {
            int[] w = {3, 3, 3, 3};
            int[] v = {5, 5, 5, 5};
            return KS.maxValue(w, v, 10) == 15;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09NontrivialChoice() {
        try {
            int[] w = {3, 4, 5, 6};
            int[] v = {2, 3, 4, 5};
            return KS.maxValue(w, v, 10) == 8;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10StressMaxValue() {
        try {
            int n = 50;
            int[] w = new int[n];
            int[] v = new int[n];
            for (int i = 0; i < n; i++) {
                w[i] = i + 1;
                v[i] = (i + 1) * 2;
            }
            int capacity = 100;
            int expected = referenceDp(w, v, capacity);
            return KS.maxValue(w, v, capacity) == expected;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB01SelectSingle() {
        try {
            int[] w = {5};
            int[] v = {10};
            Knapsack.Result r = KS.solve(w, v, 10);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 10 && r.totalWeight == 5 && selectedMatches(r.selected, new int[]{1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02SelectBetterSingle() {
        try {
            int[] w = {5, 6};
            int[] v = {10, 11};
            Knapsack.Result r = KS.solve(w, v, 10);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 11 && r.totalWeight == 6 && selectedMatches(r.selected, new int[]{0, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03SelectClassicSmall() {
        try {
            int[] w = {2, 3, 4, 5};
            int[] v = {3, 4, 5, 6};
            Knapsack.Result r = KS.solve(w, v, 5);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 7 && r.totalWeight == 5 && selectedMatches(r.selected, new int[]{1, 1, 0, 0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04SelectGreedyTrap() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            Knapsack.Result r = KS.solve(w, v, 50);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 220 && r.totalWeight == 50 && selectedMatches(r.selected, new int[]{0, 1, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05SelectZeroCapacity() {
        try {
            int[] w = {1, 2, 3};
            int[] v = {10, 20, 30};
            Knapsack.Result r = KS.solve(w, v, 0);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 0 && r.totalWeight == 0 && selectedMatches(r.selected, new int[]{0, 0, 0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06SelectTooHeavy() {
        try {
            int[] w = {15};
            int[] v = {10};
            Knapsack.Result r = KS.solve(w, v, 10);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 0 && r.totalWeight == 0 && selectedMatches(r.selected, new int[]{0});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07SelectAllFit() {
        try {
            int[] w = {1, 2, 3};
            int[] v = {10, 20, 30};
            Knapsack.Result r = KS.solve(w, v, 10);
            if (r == null || r.selected == null) {
                return false;
            }
            return r.maxValue == 60 && r.totalWeight == 6 && selectedMatches(r.selected, new int[]{1, 1, 1});
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08WeightInvariantGreedyTrap() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            int capacity = 50;
            Knapsack.Result r = KS.solve(w, v, capacity);
            if (r == null || r.selected == null || r.selected.length != w.length) {
                return false;
            }
            int sumW = 0;
            for (int i = 0; i < w.length; i++) {
                if (r.selected[i] != 0 && r.selected[i] != 1) {
                    return false;
                }
                sumW += r.selected[i] * w[i];
            }
            return sumW <= capacity && sumW == r.totalWeight;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09ValueInvariantGreedyTrap() {
        try {
            int[] w = {10, 20, 30};
            int[] v = {60, 100, 120};
            int capacity = 50;
            Knapsack.Result r = KS.solve(w, v, capacity);
            if (r == null || r.selected == null || r.selected.length != w.length) {
                return false;
            }
            int sumV = 0;
            for (int i = 0; i < w.length; i++) {
                if (r.selected[i] != 0 && r.selected[i] != 1) {
                    return false;
                }
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
            int[] w = new int[n];
            int[] v = new int[n];
            for (int i = 0; i < n; i++) {
                w[i] = i + 1;
                v[i] = (i + 1) * 2;
            }
            int capacity = 100;
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
            if (sumW > capacity) return false;
            if (sumW != r.totalWeight) return false;
            if (sumV != r.maxValue) return false;
            return r.maxValue == expected;
        } catch (Exception e) {
            return false;
        }
    }

    public static void main(String[] args) {
        int failedCount = 0;
        String[] failedTests = new String[50];
        int totalTests = 0;

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Max Value ---");
        totalTests++;
        if (testAlgoA01EmptyArrays()) {
            System.out.println("[PASS] Test A01 (Empty Arrays)");
        } else {
            System.out.println("[FAIL] Test A01 (Empty Arrays)");
            failedTests[failedCount++] = "Test A01 (Empty Arrays)";
        }
        totalTests++;
        if (testAlgoA02SingleFits()) {
            System.out.println("[PASS] Test A02 (Single Item Fits)");
        } else {
            System.out.println("[FAIL] Test A02 (Single Item Fits)");
            failedTests[failedCount++] = "Test A02 (Single Item Fits)";
        }
        totalTests++;
        if (testAlgoA03SingleTooHeavy()) {
            System.out.println("[PASS] Test A03 (Single Item Too Heavy)");
        } else {
            System.out.println("[FAIL] Test A03 (Single Item Too Heavy)");
            failedTests[failedCount++] = "Test A03 (Single Item Too Heavy)";
        }
        totalTests++;
        if (testAlgoA04ZeroCapacity()) {
            System.out.println("[PASS] Test A04 (Zero Capacity)");
        } else {
            System.out.println("[FAIL] Test A04 (Zero Capacity)");
            failedTests[failedCount++] = "Test A04 (Zero Capacity)";
        }
        totalTests++;
        if (testAlgoA05PickBetterSingle()) {
            System.out.println("[PASS] Test A05 (Pick Better Single)");
        } else {
            System.out.println("[FAIL] Test A05 (Pick Better Single)");
            failedTests[failedCount++] = "Test A05 (Pick Better Single)";
        }
        totalTests++;
        if (testAlgoA06ClassicSmall()) {
            System.out.println("[PASS] Test A06 (Classic Small)");
        } else {
            System.out.println("[FAIL] Test A06 (Classic Small)");
            failedTests[failedCount++] = "Test A06 (Classic Small)";
        }
        totalTests++;
        if (testAlgoA07GreedyTrap()) {
            System.out.println("[PASS] Test A07 (Greedy Trap)");
        } else {
            System.out.println("[FAIL] Test A07 (Greedy Trap)");
            failedTests[failedCount++] = "Test A07 (Greedy Trap)";
        }
        totalTests++;
        if (testAlgoA08IdenticalItems()) {
            System.out.println("[PASS] Test A08 (Identical Items)");
        } else {
            System.out.println("[FAIL] Test A08 (Identical Items)");
            failedTests[failedCount++] = "Test A08 (Identical Items)";
        }
        totalTests++;
        if (testAlgoA09NontrivialChoice()) {
            System.out.println("[PASS] Test A09 (Non-trivial Choice)");
        } else {
            System.out.println("[FAIL] Test A09 (Non-trivial Choice)");
            failedTests[failedCount++] = "Test A09 (Non-trivial Choice)";
        }
        totalTests++;
        if (testAlgoA10StressMaxValue()) {
            System.out.println("[PASS] Test A10 (Stress Max Value 50 items)");
        } else {
            System.out.println("[FAIL] Test A10 (Stress Max Value 50 items)");
            failedTests[failedCount++] = "Test A10 (Stress Max Value 50 items)";
        }

        System.out.println();
        System.out.println("--- Algorithm B: Item Selection ---");
        totalTests++;
        if (testAlgoB01SelectSingle()) {
            System.out.println("[PASS] Test B01 (Selection: Single Item)");
        } else {
            System.out.println("[FAIL] Test B01 (Selection: Single Item)");
            failedTests[failedCount++] = "Test B01 (Selection: Single Item)";
        }
        totalTests++;
        if (testAlgoB02SelectBetterSingle()) {
            System.out.println("[PASS] Test B02 (Selection: Pick Better Single)");
        } else {
            System.out.println("[FAIL] Test B02 (Selection: Pick Better Single)");
            failedTests[failedCount++] = "Test B02 (Selection: Pick Better Single)";
        }
        totalTests++;
        if (testAlgoB03SelectClassicSmall()) {
            System.out.println("[PASS] Test B03 (Selection: Classic Small)");
        } else {
            System.out.println("[FAIL] Test B03 (Selection: Classic Small)");
            failedTests[failedCount++] = "Test B03 (Selection: Classic Small)";
        }
        totalTests++;
        if (testAlgoB04SelectGreedyTrap()) {
            System.out.println("[PASS] Test B04 (Selection: Greedy Trap)");
        } else {
            System.out.println("[FAIL] Test B04 (Selection: Greedy Trap)");
            failedTests[failedCount++] = "Test B04 (Selection: Greedy Trap)";
        }
        totalTests++;
        if (testAlgoB05SelectZeroCapacity()) {
            System.out.println("[PASS] Test B05 (Selection: Zero Capacity)");
        } else {
            System.out.println("[FAIL] Test B05 (Selection: Zero Capacity)");
            failedTests[failedCount++] = "Test B05 (Selection: Zero Capacity)";
        }
        totalTests++;
        if (testAlgoB06SelectTooHeavy()) {
            System.out.println("[PASS] Test B06 (Selection: Single Too Heavy)");
        } else {
            System.out.println("[FAIL] Test B06 (Selection: Single Too Heavy)");
            failedTests[failedCount++] = "Test B06 (Selection: Single Too Heavy)";
        }
        totalTests++;
        if (testAlgoB07SelectAllFit()) {
            System.out.println("[PASS] Test B07 (Selection: All Items Fit)");
        } else {
            System.out.println("[FAIL] Test B07 (Selection: All Items Fit)");
            failedTests[failedCount++] = "Test B07 (Selection: All Items Fit)";
        }
        totalTests++;
        if (testAlgoB08WeightInvariantGreedyTrap()) {
            System.out.println("[PASS] Test B08 (Invariant: Weight <= Capacity)");
        } else {
            System.out.println("[FAIL] Test B08 (Invariant: Weight <= Capacity)");
            failedTests[failedCount++] = "Test B08 (Invariant: Weight <= Capacity)";
        }
        totalTests++;
        if (testAlgoB09ValueInvariantGreedyTrap()) {
            System.out.println("[PASS] Test B09 (Invariant: Value == maxValue)");
        } else {
            System.out.println("[FAIL] Test B09 (Invariant: Value == maxValue)");
            failedTests[failedCount++] = "Test B09 (Invariant: Value == maxValue)";
        }
        totalTests++;
        if (testAlgoB10StressInvariants()) {
            System.out.println("[PASS] Test B10 (Stress Invariants 50 items)");
        } else {
            System.out.println("[FAIL] Test B10 (Stress Invariants 50 items)");
            failedTests[failedCount++] = "Test B10 (Stress Invariants 50 items)";
        }

        System.out.println();
        System.out.println("=== BENCHMARK RESULTS ===");
        System.out.println("Completed " + totalTests + " tests.");

        if (failedCount == 0) {
            System.out.println("All tests passed!");
            System.exit(0);
        }

        System.out.println("Tests that failed (" + failedCount + "):");
        for (int i = 0; i < failedCount; i++) {
            System.out.println(" - " + failedTests[i]);
        }
        System.exit(1);
    }
}
