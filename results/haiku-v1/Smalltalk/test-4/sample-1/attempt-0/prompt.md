You are a GNU Smalltalk programming expert. Your task is to implement the required methods in accordance with the provided class hierarchy.

- Implement `maxValueOf: weights values: values capacity: capacity`: Return max attainable value via DP. Return 0 if empty or capacity <= 0.
- Implement `solveWeights: weights values: values capacity: capacity`: Return KnapsackResult with maxValue, selected (Array/OrderedCollection of 0/1 length n), totalWeight.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum(selected_i * weights_i) <= capacity; sum(selected_i * values_i) = maxValue.
- Put the solution in KnapsackImpl.st. Idiomatic GNU Smalltalk.

General Requirements:
- Use idiomatic GNU Smalltalk (gst) syntax.
- Use object-oriented design and model the domain with classes and message passing.
- Do not redefine built-in classes (e.g. Point, Set, Interval); use them as provided.
- Prefer standard Smalltalk collections and idioms where appropriate.
- Return ONLY raw Smalltalk code (no Markdown tags, no ```smalltalk blocks, no side text). Your code will be directly saved to a .st file and loaded by gst. Do not provide test code.

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