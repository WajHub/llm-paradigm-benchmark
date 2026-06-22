Object subclass: Polygon [
    | vertices numVertices isConvex zoneName |

    Polygon class >> numVertices: n name: aName [
        ^self new initNumVertices: n name: aName
    ]

    initNumVertices: n name: aName [
        numVertices := n max: 0.
        vertices := Array new: numVertices.
        isConvex := false.
        zoneName := aName ifNil: [''].
    ]

    vertices [ ^vertices ]
    vertices: v [ vertices := v ]
    numVertices [ ^numVertices ]
    numVertices: n [ numVertices := n ]
    isConvex [ ^isConvex ]
    isConvex: b [ isConvex := b ]
    zoneName [ ^zoneName ]
    zoneName: n [ zoneName := n ]
]

Object subclass: SpatialLayer [
    | polygons polygonCount layerName |

    SpatialLayer class >> name: aName [
        ^self new initName: aName
    ]

    initName: aName [
        polygons := OrderedCollection new.
        polygonCount := 0.
        layerName := aName ifNil: [''].
    ]

    polygons [ ^polygons ]
    polygons: p [ polygons := p ]
    polygonCount [ ^polygonCount ]
    polygonCount: c [ polygonCount := c ]
    layerName [ ^layerName ]
    layerName: n [ layerName := n ]
]

Object subclass: SpatialLogic [
    calculateCleanMinkowskiSum: poly1 with: poly2 [
        self subclassResponsibility
    ]

    checkDynamicCollision: obstacle robot: robot velocity: velocity [
        self subclassResponsibility
    ]

    createPolygon: numVertices name: aName [
        self subclassResponsibility
    ]

    createLayer: aName [
        self subclassResponsibility
    ]
]
