Object subclass: Tests [
    | tsp |

    Tests class >> new [
        ^super new init
    ]

    init [
        tsp := TspApproxImpl new.
    ]

    "======================================================================"
    " Point sets (Arrays of #(x y)); point i of the set is vertex i (1-based) "
    "======================================================================"

    emptySet [ ^#() ]
    singleSet [ ^#(#(5 5)) ]
    twoSet [ ^#(#(0 0) #(3 4)) ]
    collinearSet [ ^#(#(0 0) #(4 0) #(1 0) #(9 0) #(6 0)) ]
    squareSet [ ^#(#(0 0) #(0 2) #(2 2) #(2 0)) ]
    parentTieSet [ ^#(#(2 0) #(0 3) #(2 3) #(3 4) #(1 4)) ]
    gridSet [ ^#(#(0 0) #(1 0) #(2 0) #(0 1) #(1 1) #(2 1) #(0 2) #(1 2) #(2 2)) ]
    dupSet [ ^#(#(3 3) #(3 3) #(0 0) #(3 3)) ]
    starSet [ ^#(#(5 5) #(5 0) #(0 5) #(10 5)) ]
    clustersSet [ ^#(#(0 0) #(20 0) #(1 1) #(21 1) #(0 20) #(20 20) #(1 21) #(21 21)) ]
    spiralSet [ ^#(#(0 0) #(8 0) #(8 8) #(0 8) #(2 2) #(6 2) #(6 6) #(2 6) #(4 4)) ]

    s12Set [
        ^#(#(81 33) #(69 61) #(56 93) #(77 0) #(65 25) #(72 14) #(14 48) #(33 32) #(73 63) #(71 87) #(5 8) #(54 24))
    ]

    s20Set [
        ^#(#(38 58) #(13 15) #(51 27) #(10 19) #(12 86) #(49 67) #(84 60) #(25 43) #(89 83) #(37 66)
           #(66 78) #(95 11) #(67 54) #(31 45) #(82 36) #(24 5) #(94 2) #(51 67) #(54 53) #(61 96))
    ]

    s40Set [
        ^#(#(81 33) #(69 61) #(56 93) #(77 0) #(65 25) #(72 14) #(14 48) #(33 32) #(73 63) #(71 87)
           #(5 8) #(54 24) #(22 71) #(51 45) #(55 89) #(29 78) #(87 65) #(32 67) #(53 10) #(27 83)
           #(36 30) #(41 96) #(2 37) #(8 85) #(78 74) #(59 59) #(76 26) #(9 63) #(63 86) #(7 17)
           #(91 65) #(27 22) #(7 85) #(95 32) #(35 71) #(7 65) #(12 61) #(82 60) #(5 35) #(74 66))
    ]

    "======================================================================"
    " Helpers                                                              "
    "======================================================================"

    dist: p to: q [
        ^((p at: 1) - (q at: 1)) abs + ((p at: 2) - (q at: 2)) abs
    ]

    "Closed tour cost; tour holds 1-based vertex numbers."
    costOf: tour points: pts [
        | n total |
        n := tour size.
        n <= 1 ifTrue: [^0].
        total := 0.
        1 to: n do: [:i |
            total := total + (self dist: (pts at: (tour at: i))
                                    to: (pts at: (tour at: i \\ n + 1)))].
        ^total
    ]

    "Valid = tour is a permutation of 1..n starting with 1, and cost equals the recomputed cost."
    isValid: r points: pts [
        | tour seen |
        r isNil ifTrue: [^false].
        r tour isNil ifTrue: [^false].
        tour := r tour asArray.
        tour size = pts size ifFalse: [^false].
        tour first = 1 ifFalse: [^false].
        seen := Set new.
        tour do: [:v |
            (v isInteger and: [v between: 1 and: pts size]) ifFalse: [^false].
            seen add: v].
        seen size = pts size ifFalse: [^false].
        ^r cost = (self costOf: tour points: pts)
    ]

    doubleTree: pts tour: expectedTour cost: expectedCost mst: expectedMst [
        | r |
        (tsp mstWeight: pts) = expectedMst ifFalse: [^false].
        r := tsp doubleTree: pts.
        r isNil ifTrue: [^false].
        r tour isNil ifTrue: [^false].
        ^r tour asArray = expectedTour and: [r cost = expectedCost]
    ]

    "Christofides checks: exact matching weight, valid tour, cost <= maxCost."
    christofides: pts matching: expectedMatching maxCost: maxCost [
        | r |
        (tsp matchingWeight: pts) = expectedMatching ifFalse: [^false].
        r := tsp christofides: pts.
        (self isValid: r points: pts) ifFalse: [^false].
        ^r cost <= maxCost
    ]

    "======================================================================"
    " Algorithm A: mstWeight: and doubleTree:                               "
    "======================================================================"

    testAlgoA01Empty [
        ^(tsp mstWeight: self emptySet) = 0
            and: [(tsp doubleTree: self emptySet) isNil]
    ]

    testAlgoA02SinglePoint [
        ^self doubleTree: self singleSet tour: #(1) cost: 0 mst: 0
    ]

    testAlgoA03TwoPoints [
        ^self doubleTree: self twoSet tour: #(1 2) cost: 14 mst: 7
    ]

    testAlgoA04CollinearUnsorted [
        ^self doubleTree: self collinearSet tour: #(1 3 2 5 4) cost: 18 mst: 9
    ]

    testAlgoA05Square [
        ^self doubleTree: self squareSet tour: #(1 2 3 4) cost: 8 mst: 6
    ]

    testAlgoA06ParentTieBreaking [
        ^self doubleTree: self parentTieSet tour: #(1 3 2 5 4) cost: 14 mst: 9
    ]

    testAlgoA07GridTies [
        ^self doubleTree: self gridSet tour: #(1 2 3 6 9 5 8 4 7) cost: 12 mst: 8
    ]

    testAlgoA08DuplicatePoints [
        ^self doubleTree: self dupSet tour: #(1 2 3 4) cost: 12 mst: 6
    ]

    testAlgoA09ClustersTwoApprox [
        | r |
        (self doubleTree: self clustersSet tour: #(1 2 4 6 8 3 5 7) cost: 128 mst: 68)
            ifFalse: [^false].
        r := tsp doubleTree: self clustersSet.
        ^r cost <= (2 * 88)
    ]

    testAlgoA10Stress [
        | pts r |
        pts := self s40Set.
        (tsp mstWeight: pts) = 503 ifFalse: [^false].
        r := tsp doubleTree: pts.
        (self isValid: r points: pts) ifFalse: [^false].
        ^r cost = 832
    ]

    "======================================================================"
    " Algorithm B: matchingWeight: and christofides:                        "
    "======================================================================"

    testAlgoB01Empty [
        ^(tsp matchingWeight: self emptySet) = 0
            and: [(tsp christofides: self emptySet) isNil]
    ]

    testAlgoB02TwoPointsDoubleEdge [
        | r |
        (self christofides: self twoSet matching: 7 maxCost: 14) ifFalse: [^false].
        r := tsp christofides: self twoSet.
        ^r tour asArray = #(1 2) and: [r cost = 14]
    ]

    testAlgoB03StarParallelEdges [
        | r |
        (self christofides: self starSet matching: 15 maxCost: 30) ifFalse: [^false].
        r := tsp christofides: self starSet.
        ^r cost = 30
    ]

    testAlgoB04Collinear [
        | r |
        (self christofides: self collinearSet matching: 9 maxCost: 18) ifFalse: [^false].
        r := tsp christofides: self collinearSet.
        ^r cost = 18
    ]

    testAlgoB05Grid [
        ^self christofides: self gridSet matching: 4 maxCost: 12
    ]

    testAlgoB06BeatsDoubleTree [
        ^self christofides: self clustersSet matching: 24 maxCost: 92
    ]

    testAlgoB07SpiralBound [
        | r |
        (self christofides: self spiralSet matching: 20 maxCost: 52) ifFalse: [^false].
        r := tsp christofides: self spiralSet.
        ^2 * r cost <= (3 * 44)
    ]

    testAlgoB08GreedyMatchingTrap [
        | r |
        (self christofides: self s12Set matching: 163 maxCost: 440) ifFalse: [^false].
        r := tsp christofides: self s12Set.
        ^2 * r cost <= (3 * 396)
    ]

    testAlgoB09DuplicatePoints [
        | r |
        (self christofides: self dupSet matching: 6 maxCost: 12) ifFalse: [^false].
        r := tsp christofides: self dupSet.
        ^r cost = 12
    ]

    testAlgoB10Stress [
        | r |
        (self christofides: self s20Set matching: 211 maxCost: 608) ifFalse: [^false].
        r := tsp christofides: self s20Set.
        ^2 * r cost <= (3 * 540)
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
        Transcript show: '--- Algorithm A: MST Double Tree ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01Empty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Empty)'; cr.
                      failedTests add: 'Test A01 (Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02SinglePoint] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Single Point)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Single Point)'; cr.
                      failedTests add: 'Test A02 (Single Point)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03TwoPoints] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Two Points)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Two Points)'; cr.
                      failedTests add: 'Test A03 (Two Points)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04CollinearUnsorted] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Collinear Unsorted)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Collinear Unsorted)'; cr.
                      failedTests add: 'Test A04 (Collinear Unsorted)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05Square] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Square)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Square)'; cr.
                      failedTests add: 'Test A05 (Square)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06ParentTieBreaking] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Parent Tie Breaking)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Parent Tie Breaking)'; cr.
                      failedTests add: 'Test A06 (Parent Tie Breaking)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07GridTies] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Grid Ties)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Grid Ties)'; cr.
                      failedTests add: 'Test A07 (Grid Ties)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08DuplicatePoints] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Duplicate Points)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Duplicate Points)'; cr.
                      failedTests add: 'Test A08 (Duplicate Points)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09ClustersTwoApprox] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Clusters Two Approx)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Clusters Two Approx)'; cr.
                      failedTests add: 'Test A09 (Clusters Two Approx)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress)'; cr.
                      failedTests add: 'Test A10 (Stress)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Christofides ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01Empty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Empty)'; cr.
                      failedTests add: 'Test B01 (Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02TwoPointsDoubleEdge] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Two Points Double Edge)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Two Points Double Edge)'; cr.
                      failedTests add: 'Test B02 (Two Points Double Edge)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03StarParallelEdges] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Star Parallel Edges)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Star Parallel Edges)'; cr.
                      failedTests add: 'Test B03 (Star Parallel Edges)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04Collinear] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Collinear)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Collinear)'; cr.
                      failedTests add: 'Test B04 (Collinear)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05Grid] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Grid)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Grid)'; cr.
                      failedTests add: 'Test B05 (Grid)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06BeatsDoubleTree] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Beats Double Tree)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Beats Double Tree)'; cr.
                      failedTests add: 'Test B06 (Beats Double Tree)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07SpiralBound] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Spiral Bound)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Spiral Bound)'; cr.
                      failedTests add: 'Test B07 (Spiral Bound)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08GreedyMatchingTrap] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Greedy Matching Trap)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Greedy Matching Trap)'; cr.
                      failedTests add: 'Test B08 (Greedy Matching Trap)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09DuplicatePoints] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Duplicate Points)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Duplicate Points)'; cr.
                      failedTests add: 'Test B09 (Duplicate Points)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Stress)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Stress)'; cr.
                      failedTests add: 'Test B10 (Stress)'.
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
