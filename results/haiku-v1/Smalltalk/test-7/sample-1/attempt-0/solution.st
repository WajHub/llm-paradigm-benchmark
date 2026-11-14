SequenceAlignment subclass: SequenceAlignmentImpl [
    <comment: 'Global sequence alignment with affine gap penalties (Gotoh algorithm).'>

    negInfinity [
        "Sentinel for unreachable DP states; large enough never to win a comparison."
        ^(10 raisedTo: 40) negated
    ]

    newTableRows: r cols: c [
        | t |
        t := Array new: r.
        1 to: r do: [:i | t at: i put: (Array new: c withAll: self negInfinity)].
        ^t
    ]

    cellOf: t i: i j: j [
        ^(t at: i + 1) at: j + 1
    ]

    cellOf: t i: i j: j put: v [
        ^(t at: i + 1) at: j + 1 put: v
    ]

    fillTablesFor: aStr with: bStr match: ms mismatch: mp gapOpen: go gapExtend: ge [
        "Returns an Array holding the M, X and Y tables.
         M: last column is a(i)/b(j).
         X: last column is a(i)/-.
         Y: last column is -/b(j)."
        | n m mt xt yt open |
        n := aStr size.
        m := bStr size.
        open := go + ge.
        mt := self newTableRows: n + 1 cols: m + 1.
        xt := self newTableRows: n + 1 cols: m + 1.
        yt := self newTableRows: n + 1 cols: m + 1.
        self cellOf: mt i: 0 j: 0 put: 0.
        0 to: n do: [:i |
            0 to: m do: [:j |
                (i > 0 and: [j > 0]) ifTrue: [
                    | prev sub |
                    prev := ((self cellOf: mt i: i - 1 j: j - 1)
                                max: (self cellOf: xt i: i - 1 j: j - 1))
                                max: (self cellOf: yt i: i - 1 j: j - 1).
                    sub := (aStr at: i) = (bStr at: j) ifTrue: [ms] ifFalse: [mp negated].
                    self cellOf: mt i: i j: j put: prev + sub].
                i > 0 ifTrue: [
                    | fromM fromX fromY |
                    fromM := (self cellOf: mt i: i - 1 j: j) - open.
                    fromX := (self cellOf: xt i: i - 1 j: j) - ge.
                    fromY := (self cellOf: yt i: i - 1 j: j) - open.
                    self cellOf: xt i: i j: j put: ((fromM max: fromX) max: fromY)].
                j > 0 ifTrue: [
                    | fromM fromX fromY |
                    fromM := (self cellOf: mt i: i j: j - 1) - open.
                    fromX := (self cellOf: xt i: i j: j - 1) - open.
                    fromY := (self cellOf: yt i: i j: j - 1) - ge.
                    self cellOf: yt i: i j: j put: ((fromM max: fromY) max: fromX)]]].
        ^Array with: mt with: xt with: yt
    ]

    scoreOf: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        | tables mt xt yt n m |
        tables := self
            fillTablesFor: a
            with: b
            match: matchScore
            mismatch: mismatchPenalty
            gapOpen: gapOpen
            gapExtend: gapExtend.
        mt := tables at: 1.
        xt := tables at: 2.
        yt := tables at: 3.
        n := a size.
        m := b size.
        ^((self cellOf: mt i: n j: m)
            max: (self cellOf: xt i: n j: m))
            max: (self cellOf: yt i: n j: m)
    ]

    align: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen gapExtend: gapExtend [
        | tables mt xt yt n m open best state ra rb i j |
        tables := self
            fillTablesFor: a
            with: b
            match: matchScore
            mismatch: mismatchPenalty
            gapOpen: gapOpen
            gapExtend: gapExtend.
        mt := tables at: 1.
        xt := tables at: 2.
        yt := tables at: 3.
        n := a size.
        m := b size.
        open := gapOpen + gapExtend.

        best := self cellOf: mt i: n j: m.
        state := #M.
        (self cellOf: xt i: n j: m) > best ifTrue: [
            best := self cellOf: xt i: n j: m.
            state := #X].
        (self cellOf: yt i: n j: m) > best ifTrue: [
            best := self cellOf: yt i: n j: m.
            state := #Y].

        ra := OrderedCollection new.
        rb := OrderedCollection new.
        i := n.
        j := m.
        [i > 0 or: [j > 0]] whileTrue: [
            state == #M
                ifTrue: [
                    | target sub |
                    target := self cellOf: mt i: i j: j.
                    sub := (a at: i) = (b at: j) ifTrue: [matchScore] ifFalse: [mismatchPenalty negated].
                    target := target - sub.
                    ((self cellOf: mt i: i - 1 j: j - 1) = target)
                        ifTrue: [state := #M]
                        ifFalse: [
                            ((self cellOf: xt i: i - 1 j: j - 1) = target)
                                ifTrue: [state := #X]
                                ifFalse: [state := #Y]].
                    ra addFirst: (a at: i).
                    rb addFirst: (b at: j).
                    i := i - 1.
                    j := j - 1]
                ifFalse: [
                    state == #X
                        ifTrue: [
                            | target |
                            target := self cellOf: xt i: i j: j.
                            ((self cellOf: mt i: i - 1 j: j) - open = target)
                                ifTrue: [state := #M]
                                ifFalse: [
                                    ((self cellOf: xt i: i - 1 j: j) - gapExtend = target)
                                        ifTrue: [state := #X]
                                        ifFalse: [state := #Y]].
                            ra addFirst: (a at: i).
                            rb addFirst: $-.
                            i := i - 1]
                        ifFalse: [
                            | target |
                            target := self cellOf: yt i: i j: j.
                            ((self cellOf: mt i: i j: j - 1) - open = target)
                                ifTrue: [state := #M]
                                ifFalse: [
                                    ((self cellOf: yt i: i j: j - 1) - gapExtend = target)
                                        ifTrue: [state := #Y]
                                        ifFalse: [state := #X]].
                            ra addFirst: $-.
                            rb addFirst: (b at: j).
                            j := j - 1]]].

        ^AlignmentResult
            score: best
            alignedA: (String withAll: ra)
            alignedB: (String withAll: rb)
    ]
]
