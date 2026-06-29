Object subclass: EertreeNode [
    | len suffixLink children cnt endPos |

    len [ ^len ]
    len: x [ len := x ]
    suffixLink [ ^suffixLink ]
    suffixLink: x [ suffixLink := x ]
    children [ ^children ]
    children: x [ children := x ]
    cnt [ ^cnt ]
    cnt: x [ cnt := x ]
    endPos [ ^endPos ]
    endPos: x [ endPos := x ]
]

Object subclass: Eertree [
    | nodes size last str strLen |

    nodes [ ^nodes ]
    nodes: x [ nodes := x ]
    size [ ^size ]
    size: x [ size := x ]
    last [ ^last ]
    last: x [ last := x ]
    str [ ^str ]
    str: x [ str := x ]
    strLen [ ^strLen ]
    strLen: x [ strLen := x ]
]

Object subclass: PalindromeTree [
    "Build the palindrome tree (Eertree) for aString of length len.
     Return an Eertree, or nil if aString is nil and len > 0."
    eertreeBuild: aString length: len [
        self subclassResponsibility
    ]

    "Number of distinct palindromic substrings (real nodes, excluding the two roots)."
    eertreeCountDistinct: tree [
        self subclassResponsibility
    ]

    "Propagated occurrence count of the palindrome equal to pattern (length plen).
     0 if not found, not a palindrome, or any argument is nil."
    eertreeCountOccurrences: tree pattern: pattern length: plen [
        self subclassResponsibility
    ]

    "Maximum len among all real nodes."
    eertreeLongestLength: tree [
        self subclassResponsibility
    ]
]
