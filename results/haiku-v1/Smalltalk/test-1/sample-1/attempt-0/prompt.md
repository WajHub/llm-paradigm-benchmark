You are a GNU Smalltalk programming expert. Your task is to implement the required methods in accordance with the provided class hierarchy.

- Implement `calculateCleanMinkowskiSum: poly1 with: poly2`: calculate the Minkowski sum of two convex polygons and return a new Polygon representing only the convex hull of the resulting point cloud. The returned polygon must contain strictly extreme points only, with collinear edge points removed, ordered counter-clockwise.
- Implement `checkDynamicCollision: obstacle robot: robot velocity: velocity`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector (a Point). Use the Minkowski sum configuration-space approach to prevent tunneling.
- Implement `createPolygon: numVertices name: aName` and `createLayer: aName`: allocate the required objects (Polygon, SpatialLayer) and safely copy the provided names into the corresponding fields.
- The built-in Point class (with `x` and `y` accessors, created via `Point x: ... y: ...`) is used for 2D coordinates and velocity vectors.
- Handle nil arguments gracefully: `calculateCleanMinkowskiSum:with:` returns nil when either argument is nil; `checkDynamicCollision:robot:velocity:` returns false when either polygon is nil or has nil/empty vertices.
- Use idiomatic GNU Smalltalk and object-oriented design.
- Keep the contract in `SpatialLogic.st`, the concrete solution will live in `SpatialLogicImpl.st`.
- Return only raw Smalltalk code.

General Requirements:
- Use idiomatic GNU Smalltalk (gst) syntax.
- Use object-oriented design and model the domain with classes and message passing.
- Do not redefine built-in classes (e.g. Point, Set, Interval); use them as provided.
- Prefer standard Smalltalk collections and idioms where appropriate.
- Return ONLY raw Smalltalk code (no Markdown tags, no ```smalltalk blocks, no side text). Your code will be directly saved to a .st file and loaded by gst. Do not provide test code.

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