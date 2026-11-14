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

OrderStats subclass: OrderStatsImpl [

    lowerMedianOf: arr [
        | sorted |
        sorted := arr asSortedCollection asArray.
        ^sorted at: ((sorted size - 1) // 2) + 1
    ]

    medianOfMedians: xs [
        | groupMedians |
        xs isEmpty ifTrue: [^nil].
        groupMedians := OrderedCollection new.
        1 to: xs size by: 5 do: [:start |
            | end group |
            end := (start + 4) min: xs size.
            group := (xs copyFrom: start to: end) asSortedCollection asArray.
            groupMedians add: (group at: ((group size - 1) // 2) + 1)].
        ^self lowerMedianOf: groupMedians asArray
    ]

    selectKth: k from: xs [
        | cur rank pivots p lessPart equalCount greaterPart |
        (k < 1 or: [k > xs size]) ifTrue: [^nil].
        cur := xs.
        rank := k.
        pivots := OrderedCollection new.
        [cur size <= 5 ifTrue: [
            ^SelectResult
                value: (cur asSortedCollection asArray at: rank)
                pivots: pivots asArray].
         p := self medianOfMedians: cur.
         pivots add: p.
         lessPart := (cur select: [:e | e < p]) asArray.
         equalCount := (cur select: [:e | e = p]) size.
         greaterPart := (cur select: [:e | e > p]) asArray.
         rank <= lessPart size
            ifTrue: [cur := lessPart]
            ifFalse: [
                rank <= (lessPart size + equalCount)
                    ifTrue: [^SelectResult value: p pivots: pivots asArray].
                rank := rank - lessPart size - equalCount.
                cur := greaterPart]
        ] repeat
    ]

    kthOf: k in: a and: b [
        | m n offA offB kk |
        m := a size.
        n := b size.
        offA := 0.
        offB := 0.
        kk := k.
        [| remA remB ia ib |
         remA := m - offA.
         remB := n - offB.
         remA = 0 ifTrue: [^b at: offB + kk].
         remB = 0 ifTrue: [^a at: offA + kk].
         kk = 1 ifTrue: [^(a at: offA + 1) min: (b at: offB + 1)].
         ia := (kk // 2) min: remA.
         ib := (kk // 2) min: remB.
         (a at: offA + ia) <= (b at: offB + ib)
            ifTrue: [
                offA := offA + ia.
                kk := kk - ia]
            ifFalse: [
                offB := offB + ib.
                kk := kk - ib]
        ] repeat
    ]

    medianOf: a and: b [
        | total lo hi |
        total := a size + b size.
        total = 0 ifTrue: [^nil].
        (total \\ 2) = 1
            ifTrue: [^(self kthOf: (total + 1) // 2 in: a and: b) asFloat].
        lo := self kthOf: total // 2 in: a and: b.
        hi := self kthOf: (total // 2) + 1 in: a and: b.
        ^(lo + hi) asFloat / 2.0
    ]
]
