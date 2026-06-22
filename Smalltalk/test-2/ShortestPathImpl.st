ShortestPath subclass: ShortestPathImpl [
    createGraph: numVertices [
        self error: 'Not implemented'
    ]

    addEdge: graph from: from to: to weight: weight [
        self error: 'Not implemented'
    ]

    dijkstra: graph source: source [
        self error: 'Not implemented'
    ]

    getShortestDistance: result target: target [
        self error: 'Not implemented'
    ]

    reconstructPath: result target: target [
        self error: 'Not implemented'
    ]
]
