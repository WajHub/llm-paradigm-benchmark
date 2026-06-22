Object subclass: Tests [
    | sp |

    Tests class >> new [
        ^super new init
    ]

    init [
        sp := ShortestPathImpl new.
    ]

    distanceIs: actual expected: expected [
        (expected = Float infinity or: [expected >= 1.0e18]) ifTrue: [
            ^actual = Float infinity or: [actual >= 1.0e18]
        ].
        ^(actual - expected) abs < 1.0e-9
    ]

    checkDistance: result target: target expected: expected [
        ^self distanceIs: (sp getShortestDistance: result target: target) expected: expected
    ]

    createLinearChain: numVertices weight: weight [
        | graph |
        graph := sp createGraph: numVertices.
        0 to: numVertices - 2 do: [:i |
            sp addEdge: graph from: i to: i + 1 weight: weight
        ].
        ^graph
    ]

    pathEquals: path expected: expected [
        path isNil ifTrue: [^expected isNil].
        expected isNil ifTrue: [^false].
        ^path = expected
    ]

    "======================================================================"
    " Algorithm A: Shortest Distances                                      "
    "======================================================================"

    testAlgoA01LinearChain [
        | graph result passed |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 1 to: 2 weight: 2.0.
        sp addEdge: graph from: 2 to: 3 weight: 3.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        passed := true.
        (self checkDistance: result target: 0 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 1 expected: 1.0) ifFalse: [passed := false].
        (self checkDistance: result target: 2 expected: 3.0) ifFalse: [passed := false].
        (self checkDistance: result target: 3 expected: 6.0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA02Diamond [
        | graph result passed |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 0 to: 2 weight: 4.0.
        sp addEdge: graph from: 1 to: 3 weight: 6.0.
        sp addEdge: graph from: 2 to: 3 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        passed := true.
        (self checkDistance: result target: 0 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 1 expected: 1.0) ifFalse: [passed := false].
        (self checkDistance: result target: 2 expected: 4.0) ifFalse: [passed := false].
        (self checkDistance: result target: 3 expected: 5.0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA03Disconnected [
        | graph result passed |
        graph := sp createGraph: 5.
        sp addEdge: graph from: 0 to: 1 weight: 2.0.
        sp addEdge: graph from: 1 to: 2 weight: 3.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        passed := true.
        (self checkDistance: result target: 0 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 1 expected: 2.0) ifFalse: [passed := false].
        (self checkDistance: result target: 2 expected: 5.0) ifFalse: [passed := false].
        (self checkDistance: result target: 3 expected: Float infinity) ifFalse: [passed := false].
        (self checkDistance: result target: 4 expected: Float infinity) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA04SingleVertex [
        | graph result |
        graph := sp createGraph: 1.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        ^self checkDistance: result target: 0 expected: 0.0
    ]

    testAlgoA05ParallelEdges [
        | graph result |
        graph := sp createGraph: 2.
        sp addEdge: graph from: 0 to: 1 weight: 5.0.
        sp addEdge: graph from: 0 to: 1 weight: 2.0.
        sp addEdge: graph from: 0 to: 1 weight: 8.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        ^self checkDistance: result target: 1 expected: 2.0
    ]

    testAlgoA06ZeroWeightEdges [
        | graph result passed |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 0.0.
        sp addEdge: graph from: 1 to: 2 weight: 0.0.
        sp addEdge: graph from: 2 to: 3 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        passed := true.
        (self checkDistance: result target: 1 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 2 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 3 expected: 1.0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA07NullGraph [
        | result |
        result := sp dijkstra: nil source: 0.
        ^result isNil
    ]

    testAlgoA08InvalidSource [
        | graph resultHigh resultLow |
        graph := sp createGraph: 3.

        resultHigh := sp dijkstra: graph source: 5.
        resultLow := sp dijkstra: graph source: -1.

        ^resultHigh isNil and: [resultLow isNil]
    ]

    testAlgoA09ComplexGraph [
        | graph result passed |
        graph := sp createGraph: 6.
        sp addEdge: graph from: 0 to: 1 weight: 7.0.
        sp addEdge: graph from: 0 to: 2 weight: 9.0.
        sp addEdge: graph from: 0 to: 5 weight: 14.0.
        sp addEdge: graph from: 1 to: 2 weight: 10.0.
        sp addEdge: graph from: 1 to: 3 weight: 15.0.
        sp addEdge: graph from: 2 to: 3 weight: 11.0.
        sp addEdge: graph from: 2 to: 5 weight: 2.0.
        sp addEdge: graph from: 3 to: 4 weight: 6.0.
        sp addEdge: graph from: 4 to: 5 weight: 9.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        passed := true.
        (self checkDistance: result target: 0 expected: 0.0) ifFalse: [passed := false].
        (self checkDistance: result target: 1 expected: 7.0) ifFalse: [passed := false].
        (self checkDistance: result target: 2 expected: 9.0) ifFalse: [passed := false].
        (self checkDistance: result target: 3 expected: 20.0) ifFalse: [passed := false].
        (self checkDistance: result target: 4 expected: 26.0) ifFalse: [passed := false].
        (self checkDistance: result target: 5 expected: 11.0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA10Stress [
        | graph result |
        graph := self createLinearChain: 1000 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        ^self checkDistance: result target: 999 expected: 999.0
    ]

    "======================================================================"
    " Algorithm B: Path Reconstruction                                     "
    "======================================================================"

    testAlgoB01SimplePath [
        | graph result path expected |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 1 to: 2 weight: 2.0.
        sp addEdge: graph from: 2 to: 3 weight: 3.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 3.
        expected := OrderedCollection with: 0 with: 1 with: 2 with: 3.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB02DiamondPath [
        | graph result path expected |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 0 to: 2 weight: 4.0.
        sp addEdge: graph from: 1 to: 3 weight: 6.0.
        sp addEdge: graph from: 2 to: 3 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 3.
        expected := OrderedCollection with: 0 with: 2 with: 3.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB03SelfPath [
        | graph result path expected |
        graph := sp createGraph: 3.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 1 to: 2 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 0.
        expected := OrderedCollection with: 0.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB04Unreachable [
        | graph result path |
        graph := sp createGraph: 5.
        sp addEdge: graph from: 0 to: 1 weight: 2.0.
        sp addEdge: graph from: 1 to: 2 weight: 3.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 4.
        ^path isNil
    ]

    testAlgoB05LongChain [
        | graph result path expected i |
        graph := self createLinearChain: 10 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 9.
        expected := OrderedCollection new.
        0 to: 9 do: [:v | expected add: v].

        ^self pathEquals: path expected: expected
    ]

    testAlgoB06Cycle [
        | graph result path expected |
        graph := sp createGraph: 4.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 1 to: 2 weight: 1.0.
        sp addEdge: graph from: 2 to: 0 weight: 1.0.
        sp addEdge: graph from: 1 to: 3 weight: 2.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 3.
        expected := OrderedCollection with: 0 with: 1 with: 3.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB07Star [
        | graph result path expected |
        graph := sp createGraph: 5.
        sp addEdge: graph from: 0 to: 1 weight: 2.0.
        sp addEdge: graph from: 0 to: 2 weight: 3.0.
        sp addEdge: graph from: 0 to: 3 weight: 1.0.
        sp addEdge: graph from: 0 to: 4 weight: 5.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 3.
        expected := OrderedCollection with: 0 with: 3.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB08NullResult [
        | path |
        path := sp reconstructPath: nil target: 0.
        ^path isNil
    ]

    testAlgoB09Bidirectional [
        | graph result path expected |
        graph := sp createGraph: 3.
        sp addEdge: graph from: 0 to: 1 weight: 1.0.
        sp addEdge: graph from: 1 to: 0 weight: 10.0.
        sp addEdge: graph from: 1 to: 2 weight: 1.0.
        sp addEdge: graph from: 0 to: 2 weight: 5.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 2.
        expected := OrderedCollection with: 0 with: 1 with: 2.

        ^self pathEquals: path expected: expected
    ]

    testAlgoB10StressPath [
        | graph result path |
        graph := self createLinearChain: 1000 weight: 1.0.

        result := sp dijkstra: graph source: 0.
        result isNil ifTrue: [^false].

        path := sp reconstructPath: result target: 999.
        path isNil ifTrue: [^false].

        ^path size = 1000 and: [(path at: 1) = 0 and: [(path at: 1000) = 999]]
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
        Transcript show: '--- Algorithm A: Shortest Distances ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01LinearChain] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Linear Chain)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Linear Chain)'; cr.
                      failedTests add: 'Test A01 (Linear Chain)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02Diamond] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Diamond)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Diamond)'; cr.
                      failedTests add: 'Test A02 (Diamond)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03Disconnected] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Disconnected)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Disconnected)'; cr.
                      failedTests add: 'Test A03 (Disconnected)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04SingleVertex] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Single Vertex)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Single Vertex)'; cr.
                      failedTests add: 'Test A04 (Single Vertex)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05ParallelEdges] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Parallel Edges)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Parallel Edges)'; cr.
                      failedTests add: 'Test A05 (Parallel Edges)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06ZeroWeightEdges] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Zero-Weight Edges)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Zero-Weight Edges)'; cr.
                      failedTests add: 'Test A06 (Zero-Weight Edges)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07NullGraph] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Null Graph)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Null Graph)'; cr.
                      failedTests add: 'Test A07 (Null Graph)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08InvalidSource] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Invalid Source)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Invalid Source)'; cr.
                      failedTests add: 'Test A08 (Invalid Source)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09ComplexGraph] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Complex Graph)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Complex Graph)'; cr.
                      failedTests add: 'Test A09 (Complex Graph)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress 1000-Chain)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress 1000-Chain)'; cr.
                      failedTests add: 'Test A10 (Stress 1000-Chain)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Path Reconstruction ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01SimplePath] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Simple Path)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Simple Path)'; cr.
                      failedTests add: 'Test B01 (Simple Path)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02DiamondPath] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Diamond Path)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Diamond Path)'; cr.
                      failedTests add: 'Test B02 (Diamond Path)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03SelfPath] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Self Path)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Self Path)'; cr.
                      failedTests add: 'Test B03 (Self Path)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04Unreachable] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Unreachable)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Unreachable)'; cr.
                      failedTests add: 'Test B04 (Unreachable)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05LongChain] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Long Chain)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Long Chain)'; cr.
                      failedTests add: 'Test B05 (Long Chain)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06Cycle] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Cycle)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Cycle)'; cr.
                      failedTests add: 'Test B06 (Cycle)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07Star] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Star)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Star)'; cr.
                      failedTests add: 'Test B07 (Star)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08NullResult] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Null Result)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Null Result)'; cr.
                      failedTests add: 'Test B08 (Null Result)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09Bidirectional] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Bidirectional)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Bidirectional)'; cr.
                      failedTests add: 'Test B09 (Bidirectional)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10StressPath] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Stress Path 1000-Chain)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Stress Path 1000-Chain)'; cr.
                      failedTests add: 'Test B10 (Stress Path 1000-Chain)'.
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
