#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "palindrome_tree.h"

// ============================================================================
// TESTY Algorytmu A: eertree_build, eertree_count_distinct, eertree_longest_length
// ============================================================================

bool test_algo_a_01_basic_aabaa() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 5) passed = false;
    if (eertree_longest_length(t) != 5) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_02_single_char() {
    Eertree* t = eertree_build("a", 1);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 1) passed = false;
    if (eertree_longest_length(t) != 1) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_03_all_same_chars() {
    Eertree* t = eertree_build("aaaa", 4);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 4) passed = false;
    if (eertree_longest_length(t) != 4) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_04_no_internal_palindromes() {
    Eertree* t = eertree_build("abcde", 5);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 5) passed = false;
    if (eertree_longest_length(t) != 1) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_05_empty_string() {
    Eertree* t = eertree_build("", 0);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 0) passed = false;
    if (eertree_longest_length(t) != 0) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_06_null_input() {
    Eertree* t = eertree_build(NULL, 5);
    if (t != NULL) {
        eertree_free(t);
        return false;
    }
    return true;
}

bool test_algo_a_07_two_char_palindrome() {
    Eertree* t = eertree_build("aa", 2);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 2) passed = false;
    if (eertree_longest_length(t) != 2) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_08_abacaba() {
    Eertree* t = eertree_build("abacaba", 7);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 7) passed = false;
    if (eertree_longest_length(t) != 7) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_09_abba() {
    Eertree* t = eertree_build("abba", 4);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t) != 4) passed = false;
    if (eertree_longest_length(t) != 4) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_a_10_node_count_invariant() {
    // For any string of length n: distinct palindromes <= n (mathematical theorem).
    // Also verify specific known counts.
    const char* cases[] = { "racecar", "aabbaa", "abcbaabcba", "zzzzzzzzz" };
    const int   lens[]  = {  7,         6,         10,            9          };
    int n = 4;

    for (int i = 0; i < n; i++) {
        Eertree* t = eertree_build(cases[i], lens[i]);
        if (!t) return false;
        int distinct = eertree_count_distinct(t);
        eertree_free(t);
        if (distinct > lens[i] || distinct <= 0) return false;
    }

    Eertree* t = eertree_build("racecar", 7);
    if (!t) return false;
    bool passed = (eertree_count_distinct(t) == 7);
    eertree_free(t);
    return passed;
}

// ============================================================================
// TESTY Algorytmu B: eertree_count_occurrences
// ============================================================================

bool test_algo_b_01_single_char_occurrences() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "a", 1) == 4);

    eertree_free(t);
    return passed;
}

bool test_algo_b_02_even_palindrome_occurrences() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "aa", 2) == 2);

    eertree_free(t);
    return passed;
}

bool test_algo_b_03_full_string_palindrome() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "aabaa", 5) == 1);

    eertree_free(t);
    return passed;
}

bool test_algo_b_04_pattern_not_in_string() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "xyz", 3) == 0);

    eertree_free(t);
    return passed;
}

bool test_algo_b_05_pattern_not_a_palindrome() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "ab", 2) == 0);

    eertree_free(t);
    return passed;
}

bool test_algo_b_06_overlapping_even_palindromes() {
    // "aaaa": "aa" appears 3 times (overlapping: [0..1],[1..2],[2..3])
    Eertree* t = eertree_build("aaaa", 4);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "aa", 2) == 3);

    eertree_free(t);
    return passed;
}

bool test_algo_b_07_all_same_single_char() {
    Eertree* t = eertree_build("aaaa", 4);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "a", 1) == 4);

    eertree_free(t);
    return passed;
}

bool test_algo_b_08_repeated_palindrome() {
    // "abacaba": "aba" appears at [0..2] and [4..6] = 2 times
    Eertree* t = eertree_build("abacaba", 7);
    if (!t) return false;

    bool passed = (eertree_count_occurrences(t, "aba", 3) == 2);

    eertree_free(t);
    return passed;
}

bool test_algo_b_09_null_arguments() {
    Eertree* t = eertree_build("aabaa", 5);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_occurrences(NULL, "a", 1)  != 0) passed = false;
    if (eertree_count_occurrences(t,    NULL, 1) != 0) passed = false;
    if (eertree_count_occurrences(t,    "a",  0) != 0) passed = false;
    if (eertree_count_occurrences(NULL, NULL, 0) != 0) passed = false;

    eertree_free(t);
    return passed;
}

