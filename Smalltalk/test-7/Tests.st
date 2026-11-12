Object subclass: Tests [
    | al |

    Tests class >> new [
        ^super new init
    ]

    init [
        al := SequenceAlignmentImpl new.
    ]

    "======================================================================"
    " Helpers. p = #(matchScore mismatchPenalty gapOpen gapExtend)          "
    "======================================================================"

    stressA [
        ^'CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA'
    ]

    stressB [
        ^'GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC'
    ]

    score: a with: b params: p [
        ^al scoreOf: a with: b
            match: (p at: 1) mismatch: (p at: 2) gapOpen: (p at: 3) gapExtend: (p at: 4)
    ]

    align: a with: b params: p [
        ^al align: a with: b
            match: (p at: 1) mismatch: (p at: 2) gapOpen: (p at: 3) gapExtend: (p at: 4)
    ]

    stripGaps: aString [
        ^aString reject: [:c | c = $-]
    ]

    "Score of an alignment by definition, or nil if the two rows are not a legal alignment:
     per column without '-': +match / -mismatch; per gap (maximal run of '-' in one row)
     of length L: -(gapOpen + L * gapExtend); a '-'/'-' column is illegal."
    recompute: sa and: sb params: p [
        | m x o e s inA inB ca cb |
        sa size = sb size ifFalse: [^nil].
        m := p at: 1. x := p at: 2. o := p at: 3. e := p at: 4.
        s := 0.
        inA := false.
        inB := false.
        1 to: sa size do: [:k |
            ca := sa at: k.
            cb := sb at: k.
            (ca = $- and: [cb = $-]) ifTrue: [^nil].
            ca = $-
                ifTrue: [
                    inA ifFalse: [s := s - o].
                    s := s - e.
                    inA := true.
                    inB := false]
                ifFalse: [
                    cb = $-
                        ifTrue: [
                            inB ifFalse: [s := s - o].
                            s := s - e.
                            inB := true.
                            inA := false]
                        ifFalse: [
                            s := s + (ca = cb ifTrue: [m] ifFalse: [x negated]).
                            inA := false.
                            inB := false]]].
        ^s
    ]

    "Checks score, legality of the alignment, the recomputed score and (if exact is not nil)
     the exact aligned strings exact = #(alignedA alignedB)."
    check: a with: b params: p score: expected exact: exact [
        | r sa sb |
        r := self align: a with: b params: p.
        r isNil ifTrue: [^false].
        r score = expected ifFalse: [^false].
        (r alignedA isNil or: [r alignedB isNil]) ifTrue: [^false].
        sa := r alignedA asString.
        sb := r alignedB asString.
        sa size = sb size ifFalse: [^false].
        (self stripGaps: sa) = a ifFalse: [^false].
        (self stripGaps: sb) = b ifFalse: [^false].
        (self recompute: sa and: sb params: p) = expected ifFalse: [^false].
        exact isNil ifTrue: [^true].
        ^sa = (exact at: 1) and: [sb = (exact at: 2)]
    ]

    "======================================================================"
    " Algorithm A: scoreOf:with:match:mismatch:gapOpen:gapExtend:           "
    "======================================================================"

    testAlgoA01BothEmpty [
        ^(self score: '' with: '' params: #(1 1 2 1)) = 0
    ]

    testAlgoA02OneEmpty [
        ^(self score: '' with: 'ACG' params: #(1 1 2 1)) = -5
    ]

    testAlgoA03Identical [
        ^(self score: 'GATTACA' with: 'GATTACA' params: #(2 1 3 1)) = 14
    ]

    testAlgoA04MismatchBeatsGaps [
        ^(self score: 'A' with: 'C' params: #(1 1 2 1)) = -1
    ]

    testAlgoA05Textbook [
        ^(self score: 'GATTACA' with: 'GCATGCU' params: #(1 1 1 1)) = -1
    ]

    testAlgoA06OneLongGap [
        ^(self score: 'AAAGGGTTT' with: 'AAATTT' params: #(2 2 5 1)) = 4
    ]

    testAlgoA07ZeroExtend [
        ^(self score: 'TTACGGA' with: 'ACG' params: #(2 2 2 0)) = 2
    ]

    testAlgoA08AdjacentGapsBeatMismatch [
        ^(self score: 'XAY' with: 'XCY' params: #(1 10 1 1)) = -2
    ]

    testAlgoA09TerminalGapsPenalized [
        ^(self score: 'AAAACCCC' with: 'CCCC' params: #(2 1 3 1)) = 1
    ]

    testAlgoA10Stress [
        ^(self score: self stressA with: self stressB params: #(2 1 3 1)) = 16
    ]

    "======================================================================"
    " Algorithm B: align:with:match:mismatch:gapOpen:gapExtend:             "
    "======================================================================"

    testAlgoB01BothEmpty [
        ^self check: '' with: '' params: #(1 1 2 1) score: 0 exact: #('' '')
    ]

    testAlgoB02SecondEmpty [
        ^self check: 'ACG' with: '' params: #(1 1 2 1) score: -5 exact: #('ACG' '---')
    ]

    testAlgoB03Identical [
        ^self check: 'GATTACA' with: 'GATTACA' params: #(2 1 3 1) score: 14
            exact: #('GATTACA' 'GATTACA')
    ]

    testAlgoB04UniqueLongGap [
        ^self check: 'AAAGGGTTT' with: 'AAATTT' params: #(2 2 5 1) score: 4
            exact: #('AAAGGGTTT' 'AAA---TTT')
    ]

    testAlgoB05AdjacentGaps [
        ^self check: 'XAY' with: 'XCY' params: #(1 10 1 1) score: -2 exact: nil
    ]

    testAlgoB06TextbookUnique [
        ^self check: 'GATTACA' with: 'GCATGCU' params: #(1 1 1 1) score: -1
            exact: #('GATTACA' 'GCATGCU')
    ]

    testAlgoB07GapMerging [
        ^self check: 'ACCCGT' with: 'AGT' params: #(2 3 6 1) score: -3
            exact: #('ACCCGT' 'A---GT')
    ]

    testAlgoB08GapsInBothRows [
        ^self check: 'CACGCA' with: 'AGGCGC' params: #(3 2 3 1) score: -1
            exact: #('CA--CGCA' '-AGGCGC-')
    ]

    testAlgoB09TiedGapPositions [
        ^self check: 'AAAA' with: 'AA' params: #(1 1 1 1) score: -1 exact: nil
    ]

    testAlgoB10StressInvariants [
        ^self check: self stressA with: self stressB params: #(3 2 5 1) score: 10 exact: nil
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
        Transcript show: '--- Algorithm A: Alignment Score ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01BothEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Both Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Both Empty)'; cr.
                      failedTests add: 'Test A01 (Both Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02OneEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (One Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (One Empty)'; cr.
                      failedTests add: 'Test A02 (One Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03Identical] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Identical)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Identical)'; cr.
                      failedTests add: 'Test A03 (Identical)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04MismatchBeatsGaps] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Mismatch Beats Gaps)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Mismatch Beats Gaps)'; cr.
                      failedTests add: 'Test A04 (Mismatch Beats Gaps)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05Textbook] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Textbook)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Textbook)'; cr.
                      failedTests add: 'Test A05 (Textbook)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06OneLongGap] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (One Long Gap)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (One Long Gap)'; cr.
                      failedTests add: 'Test A06 (One Long Gap)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07ZeroExtend] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Zero Extend)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Zero Extend)'; cr.
                      failedTests add: 'Test A07 (Zero Extend)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08AdjacentGapsBeatMismatch] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Adjacent Gaps Beat Mismatch)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Adjacent Gaps Beat Mismatch)'; cr.
                      failedTests add: 'Test A08 (Adjacent Gaps Beat Mismatch)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09TerminalGapsPenalized] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Terminal Gaps Penalized)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Terminal Gaps Penalized)'; cr.
                      failedTests add: 'Test A09 (Terminal Gaps Penalized)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress)'; cr.
                      failedTests add: 'Test A10 (Stress)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Alignment Reconstruction ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01BothEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Both Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Both Empty)'; cr.
                      failedTests add: 'Test B01 (Both Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02SecondEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Second Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Second Empty)'; cr.
                      failedTests add: 'Test B02 (Second Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03Identical] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Identical)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Identical)'; cr.
                      failedTests add: 'Test B03 (Identical)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04UniqueLongGap] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Unique Long Gap)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Unique Long Gap)'; cr.
                      failedTests add: 'Test B04 (Unique Long Gap)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05AdjacentGaps] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Adjacent Gaps)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Adjacent Gaps)'; cr.
                      failedTests add: 'Test B05 (Adjacent Gaps)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06TextbookUnique] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Textbook Unique)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Textbook Unique)'; cr.
                      failedTests add: 'Test B06 (Textbook Unique)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07GapMerging] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Gap Merging)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Gap Merging)'; cr.
                      failedTests add: 'Test B07 (Gap Merging)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08GapsInBothRows] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Gaps In Both Rows)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Gaps In Both Rows)'; cr.
                      failedTests add: 'Test B08 (Gaps In Both Rows)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09TiedGapPositions] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Tied Gap Positions)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Tied Gap Positions)'; cr.
                      failedTests add: 'Test B09 (Tied Gap Positions)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10StressInvariants] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Stress Invariants)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Stress Invariants)'; cr.
                      failedTests add: 'Test B10 (Stress Invariants)'.
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
