Sudoku subclass: SudokuImpl [
    peerIndicesOf: idx [
        "Answer the indices of the 20 cells sharing a row, column or box with idx."
        | r c set br bc |
        r := (idx - 1) // 9 + 1.
        c := (idx - 1) \\ 9 + 1.
        set := Set new.
        1 to: 9 do: [:k |
            set add: (r - 1) * 9 + k.
            set add: (k - 1) * 9 + c].
        br := (r - 1) // 3 * 3 + 1.
        bc := (c - 1) // 3 * 3 + 1.
        0 to: 2 do: [:dr |
            0 to: 2 do: [:dc |
                set add: (br + dr - 1) * 9 + bc + dc]].
        set remove: idx ifAbsent: [].
        ^set asArray
    ]

    candidatesFor: idx board: board peers: peerList [
        "Digits 1..9 not used by any peer of the (empty) cell idx, ascending."
        | used v |
        used := Array new: 9 withAll: false.
        peerList do: [:p |
            v := board at: p.
            (v between: 1 and: 9) ifTrue: [used at: v put: true]].
        ^(1 to: 9) reject: [:d | used at: d]
    ]

    searchOn: board peers: peers stop: aBlock [
        "Depth-first MRV search. Answers true when aBlock answers true at a complete board."
        | best bestCands cands |
        best := nil.
        1 to: 81 do: [:i |
            (board at: i) = 0 ifTrue: [
                cands := self candidatesFor: i board: board peers: (peers at: i).
                cands isEmpty ifTrue: [^false].
                (best isNil or: [cands size < bestCands size]) ifTrue: [
                    best := i.
                    bestCands := cands]]].
        best isNil ifTrue: [^aBlock value].
        bestCands do: [:d |
            board at: best put: d.
            (self searchOn: board peers: peers stop: aBlock) ifTrue: [^true]].
        board at: best put: 0.
        ^false
    ]

    isValid: grid [
        | v |
        grid size = 81 ifFalse: [^false].
        grid do: [:x |
            ((x isInteger) and: [x between: 0 and: 9]) ifFalse: [^false]].
        1 to: 81 do: [:i |
            v := grid at: i.
            v > 0 ifTrue: [
                (self peerIndicesOf: i) do: [:p |
                    (grid at: p) = v ifTrue: [^false]]]].
        ^true
    ]

    candidates: grid row: r col: c [
        | idx |
        idx := (r - 1) * 9 + c.
        (grid at: idx) = 0 ifFalse: [^#()].
        ^self candidatesFor: idx board: grid peers: (self peerIndicesOf: idx)
    ]

    solve: grid [
        | board peers |
        (self isValid: grid) ifFalse: [^nil].
        board := Array new: 81.
        1 to: 81 do: [:i | board at: i put: (grid at: i)].
        peers := (1 to: 81) collect: [:i | self peerIndicesOf: i].
        (self searchOn: board peers: peers stop: [true]) ifTrue: [^board].
        ^nil
    ]

    countSolutions: grid limit: n [
        | board peers count |
        n <= 0 ifTrue: [^0].
        (self isValid: grid) ifFalse: [^0].
        board := Array new: 81.
        1 to: 81 do: [:i | board at: i put: (grid at: i)].
        peers := (1 to: 81) collect: [:i | self peerIndicesOf: i].
        count := 0.
        self searchOn: board peers: peers stop: [
            count := count + 1.
            count >= n].
        ^count
    ]
]
