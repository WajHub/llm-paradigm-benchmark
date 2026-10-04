import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public final class Tests {
    private static final Sudoku SUDOKU = new SudokuImpl();

    private Tests() {
    }

    // ========================================================================
    // Fixtures (row-major strings, '0' or '.' = empty)
    // ========================================================================

    private static final String CLASSIC_S =
        "530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079";
    private static final String SOLVED_S =
        "534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179";
    private static final String INKALA_S =
        "800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402";
    private static final String INKALA_SOL_S =
        "812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452";
    private static final String ANTI_BF_S =
        "000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009";
    private static final String ANTI_BF_SOL_S =
        "987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219";

    private static int[] grid(String s) {
        int[] g = new int[81];
        int i = 0;
        for (char ch : s.toCharArray()) {
            if (ch == '.') {
                g[i++] = 0;
            } else if (ch >= '0' && ch <= '9') {
                g[i++] = ch - '0';
            }
        }
        if (i != 81) {
            throw new IllegalStateException("bad fixture");
        }
        return g;
    }

    private static int[] empty() {
        return new int[81];
    }

    private static int[] classic() {
        return grid(CLASSIC_S);
    }

    private static int[] solved() {
        return grid(SOLVED_S);
    }

    private static int[] with(int[] g, int row, int col, int value) {
        int[] copy = g.clone();
        copy[row * 9 + col] = value;
        return copy;
    }

    private static int[] boxConflict() {
        return with(classic(), 1, 1, 8);
    }

    private static int[] boxConflict2() {
        return with(with(empty(), 0, 0, 1), 1, 1, 1);
    }

    private static int[] rowConflict() {
        return with(classic(), 0, 8, 5);
    }

    private static int[] colConflict() {
        return with(classic(), 8, 0, 5);
    }

    private static int[] deadCell() {
        int[] g = empty();
        for (int c = 0; c < 8; c++) {
            g[c] = c + 1;
        }
        g[4 * 9 + 8] = 9;
        return g;
    }

    private static int[] hidden() {
        return with(classic(), 0, 2, 1);
    }

    private static int[] multi() {
        return with(classic(), 2, 2, 0);
    }

    private static boolean candEquals(int[] actual, int... expected) {
        return actual != null && Arrays.equals(actual, expected);
    }

    // ========================================================================
    // Algorithm A: Validation and Candidates
    // ========================================================================

    private static boolean testAlgoA01EmptyGridValid() {
        try {
            return SUDOKU.isValid(empty());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SolvedGridValid() {
        try {
            return SUDOKU.isValid(solved()) && SUDOKU.isValid(classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03RowConflict() {
        try {
            return !SUDOKU.isValid(rowConflict()) && SUDOKU.isValid(classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04ColumnConflict() {
        try {
            return !SUDOKU.isValid(colConflict()) && SUDOKU.isValid(classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05BoxOnlyConflict() {
        try {
            return !SUDOKU.isValid(boxConflict())
                && !SUDOKU.isValid(boxConflict2())
                && SUDOKU.isValid(classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06WrongLength() {
        try {
            int[] solvedPlus = Arrays.copyOf(solved(), 82);
            return !SUDOKU.isValid(new int[80])
                && !SUDOKU.isValid(new int[82])
                && !SUDOKU.isValid(solvedPlus)
                && SUDOKU.isValid(solved());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07ValueOutOfRange() {
        try {
            return !SUDOKU.isValid(with(classic(), 0, 2, 10))
                && !SUDOKU.isValid(with(classic(), 0, 2, -1))
                && SUDOKU.isValid(classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08CandidatesBasic() {
        try {
            int[] g = classic();
            return candEquals(SUDOKU.candidates(g, 0, 2), 1, 2, 4)
                && candEquals(SUDOKU.candidates(g, 4, 4), 5)
                && candEquals(SUDOKU.candidates(g, 8, 0), 1, 2, 3);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09CandidatesEdgeCells() {
        try {
            return candEquals(SUDOKU.candidates(classic(), 0, 0))
                && candEquals(SUDOKU.candidates(classic(), 8, 8))
                && candEquals(SUDOKU.candidates(empty(), 8, 8), 1, 2, 3, 4, 5, 6, 7, 8, 9);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10CandidatesSweep() {
        try {
            int[] s = solved();
            for (int r = 0; r < 9; r++) {
                for (int c = 0; c < 9; c++) {
                    int[] g = with(s, r, c, 0);
                    if (!candEquals(SUDOKU.candidates(g, r, c), s[r * 9 + c])) {
                        return false;
                    }
                }
            }
            int[] g = classic();
            int sum = 0;
            for (int r = 0; r < 9; r++) {
                for (int c = 0; c < 9; c++) {
                    int[] cand = SUDOKU.candidates(g, r, c);
                    if (cand == null) {
                        return false;
                    }
                    sum += cand.length;
                }
            }
            return sum == 153;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: Solving
    // ========================================================================

    private static boolean testAlgoB01AlreadySolved() {
        try {
            return Arrays.equals(SUDOKU.solve(solved()), solved());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02ClassicPuzzle() {
        try {
            int[] input = classic();
            int[] result = SUDOKU.solve(input);
            return Arrays.equals(result, solved()) && Arrays.equals(input, classic());
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03InvalidGrid() {
        try {
            return SUDOKU.solve(boxConflict()) == null
                && SUDOKU.solve(new int[80]) == null
                && SUDOKU.solve(with(classic(), 0, 2, 10)) == null
                && SUDOKU.countSolutions(boxConflict(), 5) == 0
                && SUDOKU.countSolutions(new int[80], 5) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04DeadCell() {
        try {
            return SUDOKU.solve(deadCell()) == null
                && SUDOKU.countSolutions(deadCell(), 5) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05HiddenContradiction() {
        try {
            return SUDOKU.solve(hidden()) == null
                && SUDOKU.countSolutions(hidden(), 5) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06BacktrackingRequired() {
        try {
            return Arrays.equals(SUDOKU.solve(grid(INKALA_S)), grid(INKALA_SOL_S));
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07CountUnique() {
        try {
            return SUDOKU.countSolutions(classic(), 2) == 1
                && SUDOKU.countSolutions(solved(), 2) == 1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08CountMultiple() {
        try {
            return SUDOKU.countSolutions(multi(), 100) == 8
                && SUDOKU.countSolutions(multi(), 5) == 5
                && SUDOKU.countSolutions(multi(), 1) == 1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09CountEmptyGridLimit() {
        try {
            return SUDOKU.countSolutions(empty(), 2) == 2
                && SUDOKU.countSolutions(empty(), 1) == 1
                && SUDOKU.countSolutions(empty(), 0) == 0
                && SUDOKU.countSolutions(empty(), -3) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressAntiBruteForce() {
        try {
            return Arrays.equals(SUDOKU.solve(grid(ANTI_BF_S)), grid(ANTI_BF_SOL_S));
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
        System.out.println("--- Algorithm A: Validation and Candidates ---");
        runTest("Test A01 (Empty Grid Valid)", testAlgoA01EmptyGridValid(), failed);
        runTest("Test A02 (Solved Grid Valid)", testAlgoA02SolvedGridValid(), failed);
        runTest("Test A03 (Row Conflict)", testAlgoA03RowConflict(), failed);
        runTest("Test A04 (Column Conflict)", testAlgoA04ColumnConflict(), failed);
        runTest("Test A05 (Box Only Conflict)", testAlgoA05BoxOnlyConflict(), failed);
        runTest("Test A06 (Wrong Length)", testAlgoA06WrongLength(), failed);
        runTest("Test A07 (Value Out Of Range)", testAlgoA07ValueOutOfRange(), failed);
        runTest("Test A08 (Candidates Basic)", testAlgoA08CandidatesBasic(), failed);
        runTest("Test A09 (Candidates Edge Cells)", testAlgoA09CandidatesEdgeCells(), failed);
        runTest("Test A10 (Candidates Sweep)", testAlgoA10CandidatesSweep(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Solving ---");
        runTest("Test B01 (Already Solved)", testAlgoB01AlreadySolved(), failed);
        runTest("Test B02 (Classic Puzzle)", testAlgoB02ClassicPuzzle(), failed);
        runTest("Test B03 (Invalid Grid)", testAlgoB03InvalidGrid(), failed);
        runTest("Test B04 (Dead Cell)", testAlgoB04DeadCell(), failed);
        runTest("Test B05 (Hidden Contradiction)", testAlgoB05HiddenContradiction(), failed);
        runTest("Test B06 (Backtracking Required)", testAlgoB06BacktrackingRequired(), failed);
        runTest("Test B07 (Count Unique)", testAlgoB07CountUnique(), failed);
        runTest("Test B08 (Count Multiple)", testAlgoB08CountMultiple(), failed);
        runTest("Test B09 (Count Empty Grid Limit)", testAlgoB09CountEmptyGridLimit(), failed);
        runTest("Test B10 (Stress Anti Brute Force)", testAlgoB10StressAntiBruteForce(), failed);

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
