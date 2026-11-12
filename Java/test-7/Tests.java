import java.util.ArrayList;
import java.util.List;

public final class Tests {
    private static final SequenceAlignment SA = new SequenceAlignmentImpl();

    private Tests() {
    }

    // ========================================================================
    // Fixtures (stress strings: LCG seed 42, "ACGT"[r mod 4], 120 + 110 outputs)
    // ========================================================================

    private static final String STRESS_A =
        "CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA";
    private static final String STRESS_B =
        "GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC";

    // ========================================================================
    // Helpers
    // ========================================================================

    private static String removeGaps(String s) {
        return s.replace("-", "");
    }

    /** Score of an alignment by definition: columns + maximal gap runs. Returns null if malformed. */
    private static Integer scoreOf(String sa, String sb, int m, int x, int o, int e) {
        if (sa.length() != sb.length()) {
            return null;
        }
        int s = 0;
        for (int k = 0; k < sa.length(); k++) {
            char ca = sa.charAt(k);
            char cb = sb.charAt(k);
            if (ca == '-' && cb == '-') {
                return null;
            }
            if (ca != '-' && cb != '-') {
                s += (ca == cb) ? m : -x;
            }
        }
        for (String row : new String[]{sa, sb}) {
            int k = 0;
            while (k < row.length()) {
                if (row.charAt(k) == '-') {
                    int len = 0;
                    while (k < row.length() && row.charAt(k) == '-') {
                        len++;
                        k++;
                    }
                    s -= o + len * e;
                } else {
                    k++;
                }
            }
        }
        return s;
    }

    /** All invariants of an alignment result: score, equal lengths, gap removal, no '-'/'-', recomputed score. */
    private static boolean validAlignment(SequenceAlignment.AlignResult r, String a, String b,
                                          int m, int x, int o, int e, int expectedScore) {
        if (r == null || r.alignedA == null || r.alignedB == null) {
            return false;
        }
        if (r.score != expectedScore || r.alignedA.length() != r.alignedB.length()) {
            return false;
        }
        if (!removeGaps(r.alignedA).equals(a) || !removeGaps(r.alignedB).equals(b)) {
            return false;
        }
        Integer recomputed = scoreOf(r.alignedA, r.alignedB, m, x, o, e);
        return recomputed != null && recomputed == expectedScore;
    }

    private static boolean exactAlignment(String a, String b, int m, int x, int o, int e,
                                          int expectedScore, String expA, String expB) {
        SequenceAlignment.AlignResult r = SA.align(a, b, m, x, o, e);
        return validAlignment(r, a, b, m, x, o, e, expectedScore)
            && r.alignedA.equals(expA) && r.alignedB.equals(expB);
    }

    private static boolean invariantAlignment(String a, String b, int m, int x, int o, int e,
                                              int expectedScore) {
        SequenceAlignment.AlignResult r = SA.align(a, b, m, x, o, e);
        return validAlignment(r, a, b, m, x, o, e, expectedScore);
    }

    // ========================================================================
    // Algorithm A: Alignment Score
    // ========================================================================

