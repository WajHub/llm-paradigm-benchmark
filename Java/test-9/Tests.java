import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

public final class Tests {
    private static final BTree BT = new BTreeImpl();

    private Tests() {
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private static final int[] TENS = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100};

    /** Generator G(seed, count, mod): LCG x = (x * 1103515245 + 12345) mod 2^31, output (x div 65536) mod mod. */
    private static int[] gen(long seed, int count, int mod) {
        int[] out = new int[count];
        long x = seed;
        for (int i = 0; i < count; i++) {
            x = (x * 1103515245L + 12345L) % 2147483648L;
            out[i] = (int) ((x / 65536L) % mod);
        }
        return out;
    }

    /** "(" + keys + ")" for a leaf; "(" + c0 + " " + k0 + " " + c1 + ... + ")" for an internal node. */
    private static String dump(BTree.Node x) {
        if (x == null) {
            return "NULL";
        }
        StringBuilder sb = new StringBuilder("(");
        if (x.children.isEmpty()) {
            for (int i = 0; i < x.keys.size(); i++) {
                if (i > 0) {
                    sb.append(' ');
                }
                sb.append(x.keys.get(i));
            }
        } else {
            for (int i = 0; i < x.children.size(); i++) {
                if (i > 0) {
                    sb.append(' ').append(i - 1 < x.keys.size() ? String.valueOf(x.keys.get(i - 1)) : "?")
                        .append(' ');
                }
                sb.append(dump(x.children.get(i)));
            }
        }
        return sb.append(')').toString();
    }

    private static final class TreeInfo {
        int height = -1;
        int nodes = 0;
        final List<Integer> inorder = new ArrayList<>();
    }

    /** Validates all B-tree invariants; returns height/node count/in-order keys, or null if any invariant fails. */
    private static TreeInfo check(BTree.Node root, int t) {
        if (root == null) {
            return null;
        }
        TreeInfo info = new TreeInfo();
        if (!checkRec(root, t, 1, null, null, true, info)) {
            return null;
        }
        return info;
    }

    private static boolean checkRec(BTree.Node x, int t, int depth, Integer lo, Integer hi,
                                    boolean isRoot, TreeInfo info) {
        if (x == null || x.keys == null || x.children == null) {
            return false;
        }
        info.nodes++;
        int n = x.keys.size();
        if (n > 2 * t - 1) {
            return false;
        }
        if (!isRoot && n < t - 1) {
            return false;
        }
        for (int i = 0; i < n; i++) {
            Integer k = x.keys.get(i);
            if (k == null) {
                return false;
            }
            if (i > 0 && x.keys.get(i - 1) >= k) {
                return false;
            }
            if ((lo != null && k <= lo) || (hi != null && k >= hi)) {
                return false;
            }
        }
        if (x.children.isEmpty()) {
            if (info.height == -1) {
                info.height = depth;
            } else if (info.height != depth) {
                return false;
            }
            info.inorder.addAll(x.keys);
            return true;
        }
        if (n == 0 || x.children.size() != n + 1) {
            return false;
        }
        for (int i = 0; i <= n; i++) {
            Integer clo = i > 0 ? x.keys.get(i - 1) : lo;
            Integer chi = i < n ? x.keys.get(i) : hi;
            if (!checkRec(x.children.get(i), t, depth + 1, clo, chi, false, info)) {
                return false;
            }
            if (i < n) {
                info.inorder.add(x.keys.get(i));
            }
        }
        return true;
    }

    private static List<Integer> sortedDistinct(int[] keys) {
        TreeSet<Integer> s = new TreeSet<>();
        for (int k : keys) {
            s.add(k);
        }
        return new ArrayList<>(s);
    }

    private static List<Integer> sortedDifference(int[] keys, int[] removed) {
        TreeSet<Integer> s = new TreeSet<>();
        for (int k : keys) {
            s.add(k);
        }
        Set<Integer> r = new HashSet<>();
        for (int k : removed) {
            r.add(k);
        }
        s.removeAll(r);
        return new ArrayList<>(s);
    }

    private static long sum(List<Integer> xs) {
        long s = 0;
        for (int v : xs) {
            s += v;
        }
        return s;
    }

    private static boolean insertShape(int t, int[] keys, String expected) {
        BTree.Node r = BT.insertAll(t, keys);
        return check(r, t) != null && dump(r).equals(expected);
    }

    private static boolean deleteShape(int t, int[] keys, int[] dels, String expected) {
        int[] keysCopy = keys.clone();
        int[] delsCopy = dels.clone();
        BTree.Node r = BT.deleteAll(t, keysCopy, delsCopy);
        return check(r, t) != null && dump(r).equals(expected)
            && Arrays.equals(keysCopy, keys) && Arrays.equals(delsCopy, dels);
    }

    // ========================================================================
    // Algorithm A: Insertion
    // ========================================================================

