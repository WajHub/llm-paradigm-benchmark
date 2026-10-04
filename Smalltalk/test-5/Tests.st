Object subclass: Tests [
    | ex |

    Tests class >> new [
        ^super new init
    ]

    init [
        ex := ExpressionImpl new.
    ]

    noVars [ ^#() ]

    evalStr: aString vars: aColl [
        | ast |
        ast := ex parseExpression: aString.
        ast isNil ifTrue: [^EvalResult status: #invalidOp value: 0.0].
        ^ex evaluate: ast vars: aColl
    ]

    valueOk: result expected: x [
        ^(result status = #ok) and: [(result value - x) abs < 1e-9]
    ]

    "======================================================================"
    " Algorithm A: parseExpression: (syntactic validity / AST construction) "
    "======================================================================"

    testAlgoA01SingleNumber [ ^(ex parseExpression: '42') notNil ]

    testAlgoA02SimpleBinary [ ^(ex parseExpression: '1 + 2 * 3') notNil ]

    testAlgoA03Parentheses [ ^(ex parseExpression: '2 * (3 + 4) - 5') notNil ]

    testAlgoA04FunctionCall [ ^(ex parseExpression: 'sqrt(16) + max(1, 2)') notNil ]

    testAlgoA05NestedAndUnary [ ^(ex parseExpression: '-min(max(1, 2), 3) + -(4)') notNil ]

    testAlgoA06DanglingOperator [ ^(ex parseExpression: '1 +') isNil ]

    testAlgoA07EmptyString [ ^(ex parseExpression: '') isNil ]

    testAlgoA08UnbalancedParens [ ^(ex parseExpression: '(1 + 2') isNil ]

    testAlgoA09TrailingGarbage [
        ^((ex parseExpression: '1 + 2)') isNil)
            and: [(ex parseExpression: '3 4') isNil]
    ]

    testAlgoA10BadFunction [
        ^((ex parseExpression: 'foo(1)') isNil)
            and: [((ex parseExpression: 'sqrt(1, 2)') isNil)
            and: [(ex parseExpression: 'max(1)') isNil]]
    ]

    "======================================================================"
    " Algorithm B: evaluate:vars: (numeric value + error statuses)          "
    "======================================================================"

    testAlgoB01Precedence [
        ^self valueOk: (self evalStr: '3 + 4 * 2' vars: self noVars) expected: 11.0
    ]

    testAlgoB02ParensOverride [
        ^self valueOk: (self evalStr: '(3 + 4) * 2' vars: self noVars) expected: 14.0
    ]

    testAlgoB03PowerRightAssoc [
        ^self valueOk: (self evalStr: '2 ^ 3 ^ 2' vars: self noVars) expected: 512.0
    ]

    testAlgoB04UnaryVsPower [
        ^self valueOk: (self evalStr: '-2 ^ 2' vars: self noVars) expected: -4.0
    ]

    testAlgoB05Variables [
        | vars |
        vars := Array
            with: (ExprVariable name: 'x' value: 3.0)
            with: (ExprVariable name: 'y' value: 4.0).
        ^self valueOk: (self evalStr: 'x * x + y * y' vars: vars) expected: 25.0
    ]

    testAlgoB06UndefinedVar [
        ^(self evalStr: 'x + 1' vars: self noVars) status = #undefinedVar
    ]

    testAlgoB07DivAndMod [
        ^(self valueOk: (self evalStr: '10 % 3' vars: self noVars) expected: 1.0)
            and: [(self evalStr: '5 / 0' vars: self noVars) status = #divByZero]
    ]

    testAlgoB08Functions [
        ^(self valueOk: (self evalStr: 'max(3, 7) + min(2, 5)' vars: self noVars) expected: 9.0)
            and: [(self valueOk: (self evalStr: 'abs(-5) + sqrt(9)' vars: self noVars) expected: 8.0)
            and: [self valueOk: (self evalStr: 'pow(2, 10)' vars: self noVars) expected: 1024.0]]
    ]

    testAlgoB09DomainError [
        ^(self evalStr: 'sqrt(-1)' vars: self noVars) status = #domainError
    ]

    testAlgoB10ErrorPropagation [
        | vars |
        vars := Array with: (ExprVariable name: 'x' value: 2.0).
        ^(self evalStr: 'x + 1 / (x - 2)' vars: vars) status = #divByZero
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
        Transcript show: '--- Algorithm A: Parsing & AST Construction ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01SingleNumber] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Single Number)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Single Number)'; cr.
                      failedTests add: 'Test A01 (Single Number)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02SimpleBinary] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Binary + Precedence)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Binary + Precedence)'; cr.
                      failedTests add: 'Test A02 (Binary + Precedence)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03Parentheses] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Parentheses)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Parentheses)'; cr.
                      failedTests add: 'Test A03 (Parentheses)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04FunctionCall] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Function Calls)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Function Calls)'; cr.
                      failedTests add: 'Test A04 (Function Calls)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05NestedAndUnary] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Nested + Unary)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Nested + Unary)'; cr.
                      failedTests add: 'Test A05 (Nested + Unary)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06DanglingOperator] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Dangling Operator)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Dangling Operator)'; cr.
                      failedTests add: 'Test A06 (Dangling Operator)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07EmptyString] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Empty String)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Empty String)'; cr.
                      failedTests add: 'Test A07 (Empty String)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08UnbalancedParens] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Unbalanced Parens)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Unbalanced Parens)'; cr.
                      failedTests add: 'Test A08 (Unbalanced Parens)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09TrailingGarbage] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Trailing Garbage)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Trailing Garbage)'; cr.
                      failedTests add: 'Test A09 (Trailing Garbage)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10BadFunction] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Bad Function Call)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Bad Function Call)'; cr.
                      failedTests add: 'Test A10 (Bad Function Call)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Evaluation & Error Semantics ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01Precedence] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Operator Precedence)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Operator Precedence)'; cr.
                      failedTests add: 'Test B01 (Operator Precedence)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02ParensOverride] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Parentheses Override)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Parentheses Override)'; cr.
                      failedTests add: 'Test B02 (Parentheses Override)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03PowerRightAssoc] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Power Right-Assoc)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Power Right-Assoc)'; cr.
                      failedTests add: 'Test B03 (Power Right-Assoc)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04UnaryVsPower] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Unary vs Power)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Unary vs Power)'; cr.
                      failedTests add: 'Test B04 (Unary vs Power)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05Variables] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Variables)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Variables)'; cr.
                      failedTests add: 'Test B05 (Variables)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06UndefinedVar] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Undefined Variable)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Undefined Variable)'; cr.
                      failedTests add: 'Test B06 (Undefined Variable)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07DivAndMod] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Division & Modulo)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Division & Modulo)'; cr.
                      failedTests add: 'Test B07 (Division & Modulo)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08Functions] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Built-in Functions)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Built-in Functions)'; cr.
                      failedTests add: 'Test B08 (Built-in Functions)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09DomainError] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Domain Error)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Domain Error)'; cr.
                      failedTests add: 'Test B09 (Domain Error)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10ErrorPropagation] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Error Propagation)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Error Propagation)'; cr.
                      failedTests add: 'Test B10 (Error Propagation)'.
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
