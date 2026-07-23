Object subclass: KnapsackResult [
    | maxValue selected totalWeight |

    KnapsackResult class >> maxValue: mv selected: s totalWeight: tw [
        ^self new initMaxValue: mv selected: s totalWeight: tw
    ]

    initMaxValue: mv selected: s totalWeight: tw [
        maxValue := mv.
        selected := s.
        totalWeight := tw.
        ^self
    ]

    maxValue [ ^maxValue ]
    selected [ ^selected ]
    totalWeight [ ^totalWeight ]
]

Object subclass: Knapsack [
    maxValueOf: weights values: values capacity: capacity [
        ^self subclassResponsibility
    ]

    solveWeights: weights values: values capacity: capacity [
        ^self subclassResponsibility
    ]
]
