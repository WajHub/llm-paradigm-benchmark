Object subclass: SelectResult [
    | value pivots |

    SelectResult class >> value: v pivots: p [
        ^self new initValue: v pivots: p
    ]

    initValue: v pivots: p [
        value := v.
        pivots := p.
        ^self
    ]

    value [ ^value ]
    pivots [ ^pivots ]
]

Object subclass: OrderStats [
    medianOfMedians: xs [
        ^self subclassResponsibility
    ]

    selectKth: k from: xs [
        ^self subclassResponsibility
    ]

    medianOf: a and: b [
        ^self subclassResponsibility
    ]
]
