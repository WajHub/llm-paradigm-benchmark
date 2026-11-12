"======================================================================"
" Read probe for Algorithm B: a shared read counter with a budget and a  "
" read-only sorted source answering only size and at: (1-based).        "
"======================================================================"

Object subclass: TestReadBudget [
    | reads limit violated |

    TestReadBudget class >> limit: n [
        ^self new initLimit: n
    ]

    initLimit: n [
        reads := 0.
        limit := n.
        violated := false.
        ^self
    ]

    reads [ ^reads ]
    violated [ ^violated ]

    countRead [
        reads := reads + 1.
        reads > limit ifTrue: [
            violated := true.
            ^self error: 'read budget exceeded']
    ]

    outOfRange: i [
        violated := true.
        ^self error: 'index out of range: ', i printString
    ]
]

Object subclass: TestCountingSource [
    | length getter budget |

    "getter is a one-argument block taking the 0-based position."
    TestCountingSource class >> size: n getter: aBlock budget: aBudget [
        ^self basicNew initSize: n getter: aBlock budget: aBudget
    ]

    initSize: n getter: aBlock budget: aBudget [
        length := n.
        getter := aBlock.
        budget := aBudget.
        ^self
    ]

    size [ ^length ]

    at: i [
        budget countRead.
        (i isInteger and: [i between: 1 and: length]) ifFalse: [^budget outOfRange: i].
        ^getter value: i - 1
    ]
]