bool test_algo_b_10_stress_test() {
    int n = 50000;
    char* s = (char*)malloc(n + 1);
    if (!s) return false;
    memset(s, 'a', n);
    s[n] = '\0';

    Eertree* t = eertree_build(s, n);
    free(s);
    if (!t) return false;

    bool passed = true;
    if (eertree_count_distinct(t)              != n)     passed = false;
    if (eertree_longest_length(t)              != n)     passed = false;
    if (eertree_count_occurrences(t, "a",  1) != n)     passed = false;
    if (eertree_count_occurrences(t, "aa", 2) != n - 1) passed = false;

    eertree_free(t);
    return passed;
}

// ============================================================================
// MAIN RUNNER
// ============================================================================

int main() {
    int failed_count = 0;
    const char* failed_tests[50];
    int total_tests = 0;

    #define RUN_TEST(func, name) \
        do { \
            total_tests++; \
            if (func()) { \
                printf("[PASS] %s\n", name); \
            } else { \
                printf("[FAIL] %s\n", name); \
                failed_tests[failed_count++] = name; \
            } \
        } while (0)

    printf("=== START ===\n");

    printf("\n--- Algorithm A: Palindrome Tree Construction & Structural Queries ---\n");
    RUN_TEST(test_algo_a_01_basic_aabaa,             "Test A01 (Basic - aabaa)");
    RUN_TEST(test_algo_a_02_single_char,             "Test A02 (Single Char)");
    RUN_TEST(test_algo_a_03_all_same_chars,          "Test A03 (All Same Chars - aaaa)");
    RUN_TEST(test_algo_a_04_no_internal_palindromes, "Test A04 (No Internal Palindromes)");
    RUN_TEST(test_algo_a_05_empty_string,            "Test A05 (Empty String)");
    RUN_TEST(test_algo_a_06_null_input,              "Test A06 (NULL Input)");
    RUN_TEST(test_algo_a_07_two_char_palindrome,     "Test A07 (Two-Char Palindrome - aa)");
    RUN_TEST(test_algo_a_08_abacaba,                 "Test A08 (Classic - abacaba)");
    RUN_TEST(test_algo_a_09_abba,                    "Test A09 (Even Palindrome - abba)");
    RUN_TEST(test_algo_a_10_node_count_invariant,    "Test A10 (Node Count Invariant)");

    printf("\n--- Algorithm B: Occurrence Counting ---\n");
    RUN_TEST(test_algo_b_01_single_char_occurrences,     "Test B01 (Single Char Count)");
    RUN_TEST(test_algo_b_02_even_palindrome_occurrences, "Test B02 (Even Palindrome Count)");
    RUN_TEST(test_algo_b_03_full_string_palindrome,      "Test B03 (Full String Palindrome)");
    RUN_TEST(test_algo_b_04_pattern_not_in_string,       "Test B04 (Pattern Not In String)");
    RUN_TEST(test_algo_b_05_pattern_not_a_palindrome,    "Test B05 (Pattern Not A Palindrome)");
    RUN_TEST(test_algo_b_06_overlapping_even_palindromes,"Test B06 (Overlapping Even Palindromes)");
    RUN_TEST(test_algo_b_07_all_same_single_char,        "Test B07 (All Same - Single Char)");
    RUN_TEST(test_algo_b_08_repeated_palindrome,         "Test B08 (Repeated Palindrome - aba)");
    RUN_TEST(test_algo_b_09_null_arguments,              "Test B09 (NULL Arguments)");
    RUN_TEST(test_algo_b_10_stress_test,                 "Test B10 (Stress Test 50k chars)");

    printf("\n=== BENCHMARK RESULTS ===\n");
    printf("Completed %d tests.\n", total_tests);

    if (failed_count == 0) {
        printf("All tests passed!\n");
        return 0;
    } else {
        printf("Tests that failed (%d):\n", failed_count);
        for (int i = 0; i < failed_count; i++) {
            printf(" - %s\n", failed_tests[i]);
        }
        return 1;
    }
}
