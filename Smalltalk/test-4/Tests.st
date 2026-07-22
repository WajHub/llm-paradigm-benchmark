Object subclass: Tests [
    | ks |

    Tests class >> new [
        ^super new init
    ]

    init [
        ks := KnapsackImpl new.
    ]

    referenceDpWeights: weights values: values capacity: capacity [
        | dp n |
        n := weights size.
        (n = 0 or: [capacity <= 0]) ifTrue: [^0].
        dp := Array new: capacity + 1 withAll: 0.
        1 to: n do: [:i |
            | w v |
            w := weights at: i.
            v := values at: i.
            capacity to: w by: -1 do: [:c |
                | cand |
                cand := (dp at: c - w + 1) + v.
                cand > (dp at: c + 1) ifTrue: [dp at: c + 1 put: cand]
            ]
        ].
        ^dp at: capacity + 1
    ]

    selectedEquals: actual expected: expected [
        actual isNil ifTrue: [^false].
        actual size = expected size ifFalse: [^false].
        1 to: expected size do: [:i |
            (actual at: i) = (expected at: i) ifFalse: [^false]
        ].
        ^true
    ]

    testAlgoA01Empty [
        ^(ks maxValueOf: #() values: #() capacity: 10) = 0
    ]

    testAlgoA02SingleFit [
        ^(ks maxValueOf: #(5) values: #(10) capacity: 10) = 10
    ]

    testAlgoA03TooHeavy [
        ^(ks maxValueOf: #(15) values: #(10) capacity: 10) = 0
    ]

    testAlgoA04CapZero [
        ^(ks maxValueOf: #(1 2 3) values: #(10 20 30) capacity: 0) = 0
    ]

    testAlgoA05ChooseBetter [
        ^(ks maxValueOf: #(5 6) values: #(10 11) capacity: 10) = 11
    ]

    testAlgoA06Textbook [
        ^(ks maxValueOf: #(2 3 4 5) values: #(3 4 5 6) capacity: 5) = 7
    ]

    testAlgoA07GreedyTrap [
        ^(ks maxValueOf: #(10 20 30) values: #(60 100 120) capacity: 50) = 220
    ]

    testAlgoA08SameItems [
        ^(ks maxValueOf: #(3 3 3 3) values: #(5 5 5 5) capacity: 10) = 15
    ]

    testAlgoA09TightFit [
        ^(ks maxValueOf: #(3 4 5 6) values: #(2 3 4 5) capacity: 10) = 8
    ]

    testAlgoA10Stress [
        | w v expected |
        w := Array new: 50.
        v := Array new: 50.
        1 to: 50 do: [:i |
            w at: i put: i.
            v at: i put: i * 2
        ].
        expected := self referenceDpWeights: w values: v capacity: 100.
        ^(ks maxValueOf: w values: v capacity: 100) = expected
    ]

    testAlgoB01SingleSelection [
        | r |
        r := ks solveWeights: #(5) values: #(10) capacity: 10.
        r isNil ifTrue: [^false].
        ^(r maxValue = 10) and: [
            (r totalWeight = 5) and: [
                self selectedEquals: r selected expected: #(1)]]
    ]

    testAlgoB02ChooseBetterSelection [
        | r |
        r := ks solveWeights: #(5 6) values: #(10 11) capacity: 10.
        r isNil ifTrue: [^false].
        ^(r maxValue = 11) and: [
            (r totalWeight = 6) and: [
                self selectedEquals: r selected expected: #(0 1)]]
    ]

    testAlgoB03TextbookSelection [
        | r |
        r := ks solveWeights: #(2 3 4 5) values: #(3 4 5 6) capacity: 5.
        r isNil ifTrue: [^false].
        ^(r maxValue = 7) and: [
            (r totalWeight = 5) and: [
                self selectedEquals: r selected expected: #(1 1 0 0)]]
    ]

    testAlgoB04GreedyTrapSelection [
        | r |
        r := ks solveWeights: #(10 20 30) values: #(60 100 120) capacity: 50.
        r isNil ifTrue: [^false].
        ^(r maxValue = 220) and: [
            (r totalWeight = 50) and: [
                self selectedEquals: r selected expected: #(0 1 1)]]
    ]

    testAlgoB05CapZeroSelection [
        | r |
        r := ks solveWeights: #(1 2 3) values: #(10 20 30) capacity: 0.
        r isNil ifTrue: [^false].
        ^(r maxValue = 0) and: [
            (r totalWeight = 0) and: [
                self selectedEquals: r selected expected: #(0 0 0)]]
    ]

    testAlgoB06TooHeavySelection [
        | r |
        r := ks solveWeights: #(15) values: #(10) capacity: 10.
        r isNil ifTrue: [^false].
        ^(r maxValue = 0) and: [
            (r totalWeight = 0) and: [
                self selectedEquals: r selected expected: #(0)]]
    ]

    testAlgoB07AllFit [
        | r |
        r := ks solveWeights: #(1 2 3) values: #(10 20 30) capacity: 10.
        r isNil ifTrue: [^false].
        ^(r maxValue = 60) and: [
            (r totalWeight = 6) and: [
                self selectedEquals: r selected expected: #(1 1 1)]]
    ]

    testAlgoB08WeightInvariant [
        | r w capacity sumW |
        w := #(10 20 30).
        capacity := 50.
        r := ks solveWeights: w values: #(60 100 120) capacity: capacity.
        r isNil ifTrue: [^false].
        r selected isNil ifTrue: [^false].
        sumW := 0.
        1 to: w size do: [:i |
            sumW := sumW + ((r selected at: i) * (w at: i))
        ].
        ^(sumW <= capacity) and: [sumW = r totalWeight]
    ]

    testAlgoB09ValueInvariant [
        | r v sumV |
        v := #(60 100 120).
        r := ks solveWeights: #(10 20 30) values: v capacity: 50.
        r isNil ifTrue: [^false].
        r selected isNil ifTrue: [^false].
        sumV := 0.
        1 to: v size do: [:i |
            sumV := sumV + ((r selected at: i) * (v at: i))
        ].
        ^sumV = r maxValue
    ]

    testAlgoB10StressInvariants [
        | w v capacity expected r sumW sumV |
        capacity := 100.
        w := Array new: 50.
        v := Array new: 50.
        1 to: 50 do: [:i |
            w at: i put: i.
            v at: i put: i * 2
        ].
        expected := self referenceDpWeights: w values: v capacity: capacity.
        r := ks solveWeights: w values: v capacity: capacity.
        r isNil ifTrue: [^false].
        r selected isNil ifTrue: [^false].
        r selected size = 50 ifFalse: [^false].
        sumW := 0.
        sumV := 0.
        1 to: 50 do: [:i |
            | bit |
            bit := r selected at: i.
            ((bit = 0) or: [bit = 1]) ifFalse: [^false].
            sumW := sumW + (bit * (w at: i)).
            sumV := sumV + (bit * (v at: i))
        ].
        ^(r maxValue = expected)
            and: [(sumW <= capacity)
            and: [(sumW = r totalWeight)
            and: [sumV = r maxValue]]]
    ]

    runAll [
        | failedCount totalTests failedTests |
        failedCount := 0.
        totalTests := 0.
        failedTests := OrderedCollection new.

        Transcript show: '=== START ==='; cr.
        Transcript cr.
        Transcript show: '--- Algorithm A: Maximum Value ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01Empty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Empty)'; cr.
                      failedTests add: 'Test A01 (Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02SingleFit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Single Fit)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Single Fit)'; cr.
                      failedTests add: 'Test A02 (Single Fit)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03TooHeavy] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Too Heavy)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Too Heavy)'; cr.
                      failedTests add: 'Test A03 (Too Heavy)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04CapZero] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Capacity Zero)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Capacity Zero)'; cr.
                      failedTests add: 'Test A04 (Capacity Zero)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05ChooseBetter] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Choose Better)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Choose Better)'; cr.
                      failedTests add: 'Test A05 (Choose Better)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06Textbook] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Textbook)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Textbook)'; cr.
                      failedTests add: 'Test A06 (Textbook)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07GreedyTrap] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Greedy Trap)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Greedy Trap)'; cr.
                      failedTests add: 'Test A07 (Greedy Trap)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08SameItems] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Same Items)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Same Items)'; cr.
                      failedTests add: 'Test A08 (Same Items)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09TightFit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Tight Fit)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Tight Fit)'; cr.
                      failedTests add: 'Test A09 (Tight Fit)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress 50 Items)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress 50 Items)'; cr.
                      failedTests add: 'Test A10 (Stress 50 Items)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Item Selection ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01SingleSelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Single Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Single Selection)'; cr.
                      failedTests add: 'Test B01 (Single Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02ChooseBetterSelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Choose Better Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Choose Better Selection)'; cr.
                      failedTests add: 'Test B02 (Choose Better Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03TextbookSelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Textbook Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Textbook Selection)'; cr.
                      failedTests add: 'Test B03 (Textbook Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04GreedyTrapSelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Greedy Trap Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Greedy Trap Selection)'; cr.
                      failedTests add: 'Test B04 (Greedy Trap Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05CapZeroSelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Capacity Zero Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Capacity Zero Selection)'; cr.
                      failedTests add: 'Test B05 (Capacity Zero Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06TooHeavySelection] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Too Heavy Selection)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Too Heavy Selection)'; cr.
                      failedTests add: 'Test B06 (Too Heavy Selection)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07AllFit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (All Fit)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (All Fit)'; cr.
                      failedTests add: 'Test B07 (All Fit)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08WeightInvariant] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Weight Invariant)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Weight Invariant)'; cr.
                      failedTests add: 'Test B08 (Weight Invariant)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09ValueInvariant] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Value Invariant)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Value Invariant)'; cr.
                      failedTests add: 'Test B09 (Value Invariant)'.
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