Object subclass: Tests [
    | os |

    Tests class >> new [
        ^super new init
    ]

    init [
        os := OrderStatsImpl new.
    ]

    "======================================================================"
    " Helpers                                                              "
    "======================================================================"

    sel: k from: xs is: expectedValue pivots: expectedPivots [
        | r |
        r := os selectKth: k from: xs.
        r isNil ifTrue: [^false].
        r pivots isNil ifTrue: [^false].
        ^r value = expectedValue and: [r pivots asArray = expectedPivots]
    ]

    "x := (x * 1103515245 + 12345) \\ 2147483648 (seed 42), r := x // 65536, value (r \\ 20001) - 10000."
    stressValues [
        | x out |
        x := 42.
        out := Array new: 5000.
        1 to: 5000 do: [:i |
            x := (x * 1103515245 + 12345) \\ 2147483648.
            out at: i put: ((x // 65536) \\ 20001) - 10000].
        ^out
    ]

    listSource: anArray budget: aBudget [
        ^TestCountingSource size: anArray size getter: [:i | anArray at: i + 1] budget: aBudget
    ]

    "Run medianOf:and: on two literal arrays with the given read budget."
    medianOfList: a and: b budget: n [
        | budget |
        budget := TestReadBudget limit: n.
        ^self median: [:bud | os medianOf: (self listSource: a budget: bud) and: (self listSource: b budget: bud)]
            budget: budget
    ]

    "Answer the median, or #violation if the budget was exceeded / an index was out of range
     (even if the implementation swallowed the error)."
    median: aBlock budget: budget [
        | r |
        r := aBlock value: budget.
        budget violated ifTrue: [^#violation].
        ^r
    ]

    approx: r is: expected [
        r isNil ifTrue: [^false].
        r isNumber ifFalse: [^false].
        ^(r - expected) abs < 1e-9
    ]

    "======================================================================"
    " Algorithm A: medianOfMedians: and selectKth:from: (k is 1-based)      "
    "======================================================================"

    testAlgoA01Empty [
        ^(os medianOfMedians: #()) isNil
            and: [(os selectKth: 1 from: #()) isNil]
    ]

    testAlgoA02Single [
        ^(os medianOfMedians: #(7)) = 7
            and: [(self sel: 1 from: #(7) is: 7 pivots: #())
            and: [(os selectKth: 2 from: #(7)) isNil]]
    ]

    testAlgoA03OutOfRange [
        ^(os selectKth: 4 from: #(3 1 2)) isNil
            and: [(os selectKth: 0 from: #(3 1 2)) isNil
            and: [(self sel: 3 from: #(3 1 2) is: 3 pivots: #())
            and: [(os medianOfMedians: #(3 1 2)) = 2]]]
    ]

    testAlgoA04OneGroup [
        | xs |
        xs := #(9 1 8 2 7).
        ^(os medianOfMedians: xs) = 7
            and: [(self sel: 1 from: xs is: 1 pivots: #())
            and: [(self sel: 3 from: xs is: 7 pivots: #())
            and: [self sel: 5 from: xs is: 9 pivots: #()]]]
    ]

    testAlgoA05PivotIsNotMedian [
        | xs |
        xs := #(1 2 3 4 5 6 7 8 9 10).
        ^(os medianOfMedians: xs) = 3
            and: [(self sel: 5 from: xs is: 5 pivots: #(3 6))
            and: [self sel: 6 from: xs is: 6 pivots: #(3 6)]]
    ]

    testAlgoA06PartialLastGroup [
        | xs |
        xs := #(5 3 9 1 8 2 6).
        ^(os medianOfMedians: xs) = 2
            and: [(self sel: 4 from: xs is: 5 pivots: #(2))
            and: [self sel: 7 from: xs is: 9 pivots: #(2)]]
    ]

    testAlgoA07ManyDuplicates [
        | xs |
        xs := #(5 5 5 1 5 5 9 5 5 5 5).
        ^(os medianOfMedians: xs) = 5
            and: [(self sel: 1 from: xs is: 1 pivots: #(5))
            and: [(self sel: 6 from: xs is: 5 pivots: #(5))
            and: [self sel: 11 from: xs is: 9 pivots: #(5)]]]
    ]

    testAlgoA08StablePartitionOrder [
        | xs |
        xs := #(40 54 53 18 19 56 52 33 58 51 41 27).
        ^(os medianOfMedians: xs) = 40
            and: [self sel: 7 from: xs is: 51 pivots: #(40 41 51)]
    ]

    testAlgoA09AllRanks [
        | xs original sorted |
        xs := #(12 -7 3 3 25 0 -7 18 3 9 41 -2 3 16 -30 7 7 22 -11 5 3 0 14) copy.
        original := xs copy.
        sorted := #(-30 -11 -7 -7 -2 0 0 3 3 3 3 3 5 7 7 9 12 14 16 18 22 25 41).
        (os medianOfMedians: xs) = 3 ifFalse: [^false].
        1 to: 23 do: [:k |
            | pivots |
            pivots := k <= 7
                ifTrue: [#(3 -11)]
                ifFalse: [k <= 12 ifTrue: [#(3)] ifFalse: [#(3 14)]].
            (self sel: k from: xs is: (sorted at: k) pivots: pivots) ifFalse: [^false]].
        ^xs = original
    ]

    testAlgoA10Stress [
        | xs |
        xs := self stressValues.
        (xs first: 6) = #(9081 7033 5269 -4540 3856 -8907) ifFalse: [^false].
        ^(os medianOfMedians: xs) = -1678
            and: [(self sel: 1 from: xs is: -9996
                    pivots: #(-1678 -5890 -7989 -9070 -9559 -9795 -9899 -9942 -9982 -9995))
            and: [(self sel: 2500 from: xs is: -1694
                    pivots: #(-1678 -5890 -3836 -2653 -2238 -1989 -1834 -1771 -1720 -1694))
            and: [self sel: 5000 from: xs is: 9984
                    pivots: #(-1678 2387 6069 7942 9014 9543 9788 9878 9930 9951 9974)]]]
    ]

    "======================================================================"
    " Algorithm B: medianOf:and: on counting sources with a read budget     "
    "======================================================================"

    testAlgoB01BothEmpty [
        ^(self medianOfList: #() and: #() budget: 16) isNil
    ]

    testAlgoB02OneEmpty [
        ^self approx: (self medianOfList: #() and: #(1 2 3 4) budget: 64) is: 2.5
    ]

    testAlgoB03SingleEach [
        ^self approx: (self medianOfList: #(1) and: #(2) budget: 48) is: 1.5
    ]

    testAlgoB04OddTotalInterleaved [
        ^self approx: (self medianOfList: #(1 3 5) and: #(2 4) budget: 64) is: 3.0
    ]

    testAlgoB05DisjointRanges [
        ^self approx: (self medianOfList: #(10 11 12 13) and: #(1 2 3) budget: 64) is: 10.0
    ]

    testAlgoB06Duplicates [
        ^self approx: (self medianOfList: #(1 1 1 1) and: #(1 1 2) budget: 64) is: 1.0
    ]

    testAlgoB07NoOverflow [
        ^(self approx: (self medianOfList: #(2147483647) and: #(2147483647) budget: 48)
                is: 2147483647.0)
            and: [self approx: (self medianOfList: #(-2147483648 2147483647) and: #() budget: 48)
                is: -0.5]
    ]

    testAlgoB08HugeInterleaved [
        | r |
        r := self median: [:bud |
                os medianOf: (TestCountingSource size: 1000000000
                                getter: [:i | 2 * i - 1000000000] budget: bud)
                    and: (TestCountingSource size: 999999999
                                getter: [:j | 2 * j - 999999999] budget: bud)]
            budget: (TestReadBudget limit: 512).
        ^self approx: r is: -1.0
    ]

    testAlgoB09HugeUnbalanced [
        | r |
        r := self median: [:bud |
                os medianOf: (self listSource: #(-5 0 7) budget: bud)
                    and: (TestCountingSource size: 2000000000
                                getter: [:j | (j // 2) - 500000000] budget: bud)]
            budget: (TestReadBudget limit: 512).
        ^self approx: r is: 0.0
    ]

    testAlgoB10HugeDuplicates [
        | r |
        r := self median: [:bud |
                os medianOf: (TestCountingSource size: 1500000000
                                getter: [:i | i // 1000000] budget: bud)
                    and: (TestCountingSource size: 600000000
                                getter: [:j | 700 + (j // 3000000)] budget: bud)]
            budget: (TestReadBudget limit: 512).
        ^self approx: r is: 787.0
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
        Transcript show: '--- Algorithm A: Median of Medians ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01Empty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Empty)'; cr.
                      failedTests add: 'Test A01 (Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02Single] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Single)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Single)'; cr.
                      failedTests add: 'Test A02 (Single)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03OutOfRange] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Out Of Range)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Out Of Range)'; cr.
                      failedTests add: 'Test A03 (Out Of Range)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04OneGroup] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (One Group)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (One Group)'; cr.
                      failedTests add: 'Test A04 (One Group)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05PivotIsNotMedian] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Pivot Is Not Median)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Pivot Is Not Median)'; cr.
                      failedTests add: 'Test A05 (Pivot Is Not Median)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06PartialLastGroup] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Partial Last Group)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Partial Last Group)'; cr.
                      failedTests add: 'Test A06 (Partial Last Group)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07ManyDuplicates] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Many Duplicates)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Many Duplicates)'; cr.
                      failedTests add: 'Test A07 (Many Duplicates)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08StablePartitionOrder] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Stable Partition Order)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Stable Partition Order)'; cr.
                      failedTests add: 'Test A08 (Stable Partition Order)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09AllRanks] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (All Ranks)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (All Ranks)'; cr.
                      failedTests add: 'Test A09 (All Ranks)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress)'; cr.
                      failedTests add: 'Test A10 (Stress)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Median of Two Sorted Arrays ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01BothEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Both Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Both Empty)'; cr.
                      failedTests add: 'Test B01 (Both Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02OneEmpty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (One Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (One Empty)'; cr.
                      failedTests add: 'Test B02 (One Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03SingleEach] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Single Each)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Single Each)'; cr.
                      failedTests add: 'Test B03 (Single Each)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04OddTotalInterleaved] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Odd Total Interleaved)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Odd Total Interleaved)'; cr.
                      failedTests add: 'Test B04 (Odd Total Interleaved)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05DisjointRanges] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Disjoint Ranges)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Disjoint Ranges)'; cr.
                      failedTests add: 'Test B05 (Disjoint Ranges)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06Duplicates] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Duplicates)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Duplicates)'; cr.
                      failedTests add: 'Test B06 (Duplicates)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07NoOverflow] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (No Overflow)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (No Overflow)'; cr.
                      failedTests add: 'Test B07 (No Overflow)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08HugeInterleaved] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Huge Interleaved)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Huge Interleaved)'; cr.
                      failedTests add: 'Test B08 (Huge Interleaved)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09HugeUnbalanced] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Huge Unbalanced)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Huge Unbalanced)'; cr.
                      failedTests add: 'Test B09 (Huge Unbalanced)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10HugeDuplicates] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Huge Duplicates)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Huge Duplicates)'; cr.
                      failedTests add: 'Test B10 (Huge Duplicates)'.
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