    private static boolean testAlgoA01Empty() {
        try {
            return insertShape(2, new int[0], "()");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02InvalidDegree() {
        try {
            return BT.insertAll(1, new int[]{1, 2, 3}) == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03SingleLeaf() {
        try {
            return insertShape(3, new int[]{5, 1, 3}, "(1 3 5)");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04RootSplit() {
        try {
            return insertShape(2, new int[]{1, 2, 3, 4}, "((1) 2 (3 4))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05DuplicateOnFullRoot() {
        try {
            return insertShape(2, new int[]{1, 2, 3, 2}, "(1 2 3)");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06Ascending() {
        try {
            return insertShape(2, TENS.clone(), "(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07ProactiveSplit() {
        try {
            return insertShape(2, new int[]{10, 9, 8, 7, 6, 5, 4, 3, 2, 1},
                "(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08TextbookT3() {
        try {
            return insertShape(3,
                new int[]{8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18},
                "((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09Invariants() {
        try {
            int[] keys = gen(7, 100, 1000);
            TreeInfo info = check(BT.insertAll(3, keys), 3);
            List<Integer> expected = sortedDistinct(keys);
            return info != null && expected.size() == 95 && info.inorder.equals(expected)
                && info.height == 3 && info.nodes == 28;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            int[] keys = gen(42, 2000, 100000);
            BTree.Node r = BT.insertAll(4, keys);
            TreeInfo info = check(r, 4);
            List<Integer> expected = sortedDistinct(keys);
            return info != null && info.height == 5 && info.nodes == 413
                && r.keys.equals(Arrays.asList(15269))
                && info.inorder.equals(expected)
                && info.inorder.size() == 1937 && sum(info.inorder) == 31779629L;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: Deletion
    // ========================================================================

    private static boolean testAlgoB01DeleteFromLeaf() {
        try {
            return deleteShape(3, new int[]{5, 1, 3, 9, 7}, new int[]{3}, "(1 5 7 9)");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02AbsentKeyUnchanged() {
        try {
            return deleteShape(2, new int[]{10, 30, 20, 40}, new int[]{15}, "((10) 20 (30 40))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03DeleteAll() {
        try {
            return deleteShape(2, TENS.clone(), new int[]{50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999}, "()");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04PredecessorPreferred() {
        try {
            return deleteShape(2, new int[]{10, 20, 30, 40, 5}, new int[]{20}, "((5) 10 (30 40))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05Successor() {
        try {
            return deleteShape(2, new int[]{10, 20, 30, 40, 35}, new int[]{20}, "((10) 30 (35 40))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06MergeChildren() {
        try {
            return deleteShape(2, new int[]{14, 3, 4, 11, 5, 15}, new int[]{4}, "((3 5) 11 (14 15))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07BorrowLeftFirst() {
        try {
            return deleteShape(2, new int[]{21, 12, 9, 10, 17, 23, 24}, new int[]{17},
                "((9) 10 (12) 21 (23 24))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08MergeRightFirst() {
        try {
            return deleteShape(2, new int[]{3, 4, 19, 12, 7, 15, 22, 28}, new int[]{7},
                "((3) 4 (12 15) 19 (22 28))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09RootShrink() {
        try {
            return deleteShape(2, TENS.clone(), new int[]{10, 20}, "((30) 40 (50) 60 (70) 80 (90 100))");
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressInvariants() {
        try {
            int[] keys = gen(9, 300, 500);
            int[] dels = gen(3, 250, 500);
            BTree.Node r = BT.deleteAll(3, keys, dels);
            TreeInfo info = check(r, 3);
            List<Integer> expected = sortedDifference(keys, dels);
            return info != null && info.inorder.equals(expected)
                && info.inorder.size() == 150 && sum(info.inorder) == 39704L
                && info.height == 4 && info.nodes == 55
                && r.keys.equals(Arrays.asList(293));
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
        System.out.println("--- Algorithm A: Insertion ---");
        runTest("Test A01 (Empty)", testAlgoA01Empty(), failed);
        runTest("Test A02 (Invalid Degree)", testAlgoA02InvalidDegree(), failed);
        runTest("Test A03 (Single Leaf)", testAlgoA03SingleLeaf(), failed);
        runTest("Test A04 (Root Split)", testAlgoA04RootSplit(), failed);
        runTest("Test A05 (Duplicate On Full Root)", testAlgoA05DuplicateOnFullRoot(), failed);
        runTest("Test A06 (Ascending)", testAlgoA06Ascending(), failed);
        runTest("Test A07 (Proactive Split)", testAlgoA07ProactiveSplit(), failed);
        runTest("Test A08 (Textbook t3)", testAlgoA08TextbookT3(), failed);
        runTest("Test A09 (Invariants)", testAlgoA09Invariants(), failed);
        runTest("Test A10 (Stress)", testAlgoA10Stress(), failed);

        System.out.println();
        System.out.println("--- Algorithm B: Deletion ---");
        runTest("Test B01 (Delete From Leaf)", testAlgoB01DeleteFromLeaf(), failed);
        runTest("Test B02 (Absent Key Unchanged)", testAlgoB02AbsentKeyUnchanged(), failed);
        runTest("Test B03 (Delete All)", testAlgoB03DeleteAll(), failed);
        runTest("Test B04 (Predecessor Preferred)", testAlgoB04PredecessorPreferred(), failed);
        runTest("Test B05 (Successor)", testAlgoB05Successor(), failed);
        runTest("Test B06 (Merge Children)", testAlgoB06MergeChildren(), failed);
        runTest("Test B07 (Borrow Left First)", testAlgoB07BorrowLeftFirst(), failed);
        runTest("Test B08 (Merge Right First)", testAlgoB08MergeRightFirst(), failed);
        runTest("Test B09 (Root Shrink)", testAlgoB09RootShrink(), failed);
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
