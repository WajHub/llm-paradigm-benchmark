Object subclass: Sudoku [
    isValid: grid [
        ^self subclassResponsibility
    ]

    candidates: grid row: r col: c [
        ^self subclassResponsibility
    ]

    solve: grid [
        ^self subclassResponsibility
    ]

    countSolutions: grid limit: n [
        ^self subclassResponsibility
    ]
]
