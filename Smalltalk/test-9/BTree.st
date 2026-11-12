Object subclass: BTreeNode [
    | keys children |

    "keys: strictly ascending Integers.
     children: empty for a leaf, otherwise exactly (keys size + 1) BTreeNodes."

    BTreeNode class >> keys: k children: c [
        ^self new initKeys: k children: c
    ]

    initKeys: k children: c [
        keys := k.
        children := c.
        ^self
    ]

    keys [ ^keys ]
    keys: k [ keys := k ]
    children [ ^children ]
    children: c [ children := c ]
    isLeaf [ ^children isEmpty ]
]

Object subclass: BTree [
    insertAll: keys degree: t [
        ^self subclassResponsibility
    ]

    deleteAll: deletions from: keys degree: t [
        ^self subclassResponsibility
    ]
]
