PalindromeTree subclass: PalindromeTreeImpl [

    "Create a node with the given len, suffix link and end position."
    newNodeLen: l link: link endPos: e [
        ^EertreeNode new
            len: l;
            suffixLink: link;
            children: Dictionary new;
            cnt: 0;
            endPos: e;
            yourself
    ]

    "Build the palindrome tree (Eertree) for aString of length len.
     Return an Eertree, or nil if aString is nil and len > 0."
    eertreeBuild: aString length: len [
        | nodes oddRoot evenRoot last size s tree sorted |
        (len isNil or: [len < 0]) ifTrue: [^nil].
        (aString isNil and: [len > 0]) ifTrue: [^nil].
        s := aString.
        nodes := Array new: len + 2.
        oddRoot := self newNodeLen: -1 link: nil endPos: nil.
        oddRoot suffixLink: oddRoot.
        evenRoot := self newNodeLen: 0 link: oddRoot endPos: nil.
        nodes at: 1 put: oddRoot.
        nodes at: 2 put: evenRoot.
        size := 2.
        last := evenRoot.

        0 to: len - 1 do: [:p |
            | c cur node k w link |
            c := s at: p + 1.
            cur := last.
            [k := p - cur len - 1.
             k >= 0 and: [(s at: k + 1) = c]] whileFalse: [cur := cur suffixLink].

            (cur children includesKey: c)
                ifTrue: [
                    last := cur children at: c.
                    last cnt: last cnt + 1]
                ifFalse: [
                    node := self newNodeLen: cur len + 2 link: nil endPos: p.
                    node cnt: 1.
                    cur len + 2 = 1
                        ifTrue: [link := evenRoot]
                        ifFalse: [
                            w := cur suffixLink.
                            [k := p - w len - 1.
                             k >= 0 and: [(s at: k + 1) = c]] whileFalse: [w := w suffixLink].
                            link := w children at: c].
                    node suffixLink: link.
                    cur children at: c put: node.
                    size := size + 1.
                    nodes at: size put: node.
                    last := node]].

        "Propagate occurrence counts from longer palindromes to their suffix links."
        sorted := (nodes copyFrom: 1 to: size)
                    asSortedCollection: [:a :b | a len >= b len].
        sorted do: [:n |
            n len > 0 ifTrue: [
                n suffixLink cnt: n suffixLink cnt + n cnt]].

        tree := Eertree new
                    nodes: nodes;
                    size: size;
                    last: last;
                    str: s;
                    strLen: len;
                    yourself.
        ^tree
    ]

    "Number of distinct palindromic substrings (real nodes, excluding the two roots)."
    eertreeCountDistinct: tree [
        tree isNil ifTrue: [^0].
        tree size isNil ifTrue: [^0].
        ^(tree size - 2) max: 0
    ]

    "Propagated occurrence count of the palindrome equal to pattern (length plen).
     0 if not found, not a palindrome, or any argument is nil."
    eertreeCountOccurrences: tree pattern: pattern length: plen [
        | node |
        (tree isNil or: [pattern isNil or: [plen isNil]]) ifTrue: [^0].
        (plen < 1 or: [pattern size ~= plen]) ifTrue: [^0].
        node := (tree nodes copyFrom: 3 to: tree size)
                    detect: [:n |
                        n len = plen and: [
                            self matchPattern: pattern length: plen node: n in: tree]]
                    ifNone: [nil].
        node isNil ifTrue: [^0].
        ^node cnt
    ]

    "Answer true if the occurrence of node n in tree's string equals pattern."
    matchPattern: pattern length: plen node: n in: tree [
        | st str |
        str := tree str.
        str isNil ifTrue: [^false].
        st := n endPos - plen + 1.
        st < 0 ifTrue: [^false].
        ^(1 to: plen) conform: [:i |
            (str at: st + i) = (pattern at: i)]
    ]

    "Maximum len among all real nodes."
    eertreeLongestLength: tree [
        | max |
        tree isNil ifTrue: [^0].
        tree size isNil ifTrue: [^0].
        max := 0.
        3 to: tree size do: [:i |
            max := max max: (tree nodes at: i) len].
        ^max
    ]
]
