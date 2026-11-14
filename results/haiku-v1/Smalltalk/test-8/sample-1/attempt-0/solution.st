TspApprox subclass: TspApproxImpl [

    dist: p to: q [
        ^((p at: 1) - (q at: 1)) abs + ((p at: 2) - (q at: 2)) abs
    ]

    tourCost: tour points: points [
        | n |
        n := tour size.
        n = 0 ifTrue: [^0].
        ^(1 to: n) inject: 0 into: [:acc :i |
            acc + (self dist: (points at: (tour at: i))
                          to: (points at: (tour at: i \\ n + 1)))]
    ]

    mstParentsOf: points [
        | n parent key inTree bestV parentU d |
        n := points size.
        parent := Array new: n withAll: 0.
        n < 2 ifTrue: [^parent].
        key := Array new: n withAll: 0.
        inTree := Array new: n withAll: false.
        inTree at: 1 put: true.
        2 to: n do: [:v |
            key at: v put: (self dist: (points at: 1) to: (points at: v))].
        1 to: n - 1 do: [:step |
            bestV := nil.
            2 to: n do: [:v |
                ((inTree at: v) not and: [bestV isNil or: [(key at: v) < (key at: bestV)]])
                    ifTrue: [bestV := v]].
            parentU := nil.
            1 to: n do: [:u |
                (parentU isNil and: [(inTree at: u)
                    and: [(self dist: (points at: u) to: (points at: bestV)) = (key at: bestV)]])
                        ifTrue: [parentU := u]].
            parent at: bestV put: parentU.
            inTree at: bestV put: true.
            2 to: n do: [:w |
                (inTree at: w) not ifTrue: [
                    d := self dist: (points at: bestV) to: (points at: w).
                    d < (key at: w) ifTrue: [key at: w put: d]]]].
        ^parent
    ]

    mstWeight: points [
        | n parent |
        n := points size.
        parent := self mstParentsOf: points.
        ^(2 to: n) inject: 0 into: [:acc :v |
            acc + (self dist: (points at: v) to: (points at: (parent at: v)))]
    ]

    preorderFrom: u children: ch into: oc [
        oc add: u.
        (ch at: u) do: [:c | self preorderFrom: c children: ch into: oc]
    ]

    doubleTree: points [
        | n parent ch oc tour |
        n := points size.
        n = 0 ifTrue: [^nil].
        parent := self mstParentsOf: points.
        ch := (1 to: n) collect: [:x | OrderedCollection new].
        2 to: n do: [:x | (ch at: (parent at: x)) add: x].
        oc := OrderedCollection new.
        self preorderFrom: 1 children: ch into: oc.
        tour := oc asArray.
        ^TspTourResult tour: tour cost: (self tourCost: tour points: points)
    ]

    oddVerticesOf: parent [
        | n deg |
        n := parent size.
        deg := Array new: n withAll: 0.
        2 to: n do: [:v |
            deg at: v put: (deg at: v) + 1.
            deg at: (parent at: v) put: (deg at: (parent at: v)) + 1].
        ^((1 to: n) select: [:v | (deg at: v) \\ 2 = 1]) asArray
    ]

    lowestBitIndexOf: mask [
        | i |
        i := 0.
        [(mask bitAnd: (1 bitShift: i)) = 0] whileTrue: [i := i + 1].
        ^i
    ]

    removeBits: i and: j from: mask [
        ^mask bitAnd: (((1 bitShift: i) bitOr: (1 bitShift: j)) bitInvert)
    ]

    matchCost: mask pts: pts memo: memo [
        | m i best cand rest |
        mask = 0 ifTrue: [^0].
        (memo includesKey: mask) ifTrue: [^memo at: mask].
        m := pts size.
        i := self lowestBitIndexOf: mask.
        best := nil.
        i + 1 to: m - 1 do: [:j |
            (mask bitAnd: (1 bitShift: j)) = 0 ifFalse: [
                rest := self removeBits: i and: j from: mask.
                cand := (self dist: (pts at: i + 1) to: (pts at: j + 1))
                    + (self matchCost: rest pts: pts memo: memo).
                (best isNil or: [cand < best]) ifTrue: [best := cand]]].
        memo at: mask put: best.
        ^best
    ]

    minimumMatchingOf: oddVerts points: points [
        | pts memo pairs mask i bestJ best cand rest m |
        m := oddVerts size.
        pts := oddVerts collect: [:v | points at: v].
        memo := Dictionary new.
        pairs := OrderedCollection new.
        mask := (1 bitShift: m) - 1.
        [mask = 0] whileFalse: [
            i := self lowestBitIndexOf: mask.
            bestJ := nil.
            best := nil.
            i + 1 to: m - 1 do: [:j |
                (mask bitAnd: (1 bitShift: j)) = 0 ifFalse: [
                    rest := self removeBits: i and: j from: mask.
                    cand := (self dist: (pts at: i + 1) to: (pts at: j + 1))
                        + (self matchCost: rest pts: pts memo: memo).
                    (bestJ isNil or: [cand < best]) ifTrue: [
                        best := cand.
                        bestJ := j]]].
            pairs add: (Array with: (oddVerts at: i + 1) with: (oddVerts at: bestJ + 1)).
            mask := self removeBits: i and: bestJ from: mask].
        ^pairs
    ]

    matchingWeight: points [
        | parent odd pairs |
        points size < 2 ifTrue: [^0].
        parent := self mstParentsOf: points.
        odd := self oddVerticesOf: parent.
        pairs := self minimumMatchingOf: odd points: points.
        ^pairs inject: 0 into: [:acc :p |
            acc + (self dist: (points at: (p at: 1)) to: (points at: (p at: 2)))]
    ]

    christofides: points [
        | n parent odd pairs edges adj used ptr stack circuit v w k e seen tour tourArr |
        n := points size.
        n = 0 ifTrue: [^nil].
        n = 1 ifTrue: [^TspTourResult tour: #(1) cost: 0].
        parent := self mstParentsOf: points.
        odd := self oddVerticesOf: parent.
        pairs := self minimumMatchingOf: odd points: points.
        edges := OrderedCollection new.
        2 to: n do: [:x | edges add: (Array with: x with: (parent at: x))].
        edges addAll: pairs.
        adj := (1 to: n) collect: [:x | OrderedCollection new].
        edges keysAndValuesDo: [:idx :edge |
            (adj at: (edge at: 1)) add: idx.
            (adj at: (edge at: 2)) add: idx].
        used := Array new: edges size withAll: false.
        ptr := Array new: n withAll: 1.
        stack := OrderedCollection with: 1.
        circuit := OrderedCollection new.
        [stack isEmpty] whileFalse: [
            v := stack last.
            [(ptr at: v) <= (adj at: v) size
                and: [used at: ((adj at: v) at: (ptr at: v))]]
                    whileTrue: [ptr at: v put: (ptr at: v) + 1].
            (ptr at: v) > (adj at: v) size
                ifTrue: [circuit add: stack removeLast]
                ifFalse: [
                    k := (adj at: v) at: (ptr at: v).
                    used at: k put: true.
                    e := edges at: k.
                    w := (e at: 1) = v ifTrue: [e at: 2] ifFalse: [e at: 1].
                    stack addLast: w]].
        seen := Array new: n withAll: false.
        tour := OrderedCollection new.
        circuit do: [:x |
            (seen at: x) ifFalse: [
                seen at: x put: true.
                tour add: x]].
        tourArr := tour asArray.
        ^TspTourResult tour: tourArr cost: (self tourCost: tourArr points: points)
    ]
]
