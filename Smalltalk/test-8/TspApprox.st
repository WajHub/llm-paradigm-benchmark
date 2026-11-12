Object subclass: TspTourResult [
    | tour cost |

    TspTourResult class >> tour: aTour cost: aCost [
        ^self new initTour: aTour cost: aCost
    ]

    initTour: aTour cost: aCost [
        tour := aTour.
        cost := aCost.
        ^self
    ]

    tour [ ^tour ]
    cost [ ^cost ]
]

Object subclass: TspApprox [
    mstWeight: points [
        ^self subclassResponsibility
    ]

    doubleTree: points [
        ^self subclassResponsibility
    ]

    matchingWeight: points [
        ^self subclassResponsibility
    ]

    christofides: points [
        ^self subclassResponsibility
    ]
]