    private static boolean testAlgoA01BothEmpty() {
        try {
            return SA.alignmentScore("", "", 1, 1, 2, 1) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02OneEmpty() {
        try {
            return SA.alignmentScore("", "ACG", 1, 1, 2, 1) == -5;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03Identical() {
        try {
            return SA.alignmentScore("GATTACA", "GATTACA", 2, 1, 3, 1) == 14;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04MismatchBeatsGaps() {
        try {
            return SA.alignmentScore("A", "C", 1, 1, 2, 1) == -1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05Textbook() {
        try {
            return SA.alignmentScore("GATTACA", "GCATGCU", 1, 1, 1, 1) == -1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06OneLongGap() {
        try {
            return SA.alignmentScore("AAAGGGTTT", "AAATTT", 2, 2, 5, 1) == 4;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07ZeroExtend() {
        try {
            return SA.alignmentScore("TTACGGA", "ACG", 2, 2, 2, 0) == 2;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08AdjacentGapsBeatMismatch() {
        try {
            return SA.alignmentScore("XAY", "XCY", 1, 10, 1, 1) == -2;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09TerminalGapsPenalized() {
        try {
            return SA.alignmentScore("AAAACCCC", "CCCC", 2, 1, 3, 1) == 1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            return SA.alignmentScore(STRESS_A, STRESS_B, 2, 1, 3, 1) == 16;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: Alignment Reconstruction
    // ========================================================================

    private static boolean testAlgoB01BothEmpty() {
        try {
            return exactAlignment("", "", 1, 1, 2, 1, 0, "", "");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02SecondEmpty() {
        try {
            return exactAlignment("ACG", "", 1, 1, 2, 1, -5, "ACG", "---");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03Identical() {
        try {
            return exactAlignment("GATTACA", "GATTACA", 2, 1, 3, 1, 14, "GATTACA", "GATTACA");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04UniqueLongGap() {
        try {
            return exactAlignment("AAAGGGTTT", "AAATTT", 2, 2, 5, 1, 4, "AAAGGGTTT", "AAA---TTT");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05AdjacentGaps() {
        try {
            return invariantAlignment("XAY", "XCY", 1, 10, 1, 1, -2);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06TextbookUnique() {
        try {
            return exactAlignment("GATTACA", "GCATGCU", 1, 1, 1, 1, -1, "GATTACA", "GCATGCU");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07GapMerging() {
        try {
            return exactAlignment("ACCCGT", "AGT", 2, 3, 6, 1, -3, "ACCCGT", "A---GT");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08GapsInBothRows() {
        try {
            return exactAlignment("CACGCA", "AGGCGC", 3, 2, 3, 1, -1, "CA--CGCA", "-AGGCGC-");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09TiedGapPositions() {
        try {
            return invariantAlignment("AAAA", "AA", 1, 1, 1, 1, -1);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressInvariants() {
        try {
            return invariantAlignment(STRESS_A, STRESS_B, 3, 2, 5, 1, 10);
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
        System.out.println("--- Algorithm A: Alignment Score ---");
        runTest("Test A01 (Both Empty)", testAlgoA01BothEmpty(), failed);
        runTest("Test A02 (One Empty)", testAlgoA02OneEmpty(), failed);
        runTest("Test A03 (Identical)", testAlgoA03Identical(), failed);
        runTest("Test A04 (Mismatch Beats Gaps)", testAlgoA04MismatchBeatsGaps(), failed);
        runTest("Test A05 (Textbook)", testAlgoA05Textbook(), failed);
        runTest("Test A06 (One Long Gap)", testAlgoA06OneLongGap(), failed);
        runTest("Test A07 (Zero Extend)", testAlgoA07ZeroExtend(), failed);
        runTest("Test A08 (Adjacent Gaps Beat Mismatch)", testAlgoA08AdjacentGapsBeatMismatch(), failed);
        runTest("Test A09 (Terminal Gaps Penalized)", testAlgoA09TerminalGapsPenalized(), failed);
        runTest("Test A10 (Stress)", testAlgoA10Stress(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Alignment Reconstruction ---");
        runTest("Test B01 (Both Empty)", testAlgoB01BothEmpty(), failed);
        runTest("Test B02 (Second Empty)", testAlgoB02SecondEmpty(), failed);
        runTest("Test B03 (Identical)", testAlgoB03Identical(), failed);
        runTest("Test B04 (Unique Long Gap)", testAlgoB04UniqueLongGap(), failed);
        runTest("Test B05 (Adjacent Gaps)", testAlgoB05AdjacentGaps(), failed);
        runTest("Test B06 (Textbook Unique)", testAlgoB06TextbookUnique(), failed);
        runTest("Test B07 (Gap Merging)", testAlgoB07GapMerging(), failed);
        runTest("Test B08 (Gaps In Both Rows)", testAlgoB08GapsInBothRows(), failed);
        runTest("Test B09 (Tied Gap Positions)", testAlgoB09TiedGapPositions(), failed);
        runTest("Test B10 (Stress Invariants)", testAlgoB10StressInvariants(), failed);

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
