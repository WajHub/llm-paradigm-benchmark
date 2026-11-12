Object subclass: ExpressionImpl [
    | input pos |

    ExpressionImpl class >> new [
        ^super new init
    ]

    init [
        input := ''.
        pos := 1.
        ^self
    ]

    setInput: aString [
        input := aString.
        pos := 1.
        ^self
    ]

    parseExpression: aString [
        | parser |
        aString isNil ifTrue: [^nil].
        parser := self class new setInput: aString.
        ^[parser parseAll] on: Error do: [:e | e return: nil]
    ]

    evaluate: ast vars: aCollection [
        ^self evalNode: ast vars: aCollection
    ]

    "----------------------------------------------------------------"
    "Parsing"
    "----------------------------------------------------------------"

    parseError [
        ^Error new signal: 'Invalid expression'
    ]

    parseAll [
        | node |
        node := self parseExpr.
        self peek notNil ifTrue: [self parseError].
        ^node
    ]

    peek [
        self skipSpaces.
        ^pos <= input size ifTrue: [input at: pos] ifFalse: [nil]
    ]

    skipSpaces [
        [pos <= input size and: [(input at: pos) isSeparator]]
            whileTrue: [pos := pos + 1]
    ]

    advance [
        pos := pos + 1
    ]

    expect: aChar [
        self peek = aChar ifFalse: [self parseError].
        self advance
    ]

    parseExpr [
        | node op |
        node := self parseTerm.
        [(op := self peek) notNil and: [op = $+ or: [op = $-]]]
            whileTrue: [
                self advance.
                node := self binaryNode: op asString left: node right: self parseTerm].
        ^node
    ]

    parseTerm [
        | node op |
        node := self parseUnary.
        [(op := self peek) notNil and: [op = $* or: [op = $/ or: [op = $%]]]]
            whileTrue: [
                self advance.
                node := self binaryNode: op asString left: node right: self parseUnary].
        ^node
    ]

    parseUnary [
        | op |
        op := self peek.
        (op notNil and: [op = $+ or: [op = $-]]) ifTrue: [
            self advance.
            ^self unaryNode: op asString operand: self parseUnary].
        ^self parsePower
    ]

    parsePower [
        | base |
        base := self parsePrimary.
        self peek = $^ ifTrue: [
            self advance.
            ^self binaryNode: '^' left: base right: self parseUnary].
        ^base
    ]

    parsePrimary [
        | c node |
        c := self peek.
        c isNil ifTrue: [^self parseError].
        c isDigit ifTrue: [^self parseNumber].
        (self isIdentStart: c) ifTrue: [^self parseIdentifier].
        c = $( ifTrue: [
            self advance.
            node := self parseExpr.
            self expect: $).
            ^node].
        ^self parseError
    ]

    parseNumber [
        | start text |
        start := pos.
        [pos <= input size and: [(input at: pos) isDigit]]
            whileTrue: [pos := pos + 1].
        (pos <= input size and: [(input at: pos) = $.]) ifTrue: [
            pos := pos + 1.
            (pos <= input size and: [(input at: pos) isDigit])
                ifFalse: [self parseError].
            [pos <= input size and: [(input at: pos) isDigit]]
                whileTrue: [pos := pos + 1]].
        text := input copyFrom: start to: pos - 1.
        ^AstNode new initKind: #num; numValue: text asNumber asFloat; yourself
    ]

    parseIdentifier [
        | start name |
        start := pos.
        [pos <= input size and: [self isIdentChar: (input at: pos)]]
            whileTrue: [pos := pos + 1].
        name := input copyFrom: start to: pos - 1.
        self peek = $( ifTrue: [^self parseCall: name].
        ^AstNode new initKind: #var; strValue: name; yourself
    ]

    parseCall: name [
        | arity args |
        arity := self arityOf: name.
        arity isNil ifTrue: [^self parseError].
        self advance.
        args := OrderedCollection new.
        args add: self parseExpr.
        [self peek = $,] whileTrue: [
            self advance.
            args add: self parseExpr].
        self expect: $).
        args size = arity ifFalse: [^self parseError].
        ^self callNode: name args: args
    ]

    arityOf: name [
        | table |
        table := Dictionary new.
        table at: 'sqrt' put: 1;
              at: 'abs' put: 1;
              at: 'sin' put: 1;
              at: 'cos' put: 1;
              at: 'min' put: 2;
              at: 'max' put: 2;
              at: 'pow' put: 2.
        ^table at: name ifAbsent: [nil]
    ]

    isIdentStart: c [
        ^(c between: $a and: $z) or: [(c between: $A and: $Z) or: [c = $_]]
    ]

    isIdentChar: c [
        ^(self isIdentStart: c) or: [c between: $0 and: $9]
    ]

    binaryNode: op left: l right: r [
        | n |
        n := AstNode new initKind: #binOp.
        n strValue: op.
        n addChild: l.
        n addChild: r.
        ^n
    ]

    unaryNode: op operand: x [
        | n |
        n := AstNode new initKind: #unOp.
        n strValue: op.
        n addChild: x.
        ^n
    ]

    callNode: name args: list [
        | n |
        n := AstNode new initKind: #call.
        n strValue: name.
        n children: list.
        ^n
    ]

    "----------------------------------------------------------------"
    "Evaluation"
    "----------------------------------------------------------------"

    okResult: v [
        ^EvalResult status: #ok value: v
    ]

    errorResult: s [
        ^EvalResult status: s value: 0.0
    ]

    evalNode: node vars: vars [
        | kind r |
        kind := node kind.
        kind = #num ifTrue: [^self okResult: node numValue].
        kind = #var ifTrue: [^self lookup: node strValue in: vars].
        kind = #unOp ifTrue: [
            r := self evalNode: node children first vars: vars.
            r status = #ok ifFalse: [^r].
            node strValue = '-' ifTrue: [^self okResult: r value negated].
            ^r].
        kind = #binOp ifTrue: [^self evalBinary: node vars: vars].
        kind = #call ifTrue: [^self evalCall: node vars: vars].
        ^self errorResult: #invalidOp
    ]

    lookup: name in: vars [
        | binding |
        binding := vars detect: [:b | b name = name] ifNone: [nil].
        binding isNil ifTrue: [^self errorResult: #undefinedVar].
        ^self okResult: binding value asFloat
    ]

    evalBinary: node vars: vars [
        | l r |
        l := self evalNode: node children first vars: vars.
        l status = #ok ifFalse: [^l].
        r := self evalNode: node children last vars: vars.
        r status = #ok ifFalse: [^r].
        ^self applyBinary: node strValue to: l value and: r value
    ]

    applyBinary: op to: a and: b [
        op = '+' ifTrue: [^self okResult: a asFloat + b asFloat].
        op = '-' ifTrue: [^self okResult: a asFloat - b asFloat].
        op = '*' ifTrue: [^self okResult: a asFloat * b asFloat].
        op = '/' ifTrue: [
            b = 0 ifTrue: [^self errorResult: #divByZero].
            ^self okResult: a asFloat / b asFloat].
        op = '%' ifTrue: [
            b = 0 ifTrue: [^self errorResult: #divByZero].
            ^self okResult: (a asFloat rem: b asFloat)].
        op = '^' ifTrue: [^self powerOf: a to: b].
        ^self errorResult: #invalidOp
    ]

    evalCall: node vars: vars [
        | name r1 r2 x y |
        name := node strValue.
        r1 := self evalNode: node children first vars: vars.
        r1 status = #ok ifFalse: [^r1].
        x := r1 value asFloat.
        node children size = 2 ifTrue: [
            r2 := self evalNode: node children last vars: vars.
            r2 status = #ok ifFalse: [^r2].
            y := r2 value asFloat].
        name = 'sqrt' ifTrue: [
            x < 0.0 ifTrue: [^self errorResult: #domainError].
            ^self okResult: x sqrt].
        name = 'abs' ifTrue: [^self okResult: x abs].
        name = 'sin' ifTrue: [^self okResult: x sin].
        name = 'cos' ifTrue: [^self okResult: x cos].
        name = 'min' ifTrue: [^self okResult: (x min: y)].
        name = 'max' ifTrue: [^self okResult: (x max: y)].
        name = 'pow' ifTrue: [^self powerOf: x to: y].
        ^self errorResult: #invalidOp
    ]

    powerOf: a to: b [
        | x y m r |
        x := a asFloat.
        y := b asFloat.
        (x = 0.0 and: [y < 0.0]) ifTrue: [^self errorResult: #domainError].
        (x < 0.0 and: [y truncated asFloat ~= y]) ifTrue: [^self errorResult: #domainError].
        x < 0.0
            ifTrue: [
                m := x negated raisedTo: y.
                r := (y truncated odd) ifTrue: [m negated] ifFalse: [m]]
            ifFalse: [r := x raisedTo: y].
        r := r asFloat.
        (r isNaN or: [r isInfinite]) ifTrue: [^self errorResult: #domainError].
        ^self okResult: r
    ]
]
