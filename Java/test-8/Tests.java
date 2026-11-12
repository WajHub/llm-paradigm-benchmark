import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public final class Tests {
    private static final TspApprox TSP = new TspApproxImpl();

    private Tests() {
    }

    // ========================================================================
    // Fixtures (index order matters)
    // ========================================================================

    private static int[][] empty() {
        return new int[0][];
    }

    private static int[][] single() {
        return new int[][]{{5, 5}};
    }

    private static int[][] two() {
        return new int[][]{{0, 0}, {3, 4}};
    }

    private static int[][] collinear() {
        return new int[][]{{0, 0}, {4, 0}, {1, 0}, {9, 0}, {6, 0}};
    }

    private static int[][] square() {
        return new int[][]{{0, 0}, {0, 2}, {2, 2}, {2, 0}};
    }

    private static int[][] parentTie() {
        return new int[][]{{2, 0}, {0, 3}, {2, 3}, {3, 4}, {1, 4}};
    }

    private static int[][] grid() {
        return new int[][]{{0, 0}, {1, 0}, {2, 0}, {0, 1}, {1, 1}, {2, 1}, {0, 2}, {1, 2}, {2, 2}};
    }

    private static int[][] dup() {
        return new int[][]{{3, 3}, {3, 3}, {0, 0}, {3, 3}};
    }

    private static int[][] star() {
        return new int[][]{{5, 5}, {5, 0}, {0, 5}, {10, 5}};
    }

    private static int[][] clusters() {
        return new int[][]{{0, 0}, {20, 0}, {1, 1}, {21, 1}, {0, 20}, {20, 20}, {1, 21}, {21, 21}};
    }

    private static int[][] spiral() {
        return new int[][]{{0, 0}, {8, 0}, {8, 8}, {0, 8}, {2, 2}, {6, 2}, {6, 6}, {2, 6}, {4, 4}};
    }

    private static int[][] s12() {
        return new int[][]{{81, 33}, {69, 61}, {56, 93}, {77, 0}, {65, 25}, {72, 14}, {14, 48}, {33, 32},
            {73, 63}, {71, 87}, {5, 8}, {54, 24}};
    }

    private static int[][] s20() {
        return new int[][]{{38, 58}, {13, 15}, {51, 27}, {10, 19}, {12, 86}, {49, 67}, {84, 60}, {25, 43},
            {89, 83}, {37, 66}, {66, 78}, {95, 11}, {67, 54}, {31, 45}, {82, 36}, {24, 5}, {94, 2}, {51, 67},
            {54, 53}, {61, 96}};
    }

    private static int[][] s40() {
        return new int[][]{{81, 33}, {69, 61}, {56, 93}, {77, 0}, {65, 25}, {72, 14}, {14, 48}, {33, 32},
            {73, 63}, {71, 87}, {5, 8}, {54, 24}, {22, 71}, {51, 45}, {55, 89}, {29, 78}, {87, 65}, {32, 67},
            {53, 10}, {27, 83}, {36, 30}, {41, 96}, {2, 37}, {8, 85}, {78, 74}, {59, 59}, {76, 26}, {9, 63},
            {63, 86}, {7, 17}, {91, 65}, {27, 22}, {7, 85}, {95, 32}, {35, 71}, {7, 65}, {12, 61}, {82, 60},
            {5, 35}, {74, 66}};
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private static int dist(int[][] pts, int i, int j) {
        return Math.abs(pts[i][0] - pts[j][0]) + Math.abs(pts[i][1] - pts[j][1]);
    }

    /** Valid = permutation of 0..n-1, starts with 0, length n, cost equals the recomputed closed-tour cost. */
    private static boolean validTour(TspApprox.TourResult r, int[][] pts) {
        if (r == null || r.tour == null) {
            return false;
        }
        int n = pts.length;
        if (r.tour.length != n || n == 0 || r.tour[0] != 0) {
            return false;
        }
        boolean[] seen = new boolean[n];
        for (int v : r.tour) {
            if (v < 0 || v >= n || seen[v]) {
                return false;
            }
            seen[v] = true;
        }
        long cost = 0;
        for (int i = 0; i < n; i++) {
            cost += dist(pts, r.tour[i], r.tour[(i + 1) % n]);
        }
        return cost == r.cost;
    }

    private static boolean doubleTreeCase(int[][] pts, int[] expTour, int expCost, int expMst) {
        TspApprox.TourResult r = TSP.doubleTree(pts);
        return r != null && Arrays.equals(r.tour, expTour) && r.cost == expCost
            && TSP.mstWeight(pts) == expMst;
    }

    // ========================================================================
    // Algorithm A: MST Double Tree
    // ========================================================================

    private static boolean testAlgoA01Empty() {
        try {
            return TSP.mstWeight(empty()) == 0 && TSP.doubleTree(empty()) == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SinglePoint() {
        try {
            return doubleTreeCase(single(), new int[]{0}, 0, 0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03TwoPoints() {
        try {
            return doubleTreeCase(two(), new int[]{0, 1}, 14, 7);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04CollinearUnsorted() {
        try {
            return doubleTreeCase(collinear(), new int[]{0, 2, 1, 4, 3}, 18, 9);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05Square() {
        try {
            return doubleTreeCase(square(), new int[]{0, 1, 2, 3}, 8, 6);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06ParentTieBreaking() {
        try {
            return doubleTreeCase(parentTie(), new int[]{0, 2, 1, 4, 3}, 14, 9);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07GridTies() {
        try {
            return doubleTreeCase(grid(), new int[]{0, 1, 2, 5, 8, 4, 7, 3, 6}, 12, 8);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08DuplicatePoints() {
        try {
            return doubleTreeCase(dup(), new int[]{0, 1, 2, 3}, 12, 6);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09ClustersTwoApprox() {
        try {
            TspApprox.TourResult r = TSP.doubleTree(clusters());
            return doubleTreeCase(clusters(), new int[]{0, 1, 3, 5, 7, 2, 4, 6}, 128, 68)
                && r != null && r.cost <= 2 * 88;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            int[][] pts = s40();
            TspApprox.TourResult r = TSP.doubleTree(pts);
            return TSP.mstWeight(pts) == 503 && validTour(r, pts) && r.cost == 832;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: Christofides
    // ========================================================================

    private static boolean testAlgoB01Empty() {
        try {
            return TSP.matchingWeight(empty()) == 0 && TSP.christofides(empty()) == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02TwoPointsDoubleEdge() {
        try {
            int[][] pts = two();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 7 && validTour(r, pts)
                && Arrays.equals(r.tour, new int[]{0, 1}) && r.cost == 14;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03StarParallelEdges() {
        try {
            int[][] pts = star();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 15 && validTour(r, pts) && r.cost == 30;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04Collinear() {
        try {
            int[][] pts = collinear();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 9 && validTour(r, pts) && r.cost == 18;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05Grid() {
        try {
            int[][] pts = grid();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 4 && validTour(r, pts) && r.cost <= 12;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06BeatsDoubleTree() {
        try {
            int[][] pts = clusters();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 24 && validTour(r, pts) && r.cost <= 92;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07SpiralBound() {
        try {
            int[][] pts = spiral();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 20 && validTour(r, pts)
                && r.cost <= 52 && 2 * r.cost <= 3 * 44;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08GreedyMatchingTrap() {
        try {
            int[][] pts = s12();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 163 && validTour(r, pts)
                && r.cost <= 440 && 2 * r.cost <= 3 * 396;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09DuplicatePoints() {
        try {
            int[][] pts = dup();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 6 && validTour(r, pts) && r.cost == 12;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10Stress() {
        try {
            int[][] pts = s20();
            TspApprox.TourResult r = TSP.christofides(pts);
            return TSP.matchingWeight(pts) == 211 && validTour(r, pts)
                && r.cost <= 608 && 2 * r.cost <= 3 * 540;
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
        System.out.println("--- Algorithm A: MST Double Tree ---");
        runTest("Test A01 (Empty)", testAlgoA01Empty(), failed);
        runTest("Test A02 (Single Point)", testAlgoA02SinglePoint(), failed);
        runTest("Test A03 (Two Points)", testAlgoA03TwoPoints(), failed);
        runTest("Test A04 (Collinear Unsorted)", testAlgoA04CollinearUnsorted(), failed);
        runTest("Test A05 (Square)", testAlgoA05Square(), failed);
        runTest("Test A06 (Parent Tie Breaking)", testAlgoA06ParentTieBreaking(), failed);
        runTest("Test A07 (Grid Ties)", testAlgoA07GridTies(), failed);
        runTest("Test A08 (Duplicate Points)", testAlgoA08DuplicatePoints(), failed);
        runTest("Test A09 (Clusters Two Approx)", testAlgoA09ClustersTwoApprox(), failed);
        runTest("Test A10 (Stress)", testAlgoA10Stress(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Christofides ---");
        runTest("Test B01 (Empty)", testAlgoB01Empty(), failed);
        runTest("Test B02 (Two Points Double Edge)", testAlgoB02TwoPointsDoubleEdge(), failed);
        runTest("Test B03 (Star Parallel Edges)", testAlgoB03StarParallelEdges(), failed);
        runTest("Test B04 (Collinear)", testAlgoB04Collinear(), failed);
        runTest("Test B05 (Grid)", testAlgoB05Grid(), failed);
        runTest("Test B06 (Beats Double Tree)", testAlgoB06BeatsDoubleTree(), failed);
        runTest("Test B07 (Spiral Bound)", testAlgoB07SpiralBound(), failed);
        runTest("Test B08 (Greedy Matching Trap)", testAlgoB08GreedyMatchingTrap(), failed);
        runTest("Test B09 (Duplicate Points)", testAlgoB09DuplicatePoints(), failed);
        runTest("Test B10 (Stress)", testAlgoB10Stress(), failed);

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
