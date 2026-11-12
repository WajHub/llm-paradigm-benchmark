ShortestPath subclass: ShortestPathImpl [

    infinity [
        ^FloatD infinity
    ]

    createGraph: numVertices [
        | n |
        n := (numVertices isInteger) ifTrue: [numVertices] ifFalse: [0].
        ^DijkstraGraph numVertices: n
    ]

    addEdge: graph from: from to: to weight: weight [
        | n |
        graph isNil ifTrue: [^nil].
        n := graph numVertices.
        ((from isInteger and: [from >= 0 and: [from < n]]) and:
            [to isInteger and: [to >= 0 and: [to < n]]])
                ifFalse: [^nil].
        (graph adjacency at: from + 1)
            add: (Edge to: to weight: weight asFloat).
        ^graph
    ]

    dijkstra: graph source: source [
        | n distances predecessors visited current currentDist |
        graph isNil ifTrue: [^nil].
        n := graph numVertices.
        (source isInteger and: [source >= 0 and: [source < n]])
            ifFalse: [^nil].
        distances := Array new: n withAll: self infinity.
        predecessors := Array new: n withAll: nil.
        visited := Array new: n withAll: false.
        distances at: source + 1 put: 0.0.
        [
            current := nil.
            currentDist := self infinity.
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
        result isNil ifTrue: [^self infinity].
        d := result distances.
        (target isInteger and: [target >= 0 and: [target < d size]])
            ifFalse: [^self infinity].
        ^d at: target + 1
    ]

    reconstructPath: result target: target [
        | d preds path current |
        result isNil ifTrue: [^nil].
        d := result distances.
        (target isInteger and: [target >= 0 and: [target < d size]])
            ifFalse: [^nil].
        (d at: target + 1) = self infinity ifTrue: [^nil].
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
