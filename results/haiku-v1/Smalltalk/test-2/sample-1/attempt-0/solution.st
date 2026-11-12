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
        ^DijkstraGraph numVertices: numVertices
    ]

    addEdge: graph from: from to: to weight: weight [
        | n |
        graph isNil ifTrue: [^nil].
        n := graph numVertices.
        ((from isInteger and: [from >= 0 and: [from < n]]) and:
            [to isInteger and: [to >= 0 and: [to < n]]])
                ifFalse: [^nil].
        (graph adjacency at: from + 1)
            add: (Edge to: to weight: weight).
        ^graph
    ]

    dijkstra: graph source: source [
        | n distances predecessors visited current currentDist |
        graph isNil ifTrue: [^nil].
        n := graph numVertices.
        (source isInteger and: [source >= 0 and: [source < n]])
            ifFalse: [^nil].
        distances := Array new: n withAll: Float infinity.
        predecessors := Array new: n withAll: nil.
        visited := Array new: n withAll: false.
        distances at: source + 1 put: 0.
        [
            current := nil.
            currentDist := Float infinity.
            1 to: n do: [:i |
                ((visited at: i) not and: [(distances at: i) < currentDist])
                    ifTrue: [
                        current := i.
                        currentDist := distances at: i]].
            current notNil
        ] whileTrue: [
            visited at: current put: true.
            (graph adjacency at: current) do: [:edge |
                | v alt |
                v := edge eTo + 1.
                alt := currentDist + edge weight.
                alt < (distances at: v) ifTrue: [
                    distances at: v put: alt.
                    predecessors at: v put: current - 1]]].
        ^DijkstraResult distances: distances predecessors: predecessors source: source
    ]

    getShortestDistance: result target: target [
        | d |
        result isNil ifTrue: [^Float infinity].
        d := result distances.
        (target isInteger and: [target >= 0 and: [target < d size]])
            ifFalse: [^Float infinity].
        ^d at: target + 1
    ]

    reconstructPath: result target: target [
        | d preds path current |
        result isNil ifTrue: [^nil].
        d := result distances.
        (target isInteger and: [target >= 0 and: [target < d size]])
            ifFalse: [^nil].
        (d at: target + 1) = Float infinity ifTrue: [^nil].
        preds := result predecessors.
        path := OrderedCollection new.
        current := target.
        [current notNil] whileTrue: [
            path addFirst: current.
            current := preds at: current + 1].
        (path first = result source) ifFalse: [^nil].
        ^path
    ]
]
