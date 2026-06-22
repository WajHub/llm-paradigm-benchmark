SpatialLogic subclass: SpatialLogicImpl [
    createPolygon: numVertices name: aName [
    | nameCopy polygon |
    nameCopy := aName
        ifNil: ['']
        ifNotNil: [aName asString copy].

    polygon := Polygon numVertices: numVertices name: nameCopy.
    polygon zoneName: nameCopy.
    ^polygon
]

createLayer: aName [
    | nameCopy layer |
    nameCopy := aName
        ifNil: ['']
        ifNotNil: [aName asString copy].

    layer := SpatialLayer name: nameCopy.
    layer layerName: nameCopy.
    ^layer
]

calculateCleanMinkowskiSum: poly1 with: poly2 [
    | v1 v2 points hull result |

    (poly1 isNil or: [poly2 isNil]) ifTrue: [^nil].

    v1 := poly1 vertices.
    v2 := poly2 vertices.

    (v1 isNil or: [v2 isNil]) ifTrue: [^nil].

    points := OrderedCollection new.

    v1 do: [:p1 |
        p1 ifNotNil: [
            v2 do: [:p2 |
                p2 ifNotNil: [
                    points add: (Point x: (p1 x + p2 x) y: (p1 y + p2 y))
                ]
            ]
        ]
    ].

    points isEmpty ifTrue: [
        result := self createPolygon: 0 name: 'MinkowskiSum'.
        result vertices: #().
        result numVertices: 0.
        result isConvex: true.
        ^result
    ].

    hull := self convexHullFromPoints: points.

    result := self createPolygon: hull size name: 'MinkowskiSum'.
    result vertices: hull asArray.
    result numVertices: hull size.
    result isConvex: true.

    ^result
]

checkDynamicCollision: obstacle robot: robot velocity: velocity [
    | obstacleVertices robotVertices reflectedRobot configSpace origin endPoint |

    (obstacle isNil or: [robot isNil]) ifTrue: [^false].

    obstacleVertices := obstacle vertices.
    robotVertices := robot vertices.

    ((obstacleVertices isNil or: [robotVertices isNil])
        or: [obstacleVertices isEmpty or: [robotVertices isEmpty]])
        ifTrue: [^false].

    reflectedRobot := self reflectedPolygon: robot.

    configSpace := self
        calculateCleanMinkowskiSum: obstacle
        with: reflectedRobot.

    configSpace isNil ifTrue: [^false].

    origin := Point x: 0 y: 0.
    endPoint := velocity ifNil: [origin].

    ((self point: origin insideConvexPolygon: configSpace)
        or: [self point: endPoint insideConvexPolygon: configSpace])
        ifTrue: [^true].

    ^self segmentFrom: origin
        to: endPoint
        intersectsPolygon: configSpace
]

reflectedPolygon: aPolygon [
    | verts reflected result |

    verts := aPolygon vertices.

    reflected := OrderedCollection new.
    verts do: [:p |
        p ifNotNil: [
            reflected add: (Point x: p x negated y: p y negated)
        ]
    ].

    result := self createPolygon: reflected size name: aPolygon zoneName.
    result vertices: reflected asArray.
    result numVertices: reflected size.
    result isConvex: aPolygon isConvex.

    ^result
]

convexHullFromPoints: points [
    | sorted lower upper hull |

    sorted := points asSortedCollection: [:a :b |
        (a x < b x)
            or: [(a x = b x) and: [a y < b y]]
    ].

    sorted size <= 1 ifTrue: [^sorted asOrderedCollection].

    lower := OrderedCollection new.

    sorted do: [:p |
        [
            lower size >= 2 and: [
                (self crossFrom: (lower at: lower size - 1)
                    through: (lower last)
                    to: p) <= 0
            ]
        ] whileTrue: [
            lower removeLast
        ].
        lower add: p
    ].

    upper := OrderedCollection new.

    sorted reverseDo: [:p |
        [
            upper size >= 2 and: [
                (self crossFrom: (upper at: upper size - 1)
                    through: (upper last)
                    to: p) <= 0
            ]
        ] whileTrue: [
            upper removeLast
        ].
        upper add: p
    ].

    lower removeLast.
    upper removeLast.

    hull := OrderedCollection new.
    hull addAll: lower.
    hull addAll: upper.

    ^hull
]

crossFrom: a through: b to: c [
    ^((b x - a x) * (c y - a y))
        - ((b y - a y) * (c x - a x))
]

point: point insideConvexPolygon: polygon [
    | verts n sign cross |

    verts := polygon vertices.
    n := verts size.

    n = 0 ifTrue: [^false].
    n = 1 ifTrue: [^(point x = (verts first x))
                    and: [point y = (verts first y)]].

    sign := nil.

    1 to: n do: [:i |
        | a b |
        a := verts at: i.
        b := verts at: ((i = n) ifTrue: [1] ifFalse: [i + 1]).

        cross := ((b x - a x) * (point y - a y))
            - ((b y - a y) * (point x - a x)).

        cross ~= 0 ifTrue: [
            sign isNil
                ifTrue: [sign := cross > 0]
                ifFalse: [
                    sign = (cross > 0) ifFalse: [^false]
                ]
        ]
    ].

    ^true
]

segmentFrom: p1 to: p2 intersectsPolygon: polygon [
    | verts n |

    verts := polygon vertices.
    n := verts size.

    1 to: n do: [:i |
        | a b |
        a := verts at: i.
        b := verts at: ((i = n) ifTrue: [1] ifFalse: [i + 1]).

        (self segment: p1 to: p2 intersectsSegment: a to: b)
            ifTrue: [^true]
    ].

    ^false
]

segment: p1 to: p2 intersectsSegment: q1 to: q2 [
    | o1 o2 o3 o4 |

    o1 := self orientation: p1 b: p2 c: q1.
    o2 := self orientation: p1 b: p2 c: q2.
    o3 := self orientation: q1 b: q2 c: p1.
    o4 := self orientation: q1 b: q2 c: p2.

    (((o1 > 0 and: [o2 < 0]) or: [o1 < 0 and: [o2 > 0]])
        and: [((o3 > 0 and: [o4 < 0]) or: [o3 < 0 and: [o4 > 0]])])
        ifTrue: [^true].

    (o1 = 0 and: [self point: q1 onSegmentFrom: p1 to: p2]) ifTrue: [^true].
    (o2 = 0 and: [self point: q2 onSegmentFrom: p1 to: p2]) ifTrue: [^true].
    (o3 = 0 and: [self point: p1 onSegmentFrom: q1 to: q2]) ifTrue: [^true].
    (o4 = 0 and: [self point: p2 onSegmentFrom: q1 to: q2]) ifTrue: [^true].

    ^false
]

orientation: a b: b c: c [
    ^((b x - a x) * (c y - a y))
        - ((b y - a y) * (c x - a x))
]

point: p onSegmentFrom: a to: b [
    ^((p x >= (a x min: b x))
        and: [p x <= (a x max: b x)])
        and: [
            (p y >= (a y min: b y))
                and: [p y <= (a y max: b y)]
        ]
]
]