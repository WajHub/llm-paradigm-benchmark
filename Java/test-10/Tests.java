import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.LongUnaryOperator;

public final class Tests {
    private static final OrderStats OS = new OrderStatsImpl();

    private Tests() {
    }

    // ========================================================================
    // Helpers: Algorithm A
    // ========================================================================

    /** A10 generator: LCG seed 42, r = x div 65536, xs[i] = (r mod 20001) - 10000. */
    private static int[] stressValues() {
        int[] xs = new int[5000];
        long x = 42;
        for (int i = 0; i < xs.length; i++) {
            x = (x * 1103515245L + 12345L) % 2147483648L;
            long r = x / 65536L;
            xs[i] = (int) (r % 20001L) - 10000;
        }
        return xs;
    }

    private static boolean sel(int[] xs, int k, int value, int... pivots) {
        OrderStats.SelectResult r = OS.selectKth(xs, k);
        return r != null && r.value == value && r.pivots != null && Arrays.equals(r.pivots, pivots);
    }

    private static boolean mom(int[] xs, int expected) {
        Integer m = OS.medianOfMedians(xs);
        return m != null && m == expected;
    }

    // ========================================================================
    // Helpers: Algorithm B (counting probe)
    // ========================================================================

    /** Thrown by the probe when the read budget is exceeded or an index is out of range. */
    private static final class ProbeViolation extends RuntimeException {
        private static final long serialVersionUID = 1L;

        ProbeViolation(String msg) {
            super(msg);
        }
    }

    /** Shared read counter for both sources of one call. */
    private static final class Budget {
        final long limit;
        long reads = 0;
        boolean violated = false;

        Budget(long limit) {
            this.limit = limit;
        }
    }

    private static final class Probe implements OrderStats.SortedSource {
        private final int len;
        private final LongUnaryOperator f;
        private final Budget budget;

        Probe(int len, LongUnaryOperator f, Budget budget) {
            this.len = len;
            this.f = f;
            this.budget = budget;
        }

        @Override
        public int length() {
            return len;
        }

        @Override
        public int get(int index) {
            budget.reads++;
            if (index < 0 || index >= len) {
                budget.violated = true;
                throw new ProbeViolation("index out of range: " + index + " (length " + len + ")");
            }
            if (budget.reads > budget.limit) {
                budget.violated = true;
                throw new ProbeViolation("read budget exceeded: " + budget.limit);
            }
            return (int) f.applyAsLong(index);
        }
    }

    private static int bitlen(long x) {
        return 64 - Long.numberOfLeadingZeros(x);
    }

    private static long budgetFor(long m, long n) {
        return 16L * (bitlen(m + n) + 1);
    }

    private static LongUnaryOperator arr(int... values) {
        return i -> values[(int) i];
    }

    /**
     * Runs medianTwoSorted on two probes sharing one budget. expected == null means "absent".
     * Also checks that the budget formula gives the budget listed in the spec.
     */
    private static boolean median(int m, LongUnaryOperator fa, int n, LongUnaryOperator fb,
                                  Double expected, long specBudget) {
        long limit = budgetFor(m, n);
        if (limit != specBudget) {
            return false;
        }
        Budget budget = new Budget(limit);
        Double r = OS.medianTwoSorted(new Probe(m, fa, budget), new Probe(n, fb, budget));
        if (budget.violated || budget.reads > limit) {
            return false;
        }
        if (expected == null) {
            return r == null;
        }
        return r != null && Math.abs(r - expected) < 1e-9;
    }

    private static boolean medianSmall(int[] a, int[] b, Double expected, long specBudget) {
        return median(a.length, arr(a), b.length, arr(b), expected, specBudget);
    }

    // ========================================================================
    // Algorithm A: Median of Medians
    // ========================================================================

