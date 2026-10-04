Object subclass: AstNode [
    | kind numValue strValue children |

    AstNode class >> kind: k [
        ^self new initKind: k
    ]

    initKind: k [
        kind := k.
        numValue := 0.0.
        strValue := ''.
        children := OrderedCollection new.
        ^self
    ]

    kind [ ^kind ]
    kind: k [ kind := k ]
    numValue [ ^numValue ]
    numValue: v [ numValue := v ]
    strValue [ ^strValue ]
    strValue: s [ strValue := s ]
    children [ ^children ]
    children: c [ children := c ]
    addChild: c [ children add: c ]
]

Object subclass: ExprVariable [
    | name value |

    ExprVariable class >> name: n value: v [
        ^self new initName: n value: v
    ]

    initName: n value: v [
        name := n.
        value := v.
        ^self
    ]

    name [ ^name ]
    value [ ^value ]
]

Object subclass: EvalResult [
    | status value |

    EvalResult class >> status: s value: v [
        ^self new initStatus: s value: v
    ]

    initStatus: s value: v [
        status := s.
        value := v.
        ^self
    ]

    status [ ^status ]
    value [ ^value ]
]

Object subclass: Expression [
    parseExpression: aString [
        ^self subclassResponsibility
    ]

    evaluate: ast vars: aCollection [
        ^self subclassResponsibility
    ]
]
