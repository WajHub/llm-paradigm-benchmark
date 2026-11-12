import java.util.Arrays;

public final class Tests {
    private static final PalindromeTree PT = new PalindromeTreeImpl();

    private Tests() {
    }

    // ========================================================================
    // Algorithm A: eertreeBuild, eertreeCountDistinct, eertreeLongestLength
    // ========================================================================

    private static boolean testAlgoA01BasicAabaa() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 5) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 5) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02SingleChar() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("a", 1);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 1) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 1) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03AllSameChars() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aaaa", 4);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 4) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 4) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04NoInternalPalindromes() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("abcde", 5);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 5) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 1) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05EmptyString() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("", 0);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 0) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 0) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06NullInput() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild(null, 5);
            return t == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07TwoCharPalindrome() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aa", 2);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 2) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 2) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08Abacaba() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("abacaba", 7);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 7) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 7) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09Abba() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("abba", 4);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != 4) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != 4) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10NodeCountInvariant() {
        try {
            // For any string of length n: distinct palindromes <= n (mathematical theorem).
            // Also verify a specific known count.
            String[] cases = {"racecar", "aabbaa", "abcbaabcba", "zzzzzzzzz"};
            int[] lens = {7, 6, 10, 9};

            for (int i = 0; i < cases.length; i++) {
                PalindromeTree.Eertree t = PT.eertreeBuild(cases[i], lens[i]);
                if (t == null) {
                    return false;
                }
                int distinct = PT.eertreeCountDistinct(t);
                if (distinct > lens[i] || distinct <= 0) {
                    return false;
                }
            }

            PalindromeTree.Eertree t = PT.eertreeBuild("racecar", 7);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountDistinct(t) == 7;
        } catch (Exception e) {
            return false;
        }
    }

    // ========================================================================
    // Algorithm B: eertreeCountOccurrences
    // ========================================================================

    private static boolean testAlgoB01SingleCharOccurrences() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "a", 1) == 4;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02EvenPalindromeOccurrences() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "aa", 2) == 2;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03FullStringPalindrome() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "aabaa", 5) == 1;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04PatternNotInString() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "xyz", 3) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05PatternNotAPalindrome() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "ab", 2) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06OverlappingEvenPalindromes() {
        try {
            // "aaaa": "aa" appears 3 times (overlapping: [0..1],[1..2],[2..3])
            PalindromeTree.Eertree t = PT.eertreeBuild("aaaa", 4);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "aa", 2) == 3;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07AllSameSingleChar() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aaaa", 4);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "a", 1) == 4;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08RepeatedPalindrome() {
        try {
            // "abacaba": "aba" appears at [0..2] and [4..6] = 2 times
            PalindromeTree.Eertree t = PT.eertreeBuild("abacaba", 7);
            if (t == null) {
                return false;
            }
            return PT.eertreeCountOccurrences(t, "aba", 3) == 2;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09NullArguments() {
        try {
            PalindromeTree.Eertree t = PT.eertreeBuild("aabaa", 5);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountOccurrences(null, "a", 1) != 0) {
                passed = false;
            }
            if (PT.eertreeCountOccurrences(t, null, 1) != 0) {
                passed = false;
            }
            if (PT.eertreeCountOccurrences(t, "a", 0) != 0) {
                passed = false;
            }
            if (PT.eertreeCountOccurrences(null, null, 0) != 0) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressTest() {
        try {
            int n = 50000;
            char[] arr = new char[n];
            Arrays.fill(arr, 'a');
            String s = new String(arr);

            PalindromeTree.Eertree t = PT.eertreeBuild(s, n);
            if (t == null) {
                return false;
            }

            boolean passed = true;
            if (PT.eertreeCountDistinct(t) != n) {
                passed = false;
            }
            if (PT.eertreeLongestLength(t) != n) {
                passed = false;
            }
            if (PT.eertreeCountOccurrences(t, "a", 1) != n) {
                passed = false;
            }
            if (PT.eertreeCountOccurrences(t, "aa", 2) != n - 1) {
                passed = false;
            }
            return passed;
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
        System.out.println("--- Algorithm A: Palindrome Tree Construction & Structural Queries ---");
        total++;
        if (testAlgoA01BasicAabaa()) {
            System.out.println("[PASS] Test A01 (Basic - aabaa)");
        } else {
            System.out.println("[FAIL] Test A01 (Basic - aabaa)");
            failed.add("Test A01 (Basic - aabaa)");
        }
        total++;
        if (testAlgoA02SingleChar()) {
            System.out.println("[PASS] Test A02 (Single Char)");
        } else {
            System.out.println("[FAIL] Test A02 (Single Char)");
            failed.add("Test A02 (Single Char)");
        }
        total++;
        if (testAlgoA03AllSameChars()) {
            System.out.println("[PASS] Test A03 (All Same Chars - aaaa)");
        } else {
            System.out.println("[FAIL] Test A03 (All Same Chars - aaaa)");
            failed.add("Test A03 (All Same Chars - aaaa)");
        }
        total++;
        if (testAlgoA04NoInternalPalindromes()) {
            System.out.println("[PASS] Test A04 (No Internal Palindromes)");
        } else {
            System.out.println("[FAIL] Test A04 (No Internal Palindromes)");
            failed.add("Test A04 (No Internal Palindromes)");
        }
        total++;
        if (testAlgoA05EmptyString()) {
            System.out.println("[PASS] Test A05 (Empty String)");
        } else {
            System.out.println("[FAIL] Test A05 (Empty String)");
            failed.add("Test A05 (Empty String)");
        }
        total++;
        if (testAlgoA06NullInput()) {
            System.out.println("[PASS] Test A06 (NULL Input)");
        } else {
            System.out.println("[FAIL] Test A06 (NULL Input)");
            failed.add("Test A06 (NULL Input)");
        }
        total++;
        if (testAlgoA07TwoCharPalindrome()) {
            System.out.println("[PASS] Test A07 (Two-Char Palindrome - aa)");
        } else {
            System.out.println("[FAIL] Test A07 (Two-Char Palindrome - aa)");
            failed.add("Test A07 (Two-Char Palindrome - aa)");
        }
        total++;
        if (testAlgoA08Abacaba()) {
            System.out.println("[PASS] Test A08 (Classic - abacaba)");
        } else {
            System.out.println("[FAIL] Test A08 (Classic - abacaba)");
            failed.add("Test A08 (Classic - abacaba)");
        }
        total++;
        if (testAlgoA09Abba()) {
            System.out.println("[PASS] Test A09 (Even Palindrome - abba)");
        } else {
            System.out.println("[FAIL] Test A09 (Even Palindrome - abba)");
            failed.add("Test A09 (Even Palindrome - abba)");
        }
        total++;
        if (testAlgoA10NodeCountInvariant()) {
            System.out.println("[PASS] Test A10 (Node Count Invariant)");
        } else {
            System.out.println("[FAIL] Test A10 (Node Count Invariant)");
            failed.add("Test A10 (Node Count Invariant)");
        }

        System.out.println();
        System.out.println("--- Algorithm B: Occurrence Counting ---");
        total++;
        if (testAlgoB01SingleCharOccurrences()) {
            System.out.println("[PASS] Test B01 (Single Char Count)");
        } else {
            System.out.println("[FAIL] Test B01 (Single Char Count)");
            failed.add("Test B01 (Single Char Count)");
        }
        total++;
        if (testAlgoB02EvenPalindromeOccurrences()) {
            System.out.println("[PASS] Test B02 (Even Palindrome Count)");
        } else {
            System.out.println("[FAIL] Test B02 (Even Palindrome Count)");
            failed.add("Test B02 (Even Palindrome Count)");
        }
        total++;
        if (testAlgoB03FullStringPalindrome()) {
            System.out.println("[PASS] Test B03 (Full String Palindrome)");
        } else {
            System.out.println("[FAIL] Test B03 (Full String Palindrome)");
            failed.add("Test B03 (Full String Palindrome)");
        }
        total++;
        if (testAlgoB04PatternNotInString()) {
            System.out.println("[PASS] Test B04 (Pattern Not In String)");
        } else {
            System.out.println("[FAIL] Test B04 (Pattern Not In String)");
            failed.add("Test B04 (Pattern Not In String)");
        }
        total++;
        if (testAlgoB05PatternNotAPalindrome()) {
            System.out.println("[PASS] Test B05 (Pattern Not A Palindrome)");
        } else {
            System.out.println("[FAIL] Test B05 (Pattern Not A Palindrome)");
            failed.add("Test B05 (Pattern Not A Palindrome)");
        }
        total++;
        if (testAlgoB06OverlappingEvenPalindromes()) {
            System.out.println("[PASS] Test B06 (Overlapping Even Palindromes)");
        } else {
            System.out.println("[FAIL] Test B06 (Overlapping Even Palindromes)");
            failed.add("Test B06 (Overlapping Even Palindromes)");
        }
        total++;
        if (testAlgoB07AllSameSingleChar()) {
            System.out.println("[PASS] Test B07 (All Same - Single Char)");
        } else {
            System.out.println("[FAIL] Test B07 (All Same - Single Char)");
            failed.add("Test B07 (All Same - Single Char)");
        }
        total++;
        if (testAlgoB08RepeatedPalindrome()) {
            System.out.println("[PASS] Test B08 (Repeated Palindrome - aba)");
        } else {
            System.out.println("[FAIL] Test B08 (Repeated Palindrome - aba)");
            failed.add("Test B08 (Repeated Palindrome - aba)");
        }
        total++;
        if (testAlgoB09NullArguments()) {
            System.out.println("[PASS] Test B09 (NULL Arguments)");
        } else {
            System.out.println("[FAIL] Test B09 (NULL Arguments)");
            failed.add("Test B09 (NULL Arguments)");
        }
        total++;
        if (testAlgoB10StressTest()) {
            System.out.println("[PASS] Test B10 (Stress Test 50k chars)");
        } else {
            System.out.println("[FAIL] Test B10 (Stress Test 50k chars)");
            failed.add("Test B10 (Stress Test 50k chars)");
        }

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
