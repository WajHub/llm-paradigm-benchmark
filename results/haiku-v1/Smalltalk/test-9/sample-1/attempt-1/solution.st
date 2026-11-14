The failure is in the deletion path. Every test that removes a key fails, while insertion and the absent-key test pass. The likely cause is `OrderedCollection>>removeIndex:`, which may not exist in this gst image, so the code raises `doesNotUnderstand` as soon as it removes an element. I've replaced those calls with a helper that removes an element by value, using only `at:` and `remove:`. I also dropped the redundant `Object subclass: BTree [ ]` stub, since BTree.st already defines that class.

BTreeImpl.st:

BTree subclass: BTreeImpl [

    insertAll: keys degree: t [
        | root |
        t < 2 ifTrue: [^nil].
        root := BTreeNode keys: OrderedCollection new children: OrderedCollection new.
        keys do: [:k | root := self insertKey: k into: root degree: t].
        ^root
    ]

    deleteAll: deletions from: keys degree: t [
        | root |
        t < 2 ifTrue: [^nil].
        root := self insertAll: keys degree: t.
        deletions do: [:k |
            (self containsKey: k in: root) ifTrue: [
                self deleteKey: k from: root degree: t.
                [root keys isEmpty and: [root isLeaf not]]
                    whileTrue: [root := root children first]]].
        ^root
    ]

    "Helpers"

    dropAt: i from: aCollection [
        "Remove the element at index i by value (elements are distinct keys or nodes)."
        ^aCollection remove: (aCollection at: i)
    ]

    lowerBoundOf: k in: keyList [
        "Answer the first index whose key is not less than k (size + 1 if none)."
        | i |
        i := 1.
        [i <= keyList size and: [(keyList at: i) < k]] whileTrue: [i := i + 1].
        ^i
    ]

    containsKey: k in: node [
        | n i |
        n := node.
        [
            i := self lowerBoundOf: k in: n keys.
            (i <= n keys size and: [(n keys at: i) = k]) ifTrue: [^true].
            n isLeaf ifTrue: [^false].
            n := n children at: i
        ] repeat
    ]

    maxKeyIn: node [
        | n |
        n := node.
        [n isLeaf] whileFalse: [n := n children last].
        ^n keys last
    ]

    minKeyIn: node [
        | n |
        n := node.
        [n isLeaf] whileFalse: [n := n children first].
        ^n keys first
    ]

    splitChild: i of: x degree: t [
        | y z median |
        y := x children at: i.
        median := y keys at: t.
        z := BTreeNode
            keys: (y keys copyFrom: t + 1 to: 2 * t - 1) asOrderedCollection
            children: (y isLeaf
                ifTrue: [OrderedCollection new]
                ifFalse: [(y children copyFrom: t + 1 to: 2 * t) asOrderedCollection]).
        y keys: (y keys copyFrom: 1 to: t - 1) asOrderedCollection.
        y isLeaf ifFalse: [
            y children: (y children copyFrom: 1 to: t) asOrderedCollection].
        x keys add: median beforeIndex: i.
        x children add: z beforeIndex: i + 1.
        ^self
    ]

    insertKey: k into: root degree: t [
        | r s |
        (self containsKey: k in: root) ifTrue: [^root].
        root keys size = (2 * t - 1)
            ifTrue: [
                s := BTreeNode
                    keys: OrderedCollection new
                    children: (OrderedCollection with: root).
                self splitChild: 1 of: s degree: t.
                r := s]
            ifFalse: [r := root].
        self insertNonFull: k into: r degree: t.
        ^r
    ]

    insertNonFull: k into: x degree: t [
        | node i child pos |
        node := x.
        [node isLeaf] whileFalse: [
            i := self lowerBoundOf: k in: node keys.
            child := node children at: i.
            child keys size = (2 * t - 1) ifTrue: [
                self splitChild: i of: node degree: t.
                k > (node keys at: i) ifTrue: [i := i + 1].
                child := node children at: i].
            node := child].
        pos := self lowerBoundOf: k in: node keys.
        node keys add: k beforeIndex: pos.
        ^self
    ]

    mergeChildren: idx of: x [
        "Merge child idx, separator key idx and child idx+1 into child idx."
        | y z |
        y := x children at: idx.
        z := x children at: idx + 1.
        y keys addLast: (x keys at: idx).
        y keys addAll: z keys.
        y children addAll: z children.
        self dropAt: idx from: x keys.
        self dropAt: idx + 1 from: x children.
        ^y
    ]

    fixChildAt: i of: x degree: t [
        "Ensure child i has at least t keys; answer the index of the child covering the range."
        | c left right |
        c := x children at: i.
        c keys size < t ifFalse: [^i].
        (i > 1 and: [(x children at: i - 1) keys size >= t]) ifTrue: [
            left := x children at: i - 1.
            c keys addFirst: (x keys at: i - 1).
            x keys at: i - 1 put: left keys removeLast.
            left isLeaf ifFalse: [c children addFirst: left children removeLast].
            ^i].
        (i < x children size and: [(x children at: i + 1) keys size >= t]) ifTrue: [
            right := x children at: i + 1.
            c keys addLast: (x keys at: i).
            x keys at: i put: right keys removeFirst.
            right isLeaf ifFalse: [c children addLast: right children removeFirst].
            ^i].
        i < x children size ifTrue: [
            self mergeChildren: i of: x.
            ^i].
        self mergeChildren: i - 1 of: x.
        ^i - 1
    ]

    deleteKey: k from: x degree: t [
        | i y z pred succ child |
        i := self lowerBoundOf: k in: x keys.
        (i <= x keys size and: [(x keys at: i) = k]) ifTrue: [
            x isLeaf ifTrue: [
                self dropAt: i from: x keys.
                ^self].
            y := x children at: i.
            z := x children at: i + 1.
            y keys size >= t ifTrue: [
                pred := self maxKeyIn: y.
                self deleteKey: pred from: y degree: t.
                x keys at: i put: pred.
                ^self].
            z keys size >= t ifTrue: [
                succ := self minKeyIn: z.
                self deleteKey: succ from: z degree: t.
                x keys at: i put: succ.
                ^self].
            self mergeChildren: i of: x.
            self deleteKey: k from: y degree: t.
            ^self].
        i := self fixChildAt: i of: x degree: t.
        child := x children at: i.
        self deleteKey: k from: child degree: t.
        ^self
    ]
]
