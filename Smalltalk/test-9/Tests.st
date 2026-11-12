Object subclass: Tests [
    | bt |

    Tests class >> new [
        ^super new init
    ]

    init [
        bt := BTreeImpl new.
    ]

    "======================================================================"
    " Helpers: serialisation, invariant checker, key generator              "
    "======================================================================"

    childrenOf: aNode [
        aNode children isNil ifTrue: [^#()].
        ^aNode children
    ]

    "Leaf: '(k1 k2 ...)'. Internal: '(' dump(c1) ' ' k1 ' ' dump(c2) ... dump(cLast) ')'.
     Empty tree: '()'. nil: 'NONE'."
    dump: aNode [
        | ws |
        aNode isNil ifTrue: [^'NONE'].
        ws := WriteStream on: String new.
        self dump: aNode on: ws.
        ^ws contents
    ]

    dump: aNode on: ws [
        | ks cs |
        ks := aNode keys asArray.
        cs := (self childrenOf: aNode) asArray.
        ws nextPut: $(.
        cs isEmpty
            ifTrue: [
                ks doWithIndex: [:k :i |
                    i > 1 ifTrue: [ws space].
                    ws print: k]]
            ifFalse: [
                self dump: (cs at: 1) on: ws.
                ks doWithIndex: [:k :i |
                    ws space; print: k; space.
                    self dump: (cs at: i + 1) on: ws]].
        ws nextPut: $)
    ]

    dumpOf: aNode is: aString [
        ^(self dump: aNode) = aString
    ]

    "Answer #(height nodeCount inorderKeys) if every B-tree invariant holds, nil otherwise:
     at most 2t-1 keys per node, at least t-1 in every non-root node, strictly ascending
     Integer keys inside the separator range, an internal node with k keys has k+1 children
     (an internal root has at least one key), all leaves at the same depth."
    check: root degree: t [
        | info |
        root isNil ifTrue: [^nil].
        info := Array with: nil with: 0 with: OrderedCollection new.
        (self checkNode: root depth: 1 lo: nil hi: nil isRoot: true degree: t info: info)
            ifFalse: [^nil].
        ^Array with: (info at: 1) with: (info at: 2) with: (info at: 3) asArray
    ]

    checkNode: x depth: d lo: lo hi: hi isRoot: isRoot degree: t info: info [
        | ks cs n |
        x isNil ifTrue: [^false].
        x keys isNil ifTrue: [^false].
        ks := x keys asArray.
        cs := (self childrenOf: x) asArray.
        n := ks size.
        info at: 2 put: (info at: 2) + 1.
        n > (2 * t - 1) ifTrue: [^false].
        (isRoot not and: [n < (t - 1)]) ifTrue: [^false].
        1 to: n do: [:i |
            | k |
            k := ks at: i.
            k isInteger ifFalse: [^false].
            (i > 1 and: [(ks at: i - 1) >= k]) ifTrue: [^false].
            (lo notNil and: [k <= lo]) ifTrue: [^false].
            (hi notNil and: [k >= hi]) ifTrue: [^false]].
        cs isEmpty ifTrue: [
            (info at: 1) isNil ifTrue: [info at: 1 put: d].
            (info at: 1) = d ifFalse: [^false].
            (info at: 3) addAll: ks.
            ^true].
        n = 0 ifTrue: [^false].
        cs size = (n + 1) ifFalse: [^false].
        1 to: n + 1 do: [:i |
            (self checkNode: (cs at: i)
                    depth: d + 1
                    lo: (i > 1 ifTrue: [ks at: i - 1] ifFalse: [lo])
                    hi: (i <= n ifTrue: [ks at: i] ifFalse: [hi])
                    isRoot: false
                    degree: t
                    info: info) ifFalse: [^false].
            i <= n ifTrue: [(info at: 3) add: (ks at: i)]].
        ^true
    ]

    "G(seed, count, mod): x := (x * 1103515245 + 12345) \\ 2147483648, output (x // 65536) \\ mod."
    genSeed: seed count: count mod: m [
        | x out |
        x := seed.
        out := Array new: count.
        1 to: count do: [:i |
            x := (x * 1103515245 + 12345) \\ 2147483648.
            out at: i put: (x // 65536) \\ m].
        ^out
    ]

    sortedDistinct: aCollection [
        ^(aCollection asSet asSortedCollection: [:a :b | a <= b]) asArray
    ]

    sumOf: aCollection [
        ^aCollection inject: 0 into: [:acc :each | acc + each]
    ]

    ascendingTens [ ^#(10 20 30 40 50 60 70 80 90 100) ]

    "======================================================================"
    " Algorithm A: insertAll:degree: (top-down CLRS insertion)             "
    "======================================================================"

    testAlgoA01Empty [
        ^self dumpOf: (bt insertAll: #() degree: 2) is: '()'
    ]

    testAlgoA02InvalidDegree [
        ^(bt insertAll: #(1 2 3) degree: 1) isNil
    ]

    testAlgoA03SingleLeaf [
        ^self dumpOf: (bt insertAll: #(5 1 3) degree: 3) is: '(1 3 5)'
    ]

    testAlgoA04RootSplit [
        ^self dumpOf: (bt insertAll: #(1 2 3 4) degree: 2) is: '((1) 2 (3 4))'
    ]

    testAlgoA05DuplicateOnFullRoot [
        ^self dumpOf: (bt insertAll: #(1 2 3 2) degree: 2) is: '(1 2 3)'
    ]

    testAlgoA06Ascending [
        ^self dumpOf: (bt insertAll: self ascendingTens degree: 2)
            is: '(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))'
    ]

    testAlgoA07ProactiveSplit [
        ^self dumpOf: (bt insertAll: #(10 9 8 7 6 5 4 3 2 1) degree: 2)
            is: '(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))'
    ]

    testAlgoA08TextbookT3 [
        ^self dumpOf: (bt insertAll: #(8 3 15 1 20 6 11 17 4 25 13 9 30 2 22 7 14 18) degree: 3)
            is: '((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))'
    ]

    testAlgoA09Invariants [
        | keys expected info |
        keys := self genSeed: 7 count: 100 mod: 1000.
        expected := self sortedDistinct: keys.
        ((keys first: 5) = #(564 806 868 674 531) and: [expected size = 95]) ifFalse: [^false].
        info := self check: (bt insertAll: keys degree: 3) degree: 3.
        info isNil ifTrue: [^false].
        ^(info at: 1) = 3
            and: [(info at: 2) = 28
            and: [(info at: 3) = expected]]
    ]

    testAlgoA10Stress [
        | keys expected root info |
        keys := self genSeed: 42 count: 2000 mod: 100000.
        expected := self sortedDistinct: keys.
        (expected size = 1937 and: [(self sumOf: expected) = 31779629]) ifFalse: [^false].
        root := bt insertAll: keys degree: 4.
        info := self check: root degree: 4.
        info isNil ifTrue: [^false].
        ^(info at: 1) = 5
            and: [(info at: 2) = 413
            and: [root keys asArray = #(15269)
            and: [(info at: 3) = expected]]]
    ]

    "======================================================================"
    " Algorithm B: deleteAll:from:degree: (top-down CLRS deletion)        "
    "======================================================================"

    testAlgoB01DeleteFromLeaf [
        ^self dumpOf: (bt deleteAll: #(3) from: #(5 1 3 9 7) degree: 3) is: '(1 5 7 9)'
    ]

    testAlgoB02AbsentKeyUnchanged [
        ^self dumpOf: (bt deleteAll: #(15) from: #(10 30 20 40) degree: 2) is: '((10) 20 (30 40))'
    ]

    testAlgoB03DeleteAll [
        ^self dumpOf: (bt deleteAll: #(50 10 100 30 70 20 90 40 80 60 999) from: self ascendingTens degree: 2)
            is: '()'
    ]

    testAlgoB04PredecessorPreferred [
        ^self dumpOf: (bt deleteAll: #(20) from: #(10 20 30 40 5) degree: 2) is: '((5) 10 (30 40))'
    ]

    testAlgoB05Successor [
        ^self dumpOf: (bt deleteAll: #(20) from: #(10 20 30 40 35) degree: 2) is: '((10) 30 (35 40))'
    ]

    testAlgoB06MergeChildren [
        ^self dumpOf: (bt deleteAll: #(4) from: #(14 3 4 11 5 15) degree: 2) is: '((3 5) 11 (14 15))'
    ]

    testAlgoB07BorrowLeftFirst [
        ^self dumpOf: (bt deleteAll: #(17) from: #(21 12 9 10 17 23 24) degree: 2)
            is: '((9) 10 (12) 21 (23 24))'
    ]

    testAlgoB08MergeRightFirst [
        ^self dumpOf: (bt deleteAll: #(7) from: #(3 4 19 12 7 15 22 28) degree: 2)
            is: '((3) 4 (12 15) 19 (22 28))'
    ]

    testAlgoB09RootShrink [
        ^self dumpOf: (bt deleteAll: #(10 20) from: self ascendingTens degree: 2)
            is: '((30) 40 (50) 60 (70) 80 (90 100))'
    ]

    testAlgoB10StressInvariants [
        | keys dels removed expected root info |
        keys := self genSeed: 9 count: 300 mod: 500.
        dels := self genSeed: 3 count: 250 mod: 500.
        removed := dels asSet.
        expected := (self sortedDistinct: keys) reject: [:k | removed includes: k].
        (expected size = 150 and: [(self sumOf: expected) = 39704]) ifFalse: [^false].
        root := bt deleteAll: dels from: keys degree: 3.
        info := self check: root degree: 3.
        info isNil ifTrue: [^false].
        ^(info at: 1) = 4
            and: [(info at: 2) = 55
            and: [root keys asArray = #(293)
            and: [(info at: 3) = expected]]]
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
        Transcript show: '--- Algorithm A: Insertion ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01Empty] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Empty)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Empty)'; cr.
                      failedTests add: 'Test A01 (Empty)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02InvalidDegree] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Invalid Degree)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Invalid Degree)'; cr.
                      failedTests add: 'Test A02 (Invalid Degree)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03SingleLeaf] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Single Leaf)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Single Leaf)'; cr.
                      failedTests add: 'Test A03 (Single Leaf)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04RootSplit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Root Split)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Root Split)'; cr.
                      failedTests add: 'Test A04 (Root Split)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05DuplicateOnFullRoot] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Duplicate On Full Root)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Duplicate On Full Root)'; cr.
                      failedTests add: 'Test A05 (Duplicate On Full Root)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06Ascending] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Ascending)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Ascending)'; cr.
                      failedTests add: 'Test A06 (Ascending)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07ProactiveSplit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Proactive Split)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Proactive Split)'; cr.
                      failedTests add: 'Test A07 (Proactive Split)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08TextbookT3] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Textbook t3)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Textbook t3)'; cr.
                      failedTests add: 'Test A08 (Textbook t3)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09Invariants] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Invariants)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Invariants)'; cr.
                      failedTests add: 'Test A09 (Invariants)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10Stress] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress)'; cr.
                      failedTests add: 'Test A10 (Stress)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Deletion ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01DeleteFromLeaf] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Delete From Leaf)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Delete From Leaf)'; cr.
                      failedTests add: 'Test B01 (Delete From Leaf)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02AbsentKeyUnchanged] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Absent Key Unchanged)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Absent Key Unchanged)'; cr.
                      failedTests add: 'Test B02 (Absent Key Unchanged)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03DeleteAll] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Delete All)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Delete All)'; cr.
                      failedTests add: 'Test B03 (Delete All)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04PredecessorPreferred] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Predecessor Preferred)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Predecessor Preferred)'; cr.
                      failedTests add: 'Test B04 (Predecessor Preferred)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05Successor] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Successor)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Successor)'; cr.
                      failedTests add: 'Test B05 (Successor)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06MergeChildren] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Merge Children)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Merge Children)'; cr.
                      failedTests add: 'Test B06 (Merge Children)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07BorrowLeftFirst] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Borrow Left First)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Borrow Left First)'; cr.
                      failedTests add: 'Test B07 (Borrow Left First)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08MergeRightFirst] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Merge Right First)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Merge Right First)'; cr.
                      failedTests add: 'Test B08 (Merge Right First)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09RootShrink] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Root Shrink)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Root Shrink)'; cr.
                      failedTests add: 'Test B09 (Root Shrink)'.
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
