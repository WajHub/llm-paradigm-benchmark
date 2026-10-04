Object subclass: Tests [
    | sd |

    Tests class >> new [
        ^super new init
    ]

    init [
        sd := SudokuImpl new.
    ]

    "======================================================================"
    " Grids: flat 81-element Arrays, row-major, 0 = empty.                  "
    " Cell (row r, col c), both 1-based, is at index (r - 1) * 9 + c.       "
    "======================================================================"

    gridFrom: aString [
        ^(aString select: [:ch | ch isDigit]) asArray collect: [:ch | ch digitValue]
    ]

    copyOf: aGrid row: r col: c put: v [
        | g |
        g := aGrid copy.
        g at: (r - 1) * 9 + c put: v.
        ^g
    ]

    zeros: n [ ^Array new: n withAll: 0 ]

    emptyGrid [ ^self zeros: 81 ]

    classic [
        ^self gridFrom: '530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079'
    ]

    solved [
        ^self gridFrom: '534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179'
    ]

    inkala [
        ^self gridFrom: '800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402'
    ]

    inkalaSol [
        ^self gridFrom: '812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452'
    ]

    antiBf [
        ^self gridFrom: '000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009'
    ]

    antiBfSol [
        ^self gridFrom: '987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219'
    ]

    "CLASSIC with (row 2, col 2) = 8: clashes only with the 8 at (row 3, col 3) in the top-left box."
    boxConflict [ ^self copyOf: self classic row: 2 col: 2 put: 8 ]

    "EMPTY with (row 1, col 1) = 1 and (row 2, col 2) = 1."
    boxConflict2 [
        ^self copyOf: (self copyOf: self emptyGrid row: 1 col: 1 put: 1) row: 2 col: 2 put: 1
    ]

    "CLASSIC with (row 1, col 9) = 5: row 1 already has a 5."
    rowConflict [ ^self copyOf: self classic row: 1 col: 9 put: 5 ]

    "CLASSIC with (row 9, col 1) = 5: column 1 already has a 5."
    colConflict [ ^self copyOf: self classic row: 9 col: 1 put: 5 ]

    "EMPTY with row 1 = 1 2 3 4 5 6 7 8 0 and (row 5, col 9) = 9: valid, but (row 1, col 9) has no candidate."
    deadCell [
        | g |
        g := self emptyGrid.
        1 to: 8 do: [:c | g at: c put: c].
        ^self copyOf: g row: 5 col: 9 put: 9
    ]

    "CLASSIC with (row 1, col 3) = 1: valid, every empty cell has a candidate, but no solution."
    hidden [ ^self copyOf: self classic row: 1 col: 3 put: 1 ]

    "CLASSIC with (row 3, col 3) cleared: exactly 8 solutions."
    multi [ ^self copyOf: self classic row: 3 col: 3 put: 0 ]

    same: actual as: expected [
        actual isNil ifTrue: [^false].
        ^actual asArray = expected asArray
    ]

    "======================================================================"
    " Algorithm A: isValid: and candidates:row:col:                         "
    "======================================================================"

    testAlgoA01EmptyGridValid [
        ^(sd isValid: self emptyGrid) = true
    ]

    testAlgoA02SolvedGridValid [
        ^((sd isValid: self solved) = true)
            and: [(sd isValid: self classic) = true]
    ]

    testAlgoA03RowConflict [
        ^((sd isValid: self rowConflict) = false)
            and: [(sd isValid: self classic) = true]
    ]

    testAlgoA04ColumnConflict [
        ^((sd isValid: self colConflict) = false)
            and: [(sd isValid: self classic) = true]
    ]

    testAlgoA05BoxOnlyConflict [
        ^((sd isValid: self boxConflict) = false)
            and: [((sd isValid: self boxConflict2) = false)
            and: [(sd isValid: self classic) = true]]
    ]

    testAlgoA06WrongLength [
        ^((sd isValid: (self zeros: 80)) = false)
            and: [((sd isValid: (self zeros: 82)) = false)
            and: [((sd isValid: self solved , #(0)) = false)
            and: [(sd isValid: self solved) = true]]]
    ]

    testAlgoA07ValueOutOfRange [
        ^((sd isValid: (self copyOf: self classic row: 1 col: 3 put: 10)) = false)
            and: [((sd isValid: (self copyOf: self classic row: 1 col: 3 put: -1)) = false)
            and: [(sd isValid: self classic) = true]]
    ]

    testAlgoA08CandidatesBasic [
        | g |
        g := self classic.
        ^(self same: (sd candidates: g row: 1 col: 3) as: #(1 2 4))
            and: [(self same: (sd candidates: g row: 5 col: 5) as: #(5))
            and: [self same: (sd candidates: g row: 9 col: 1) as: #(1 2 3)]]
    ]

    testAlgoA09CandidatesEdgeCells [
        ^(self same: (sd candidates: self classic row: 1 col: 1) as: #())
            and: [(self same: (sd candidates: self classic row: 9 col: 9) as: #())
            and: [self same: (sd candidates: self emptyGrid row: 9 col: 9) as: #(1 2 3 4 5 6 7 8 9)]]
    ]

    testAlgoA10CandidatesSweep [
        | full g total |
        full := self solved.
        1 to: 9 do: [:r |
            1 to: 9 do: [:c |
                | digit |
                digit := full at: (r - 1) * 9 + c.
                (self same: (sd candidates: (self copyOf: full row: r col: c put: 0) row: r col: c)
                      as: (Array with: digit)) ifFalse: [^false]]].
        g := self classic.
        total := 0.
        1 to: 9 do: [:r |
            1 to: 9 do: [:c |
                total := total + (sd candidates: g row: r col: c) size]].
        ^total = 153
    ]

    "======================================================================"
    " Algorithm B: solve: and countSolutions:limit:                         "
    "======================================================================"

    testAlgoB01AlreadySolved [
        ^self same: (sd solve: self solved) as: self solved
    ]

    testAlgoB02ClassicPuzzle [
        | input |
        input := self classic.
        ^(self same: (sd solve: input) as: self solved)
            and: [input = self classic]
    ]

    testAlgoB03InvalidGrid [
        ^((sd solve: self boxConflict) isNil)
            and: [((sd solve: (self zeros: 80)) isNil)
            and: [((sd solve: (self copyOf: self classic row: 1 col: 3 put: 10)) isNil)
            and: [((sd countSolutions: self boxConflict limit: 5) = 0)
            and: [(sd countSolutions: (self zeros: 80) limit: 5) = 0]]]]
    ]

    testAlgoB04DeadCell [
        ^((sd solve: self deadCell) isNil)
            and: [(sd countSolutions: self deadCell limit: 5) = 0]
    ]

    testAlgoB05HiddenContradiction [
        ^((sd solve: self hidden) isNil)
            and: [(sd countSolutions: self hidden limit: 5) = 0]
    ]

    testAlgoB06BacktrackingRequired [
        ^self same: (sd solve: self inkala) as: self inkalaSol
    ]

    testAlgoB07CountUnique [
        ^((sd countSolutions: self classic limit: 2) = 1)
            and: [(sd countSolutions: self solved limit: 2) = 1]
    ]

    testAlgoB08CountMultiple [
        ^((sd countSolutions: self multi limit: 100) = 8)
            and: [((sd countSolutions: self multi limit: 5) = 5)
            and: [(sd countSolutions: self multi limit: 1) = 1]]
    ]

    testAlgoB09CountEmptyGridLimit [
        ^((sd countSolutions: self emptyGrid limit: 2) = 2)
            and: [((sd countSolutions: self emptyGrid limit: 1) = 1)
            and: [((sd countSolutions: self emptyGrid limit: 0) = 0)
            and: [(sd countSolutions: self emptyGrid limit: -3) = 0]]]
    ]

    testAlgoB10StressAntiBruteForce [
        ^self same: (sd solve: self antiBf) as: self antiBfSol
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
        Transcript show: '--- Algorithm A: Validation and Candidates ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01EmptyGridValid] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Empty Grid Valid)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Empty Grid Valid)'; cr.
                      failedTests add: 'Test A01 (Empty Grid Valid)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02SolvedGridValid] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Solved Grid Valid)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Solved Grid Valid)'; cr.
                      failedTests add: 'Test A02 (Solved Grid Valid)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03RowConflict] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Row Conflict)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Row Conflict)'; cr.
                      failedTests add: 'Test A03 (Row Conflict)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04ColumnConflict] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Column Conflict)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Column Conflict)'; cr.
                      failedTests add: 'Test A04 (Column Conflict)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05BoxOnlyConflict] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Box Only Conflict)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Box Only Conflict)'; cr.
                      failedTests add: 'Test A05 (Box Only Conflict)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06WrongLength] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Wrong Length)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Wrong Length)'; cr.
                      failedTests add: 'Test A06 (Wrong Length)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07ValueOutOfRange] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Value Out Of Range)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Value Out Of Range)'; cr.
                      failedTests add: 'Test A07 (Value Out Of Range)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08CandidatesBasic] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Candidates Basic)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Candidates Basic)'; cr.
                      failedTests add: 'Test A08 (Candidates Basic)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09CandidatesEdgeCells] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Candidates Edge Cells)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Candidates Edge Cells)'; cr.
                      failedTests add: 'Test A09 (Candidates Edge Cells)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10CandidatesSweep] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Candidates Sweep)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Candidates Sweep)'; cr.
                      failedTests add: 'Test A10 (Candidates Sweep)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Solving ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01AlreadySolved] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Already Solved)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Already Solved)'; cr.
                      failedTests add: 'Test B01 (Already Solved)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02ClassicPuzzle] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Classic Puzzle)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Classic Puzzle)'; cr.
                      failedTests add: 'Test B02 (Classic Puzzle)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03InvalidGrid] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Invalid Grid)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Invalid Grid)'; cr.
                      failedTests add: 'Test B03 (Invalid Grid)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04DeadCell] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Dead Cell)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Dead Cell)'; cr.
                      failedTests add: 'Test B04 (Dead Cell)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05HiddenContradiction] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Hidden Contradiction)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Hidden Contradiction)'; cr.
                      failedTests add: 'Test B05 (Hidden Contradiction)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06BacktrackingRequired] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Backtracking Required)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Backtracking Required)'; cr.
                      failedTests add: 'Test B06 (Backtracking Required)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07CountUnique] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Count Unique)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Count Unique)'; cr.
                      failedTests add: 'Test B07 (Count Unique)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08CountMultiple] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Count Multiple)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Count Multiple)'; cr.
                      failedTests add: 'Test B08 (Count Multiple)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09CountEmptyGridLimit] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Count Empty Grid Limit)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Count Empty Grid Limit)'; cr.
                      failedTests add: 'Test B09 (Count Empty Grid Limit)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10StressAntiBruteForce] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Stress Anti Brute Force)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Stress Anti Brute Force)'; cr.
                      failedTests add: 'Test B10 (Stress Anti Brute Force)'.
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
