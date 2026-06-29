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

    public static void main(String[] args) {
        int failedCount = 0;
        String[] failedTests = new String[50];
        int totalTests = 0;

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Palindrome Tree Construction & Structural Queries ---");
        totalTests++;
        if (testAlgoA01BasicAabaa()) {
            System.out.println("[PASS] Test A01 (Basic - aabaa)");
        } else {
            System.out.println("[FAIL] Test A01 (Basic - aabaa)");
            failedTests[failedCount++] = "Test A01 (Basic - aabaa)";
        }
        totalTests++;
        if (testAlgoA02SingleChar()) {
            System.out.println("[PASS] Test A02 (Single Char)");
        } else {
            System.out.println("[FAIL] Test A02 (Single Char)");
            failedTests[failedCount++] = "Test A02 (Single Char)";
        }
        totalTests++;
        if (testAlgoA03AllSameChars()) {
            System.out.println("[PASS] Test A03 (All Same Chars - aaaa)");
        } else {
            System.out.println("[FAIL] Test A03 (All Same Chars - aaaa)");
            failedTests[failedCount++] = "Test A03 (All Same Chars - aaaa)";
        }
        totalTests++;
        if (testAlgoA04NoInternalPalindromes()) {
            System.out.println("[PASS] Test A04 (No Internal Palindromes)");
        } else {
            System.out.println("[FAIL] Test A04 (No Internal Palindromes)");
            failedTests[failedCount++] = "Test A04 (No Internal Palindromes)";
        }
        totalTests++;
        if (testAlgoA05EmptyString()) {
            System.out.println("[PASS] Test A05 (Empty String)");
        } else {
            System.out.println("[FAIL] Test A05 (Empty String)");
            failedTests[failedCount++] = "Test A05 (Empty String)";
        }
        totalTests++;
        if (testAlgoA06NullInput()) {
            System.out.println("[PASS] Test A06 (NULL Input)");
        } else {
            System.out.println("[FAIL] Test A06 (NULL Input)");
            failedTests[failedCount++] = "Test A06 (NULL Input)";
        }
        totalTests++;
        if (testAlgoA07TwoCharPalindrome()) {
            System.out.println("[PASS] Test A07 (Two-Char Palindrome - aa)");
        } else {
            System.out.println("[FAIL] Test A07 (Two-Char Palindrome - aa)");
            failedTests[failedCount++] = "Test A07 (Two-Char Palindrome - aa)";
        }
        totalTests++;
        if (testAlgoA08Abacaba()) {
            System.out.println("[PASS] Test A08 (Classic - abacaba)");
        } else {
            System.out.println("[FAIL] Test A08 (Classic - abacaba)");
            failedTests[failedCount++] = "Test A08 (Classic - abacaba)";
        }
        totalTests++;
        if (testAlgoA09Abba()) {
            System.out.println("[PASS] Test A09 (Even Palindrome - abba)");
        } else {
            System.out.println("[FAIL] Test A09 (Even Palindrome - abba)");
            failedTests[failedCount++] = "Test A09 (Even Palindrome - abba)";
        }
        totalTests++;
        if (testAlgoA10NodeCountInvariant()) {
            System.out.println("[PASS] Test A10 (Node Count Invariant)");
        } else {
            System.out.println("[FAIL] Test A10 (Node Count Invariant)");
            failedTests[failedCount++] = "Test A10 (Node Count Invariant)";
        }

        System.out.println();
        System.out.println("--- Algorithm B: Occurrence Counting ---");
        totalTests++;
        if (testAlgoB01SingleCharOccurrences()) {
            System.out.println("[PASS] Test B01 (Single Char Count)");
        } else {
            System.out.println("[FAIL] Test B01 (Single Char Count)");
            failedTests[failedCount++] = "Test B01 (Single Char Count)";
        }
        totalTests++;
        if (testAlgoB02EvenPalindromeOccurrences()) {
            System.out.println("[PASS] Test B02 (Even Palindrome Count)");
        } else {
            System.out.println("[FAIL] Test B02 (Even Palindrome Count)");
            failedTests[failedCount++] = "Test B02 (Even Palindrome Count)";
        }
        totalTests++;
        if (testAlgoB03FullStringPalindrome()) {
            System.out.println("[PASS] Test B03 (Full String Palindrome)");
        } else {
            System.out.println("[FAIL] Test B03 (Full String Palindrome)");
            failedTests[failedCount++] = "Test B03 (Full String Palindrome)";
        }
        totalTests++;
        if (testAlgoB04PatternNotInString()) {
            System.out.println("[PASS] Test B04 (Pattern Not In String)");
        } else {
            System.out.println("[FAIL] Test B04 (Pattern Not In String)");
            failedTests[failedCount++] = "Test B04 (Pattern Not In String)";
        }
        totalTests++;
        if (testAlgoB05PatternNotAPalindrome()) {
            System.out.println("[PASS] Test B05 (Pattern Not A Palindrome)");
        } else {
            System.out.println("[FAIL] Test B05 (Pattern Not A Palindrome)");
            failedTests[failedCount++] = "Test B05 (Pattern Not A Palindrome)";
        }
        totalTests++;
        if (testAlgoB06OverlappingEvenPalindromes()) {
            System.out.println("[PASS] Test B06 (Overlapping Even Palindromes)");
        } else {
            System.out.println("[FAIL] Test B06 (Overlapping Even Palindromes)");
            failedTests[failedCount++] = "Test B06 (Overlapping Even Palindromes)";
        }
        totalTests++;
        if (testAlgoB07AllSameSingleChar()) {
            System.out.println("[PASS] Test B07 (All Same - Single Char)");
        } else {
            System.out.println("[FAIL] Test B07 (All Same - Single Char)");
            failedTests[failedCount++] = "Test B07 (All Same - Single Char)";
        }
        totalTests++;
        if (testAlgoB08RepeatedPalindrome()) {
            System.out.println("[PASS] Test B08 (Repeated Palindrome - aba)");
        } else {
            System.out.println("[FAIL] Test B08 (Repeated Palindrome - aba)");
            failedTests[failedCount++] = "Test B08 (Repeated Palindrome - aba)";
        }
        totalTests++;
        if (testAlgoB09NullArguments()) {
            System.out.println("[PASS] Test B09 (NULL Arguments)");
        } else {
            System.out.println("[FAIL] Test B09 (NULL Arguments)");
            failedTests[failedCount++] = "Test B09 (NULL Arguments)";
        }
        totalTests++;
        if (testAlgoB10StressTest()) {
            System.out.println("[PASS] Test B10 (Stress Test 50k chars)");
        } else {
            System.out.println("[FAIL] Test B10 (Stress Test 50k chars)");
            failedTests[failedCount++] = "Test B10 (Stress Test 50k chars)";
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
