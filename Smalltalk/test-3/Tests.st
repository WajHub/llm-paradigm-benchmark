Object subclass: Tests [
    | pt |

    Tests class >> new [
        ^super new init
    ]

    init [
        pt := PalindromeTreeImpl new.
    ]

    "======================================================================"
    " Algorithm A: eertreeBuild, eertreeCountDistinct, eertreeLongestLength "
    "======================================================================"

    testAlgoA01BasicAabaa [
        | t passed |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 5 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 5 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA02SingleChar [
        | t passed |
        t := pt eertreeBuild: 'a' length: 1.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 1 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 1 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA03AllSameChars [
        | t passed |
        t := pt eertreeBuild: 'aaaa' length: 4.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 4 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 4 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA04NoInternalPalindromes [
        | t passed |
        t := pt eertreeBuild: 'abcde' length: 5.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 5 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 1 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA05EmptyString [
        | t passed |
        t := pt eertreeBuild: '' length: 0.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 0 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 0 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA06NullInput [
        | t |
        t := pt eertreeBuild: nil length: 5.
        ^t isNil
    ]

    testAlgoA07TwoCharPalindrome [
        | t passed |
        t := pt eertreeBuild: 'aa' length: 2.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 2 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 2 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA08Abacaba [
        | t passed |
        t := pt eertreeBuild: 'abacaba' length: 7.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 7 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 7 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA09Abba [
        | t passed |
        t := pt eertreeBuild: 'abba' length: 4.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = 4 ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = 4 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA10NodeCountInvariant [
        | cases lens t d passed t2 |
        cases := #('racecar' 'aabbaa' 'abcbaabcba' 'zzzzzzzzz').
        lens := #(7 6 10 9).
        passed := true.
        1 to: cases size do: [:i |
            t := pt eertreeBuild: (cases at: i) length: (lens at: i).
            t isNil ifTrue: [^false].
            d := pt eertreeCountDistinct: t.
            (d > (lens at: i)) ifTrue: [passed := false].
            (d <= 0) ifTrue: [passed := false]].
        passed ifFalse: [^false].
        t2 := pt eertreeBuild: 'racecar' length: 7.
        t2 isNil ifTrue: [^false].
        ^(pt eertreeCountDistinct: t2) = 7
    ]

    "======================================================================"
    " Algorithm B: eertreeCountOccurrences                                 "
    "======================================================================"

    testAlgoB01SingleCharOccurrences [
        | t |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'a' length: 1) = 4
    ]

    testAlgoB02EvenPalindromeOccurrences [
        | t |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'aa' length: 2) = 2
    ]

    testAlgoB03FullStringPalindrome [
        | t |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'aabaa' length: 5) = 1
    ]

    testAlgoB04PatternNotInString [
        | t |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'xyz' length: 3) = 0
    ]

    testAlgoB05PatternNotAPalindrome [
        | t |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'ab' length: 2) = 0
    ]

    testAlgoB06OverlappingEvenPalindromes [
        | t |
        "'aaaa': 'aa' appears 3 times (overlapping: [0..1],[1..2],[2..3])"
        t := pt eertreeBuild: 'aaaa' length: 4.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'aa' length: 2) = 3
    ]

    testAlgoB07AllSameSingleChar [
        | t |
        t := pt eertreeBuild: 'aaaa' length: 4.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'a' length: 1) = 4
    ]

    testAlgoB08RepeatedPalindrome [
        | t |
        "'abacaba': 'aba' appears at [0..2] and [4..6] = 2 times"
        t := pt eertreeBuild: 'abacaba' length: 7.
        t isNil ifTrue: [^false].
        ^(pt eertreeCountOccurrences: t pattern: 'aba' length: 3) = 2
    ]

    testAlgoB09NullArguments [
        | t passed |
        t := pt eertreeBuild: 'aabaa' length: 5.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountOccurrences: nil pattern: 'a' length: 1) = 0 ifFalse: [passed := false].
        (pt eertreeCountOccurrences: t pattern: nil length: 1) = 0 ifFalse: [passed := false].
        (pt eertreeCountOccurrences: t pattern: 'a' length: 0) = 0 ifFalse: [passed := false].
        (pt eertreeCountOccurrences: nil pattern: nil length: 0) = 0 ifFalse: [passed := false].
        ^passed
    ]

    testAlgoB10StressTest [
        | n s t passed |
        n := 50000.
        s := String new: n withAll: $a.
        t := pt eertreeBuild: s length: n.
        t isNil ifTrue: [^false].
        passed := true.
        (pt eertreeCountDistinct: t) = n ifFalse: [passed := false].
        (pt eertreeLongestLength: t) = n ifFalse: [passed := false].
        (pt eertreeCountOccurrences: t pattern: 'a' length: 1) = n ifFalse: [passed := false].
        (pt eertreeCountOccurrences: t pattern: 'aa' length: 2) = (n - 1) ifFalse: [passed := false].
        ^passed
    ]

    "======================================================================"
    " Test Runner                                                          "
    "======================================================================"

    runAll [
        | failedCount totalTests failedTests |
        failedCount := 0.
        totalTests := 0.
        failedTests := OrderedCollection new.

        Transcript show: '=== START ==='; cr.
        Transcript cr.
        Transcript show: '--- Algorithm A: Palindrome Tree Construction & Structural Queries ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01BasicAabaa] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Basic - aabaa)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Basic - aabaa)'; cr.
                      failedTests add: 'Test A01 (Basic - aabaa)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02SingleChar] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Single Char)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Single Char)'; cr.
                      failedTests add: 'Test A02 (Single Char)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03AllSameChars] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (All Same Chars - aaaa)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (All Same Chars - aaaa)'; cr.
                      failedTests add: 'Test A03 (All Same Chars - aaaa)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04NoInternalPalindromes] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (No Internal Palindromes)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (No Internal Palindromes)'; cr.
                      failedTests add: 'Test A04 (No Internal Palindromes)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05EmptyString] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Empty String)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Empty String)'; cr.
                      failedTests add: 'Test A05 (Empty String)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06NullInput] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (NULL Input)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (NULL Input)'; cr.
                      failedTests add: 'Test A06 (NULL Input)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07TwoCharPalindrome] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Two-Char Palindrome - aa)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Two-Char Palindrome - aa)'; cr.
                      failedTests add: 'Test A07 (Two-Char Palindrome - aa)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08Abacaba] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Classic - abacaba)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Classic - abacaba)'; cr.
                      failedTests add: 'Test A08 (Classic - abacaba)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09Abba] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Even Palindrome - abba)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Even Palindrome - abba)'; cr.
                      failedTests add: 'Test A09 (Even Palindrome - abba)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10NodeCountInvariant] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Node Count Invariant)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Node Count Invariant)'; cr.
                      failedTests add: 'Test A10 (Node Count Invariant)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Occurrence Counting ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01SingleCharOccurrences] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Single Char Count)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Single Char Count)'; cr.
                      failedTests add: 'Test B01 (Single Char Count)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02EvenPalindromeOccurrences] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Even Palindrome Count)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Even Palindrome Count)'; cr.
                      failedTests add: 'Test B02 (Even Palindrome Count)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03FullStringPalindrome] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Full String Palindrome)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Full String Palindrome)'; cr.
                      failedTests add: 'Test B03 (Full String Palindrome)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04PatternNotInString] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Pattern Not In String)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Pattern Not In String)'; cr.
                      failedTests add: 'Test B04 (Pattern Not In String)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05PatternNotAPalindrome] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Pattern Not A Palindrome)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Pattern Not A Palindrome)'; cr.
                      failedTests add: 'Test B05 (Pattern Not A Palindrome)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06OverlappingEvenPalindromes] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Overlapping Even Palindromes)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Overlapping Even Palindromes)'; cr.
                      failedTests add: 'Test B06 (Overlapping Even Palindromes)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07AllSameSingleChar] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (All Same - Single Char)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (All Same - Single Char)'; cr.
                      failedTests add: 'Test B07 (All Same - Single Char)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08RepeatedPalindrome] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Repeated Palindrome - aba)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Repeated Palindrome - aba)'; cr.
                      failedTests add: 'Test B08 (Repeated Palindrome - aba)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09NullArguments] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (NULL Arguments)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (NULL Arguments)'; cr.
                      failedTests add: 'Test B09 (NULL Arguments)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10StressTest] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Stress Test 50k chars)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Stress Test 50k chars)'; cr.
                      failedTests add: 'Test B10 (Stress Test 50k chars)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '=== BENCHMARK RESULTS ==='; cr.
        Transcript show: 'Completed ', totalTests printString, ' tests.'; cr.

        failedCount = 0
            ifTrue: [
                Transcript show: 'All tests passed!'; cr.
                ObjectMemory quit: 0
            ]
            ifFalse: [
                Transcript show: 'Tests that failed (', failedCount printString, '):'; cr.
                failedTests do: [:t | Transcript show: ' - ', t; cr].
                ObjectMemory quit: 1
            ]
    ]
]

Tests new runAll.
