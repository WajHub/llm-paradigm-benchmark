Object subclass: Edge [
    | eTo weight |

    Edge class >> to: t weight: w [
        ^self new initTo: t weight: w
    ]

    initTo: t weight: w [
        eTo := t.
        weight := w.
    ]

    eTo [ ^eTo ]
    eTo: t [ eTo := t ]
    weight [ ^weight ]
    weight: w [ weight := w ]
]

Object subclass: DijkstraGraph [
    | adjacency numVertices |

    DijkstraGraph class >> numVertices: n [
        ^self new initNumVertices: n
    ]

    initNumVertices: n [
        numVertices := n max: 0.
        adjacency := Array new: numVertices withAll: OrderedCollection new.
        1 to: numVertices do: [:i | adjacency at: i put: OrderedCollection new].
    ]

    adjacency [ ^adjacency ]
    adjacency: a [ adjacency := a ]
    numVertices [ ^numVertices ]
    numVertices: n [ numVertices := n ]
]

Object subclass: DijkstraResult [
    | distances predecessors source |

    DijkstraResult class >> distances: d predecessors: p source: s [
        ^self new initDistances: d predecessors: p source: s
    ]

    initDistances: d predecessors: p source: s [
        distances := d.
        predecessors := p.
        source := s.
    ]

    distances [ ^distances ]
    distances: d [ distances := d ]
    predecessors [ ^predecessors ]
    predecessors: p [ predecessors := p ]
    source [ ^source ]
    source: s [ source := s ]
]

Object subclass: ShortestPath [
    createGraph: numVertices [
        self subclassResponsibility
    ]

    addEdge: graph from: from to: to weight: weight [
        self subclassResponsibility
    ]

    dijkstra: graph source: source [
        self subclassResponsibility
    ]

    getShortestDistance: result target: target [
        self subclassResponsibility
    ]

    reconstructPath: result target: target [
        self subclassResponsibility
    ]
]
