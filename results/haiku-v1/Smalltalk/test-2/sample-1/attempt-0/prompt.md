You are a GNU Smalltalk programming expert. Your task is to implement the required methods in accordance with the provided class hierarchy.

- Implement `createGraph: numVertices`: Create a DijkstraGraph with given vertices (0-indexed internally, but Smalltalk arrays are 1-indexed — handle the mapping).
- Implement `addEdge: graph from: from to: to weight: weight`: Add a directed edge. Mutate the graph's adjacency list.
- Implement `dijkstra: graph source: source`: Run Dijkstra's algorithm. Return a DijkstraResult with distances and predecessors arrays. Unreachable vertices get Float infinity. Return nil if graph is nil or source out of bounds.
- Implement `getShortestDistance: result target: target`: Return distance. Return Float infinity if nil or out of bounds.
- Implement `reconstructPath: result target: target`: Return an OrderedCollection of vertex indices (0-based) from source to target. Return nil if unreachable.
- Use the built-in Edge, DijkstraGraph, DijkstraResult classes defined in ShortestPath.st.
- Use idiomatic GNU Smalltalk.

General Requirements:
- Use idiomatic GNU Smalltalk (gst) syntax.
- Use object-oriented design and model the domain with classes and message passing.
- Do not redefine built-in classes (e.g. Point, Set, Interval); use them as provided.
- Prefer standard Smalltalk collections and idioms where appropriate.
- Return ONLY raw Smalltalk code (no Markdown tags, no ```smalltalk blocks, no side text). Your code will be directly saved to a .st file and loaded by gst. Do not provide test code.

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