    private static boolean testAlgoA01Empty() {
        try {
            return OS.medianOfMedians(new int[0]) == null && OS.selectKth(new int[0], 0) == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02Single() {
        try {
            int[] xs = {7};
            return mom(xs, 7) && sel(xs, 0, 7) && OS.selectKth(xs, 1) == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03OutOfRange() {
        try {
            int[] xs = {3, 1, 2};
            return OS.selectKth(xs, 3) == null && OS.selectKth(xs, -1) == null
                && sel(xs, 2, 3) && mom(xs, 2);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04OneGroup() {
        try {
            int[] xs = {9, 1, 8, 2, 7};
            return mom(xs, 7) && sel(xs, 0, 1) && sel(xs, 2, 7) && sel(xs, 4, 9);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05PivotIsNotMedian() {
        try {
            int[] xs = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
            return mom(xs, 3) && sel(xs, 4, 5, 3, 6) && sel(xs, 5, 6, 3, 6);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06PartialLastGroup() {
        try {
            int[] xs = {5, 3, 9, 1, 8, 2, 6};
            return mom(xs, 2) && sel(xs, 3, 5, 2) && sel(xs, 6, 9, 2);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07ManyDuplicates() {
        try {
            int[] xs = {5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5};
            return mom(xs, 5) && sel(xs, 0, 1, 5) && sel(xs, 5, 5, 5) && sel(xs, 10, 9, 5);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08StablePartitionOrder() {
        try {
            int[] xs = {40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27};
            return mom(xs, 40) && sel(xs, 6, 51, 40, 41, 51);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09AllRanks() {
        try {
            int[] original = {12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14};
            int[] xs = original.clone();
            int[] sorted = {-30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41};
            if (!mom(xs, 3)) {
                return false;
            }
            for (int k = 0; k < 23; k++) {
                int[] pivots = k <= 6 ? new int[]{3, -11} : (k <= 11 ? new int[]{3} : new int[]{3, 14});
                if (!sel(xs, k, sorted[k], pivots)) {
                    return false;
                }
            }
            return Arrays.equals(xs, original);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            int[] xs = stressValues();
            return mom(xs, -1678)
                && sel(xs, 0, -9996, -1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995)
                && sel(xs, 2499, -1694, -1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694)
                && sel(xs, 4999, 9984, -1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974);
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: Median of Two Sorted Arrays
    // ========================================================================

    private static boolean testAlgoB01BothEmpty() {
        try {
            return medianSmall(new int[0], new int[0], null, 16);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02OneEmpty() {
        try {
            return medianSmall(new int[0], new int[]{1, 2, 3, 4}, 2.5, 64);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03SingleEach() {
        try {
            return medianSmall(new int[]{1}, new int[]{2}, 1.5, 48);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04OddTotalInterleaved() {
        try {
            return medianSmall(new int[]{1, 3, 5}, new int[]{2, 4}, 3.0, 64);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05DisjointRanges() {
        try {
            return medianSmall(new int[]{10, 11, 12, 13}, new int[]{1, 2, 3}, 10.0, 64);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06Duplicates() {
        try {
            return medianSmall(new int[]{1, 1, 1, 1}, new int[]{1, 1, 2}, 1.0, 64);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07NoOverflow() {
        try {
            return medianSmall(new int[]{2147483647}, new int[]{2147483647}, 2147483647.0, 48)
                && medianSmall(new int[]{-2147483648, 2147483647}, new int[0], -0.5, 48);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08HugeInterleaved() {
        try {
            return median(1000000000, i -> 2L * i - 1000000000L,
                999999999, j -> 2L * j - 999999999L, -1.0, 512);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09HugeUnbalanced() {
        try {
            return median(3, arr(-5, 0, 7),
                2000000000, j -> j / 2L - 500000000L, 0.0, 512);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10HugeDuplicates() {
        try {
            return median(1500000000, i -> i / 1000000L,
                600000000, j -> 700L + j / 3000000L, 787.0, 512);
        } catch (Exception e) {
            return false;
        }
    }

    private static int totalTests = 0;

    private static void runTest(String name, boolean passed, List<String> failed) {
        totalTests++;
        if (passed) {
            System.out.println("[PASS] " + name);
        } else {
            System.out.println("[FAIL] " + name);
            failed.add(name);
        }
    }

    public static void main(String[] args) {
        List<String> failed = new ArrayList<>();

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Median of Medians ---");
        runTest("Test A01 (Empty)", testAlgoA01Empty(), failed);
        runTest("Test A02 (Single)", testAlgoA02Single(), failed);
        runTest("Test A03 (Out Of Range)", testAlgoA03OutOfRange(), failed);
        runTest("Test A04 (One Group)", testAlgoA04OneGroup(), failed);
        runTest("Test A05 (Pivot Is Not Median)", testAlgoA05PivotIsNotMedian(), failed);
        runTest("Test A06 (Partial Last Group)", testAlgoA06PartialLastGroup(), failed);
        runTest("Test A07 (Many Duplicates)", testAlgoA07ManyDuplicates(), failed);
        runTest("Test A08 (Stable Partition Order)", testAlgoA08StablePartitionOrder(), failed);
        runTest("Test A09 (All Ranks)", testAlgoA09AllRanks(), failed);
        runTest("Test A10 (Stress)", testAlgoA10Stress(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Median of Two Sorted Arrays ---");
        runTest("Test B01 (Both Empty)", testAlgoB01BothEmpty(), failed);
        runTest("Test B02 (One Empty)", testAlgoB02OneEmpty(), failed);
        runTest("Test B03 (Single Each)", testAlgoB03SingleEach(), failed);
        runTest("Test B04 (Odd Total Interleaved)", testAlgoB04OddTotalInterleaved(), failed);
        runTest("Test B05 (Disjoint Ranges)", testAlgoB05DisjointRanges(), failed);
        runTest("Test B06 (Duplicates)", testAlgoB06Duplicates(), failed);
        runTest("Test B07 (No Overflow)", testAlgoB07NoOverflow(), failed);
        runTest("Test B08 (Huge Interleaved)", testAlgoB08HugeInterleaved(), failed);
        runTest("Test B09 (Huge Unbalanced)", testAlgoB09HugeUnbalanced(), failed);
        runTest("Test B10 (Huge Duplicates)", testAlgoB10HugeDuplicates(), failed);

        System.out.println();
        System.out.println("=== BENCHMARK RESULTS ===");
        System.out.println("Completed " + totalTests + " tests.");

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
