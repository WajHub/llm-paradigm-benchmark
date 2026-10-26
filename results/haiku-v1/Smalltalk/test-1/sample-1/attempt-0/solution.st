SpatialLogic subclass: SpatialLogicImpl [

    calculateCleanMinkowskiSum: poly1 with: poly2 [
        | pts1 pts2 hull result |
        (poly1 isNil or: [poly2 isNil]) ifTrue: [^nil].
        pts1 := self validVerticesOf: poly1.
        pts2 := self validVerticesOf: poly2.
        hull := self minkowskiHullOf: pts1 with: pts2.
        result := Polygon numVertices: hull size name: (poly1 zoneName ifNil: ['']) copy.
        result vertices: hull.
        result isConvex: true.
        ^result
    ]

    checkDynamicCollision: obstacle robot: robot velocity: velocity [
        | obsPts robPts negatedRobot cs |
        (obstacle isNil or: [robot isNil or: [velocity isNil]]) ifTrue: [^false].
        obsPts := self validVerticesOf: obstacle.
        robPts := self validVerticesOf: robot.
        (obsPts isEmpty or: [robPts isEmpty]) ifTrue: [^false].
        "Configuration space: obstacle (+) (-robot). The robot moves along the
         segment 0 -> velocity, so collision occurs iff that segment meets C."
        negatedRobot := robPts collect: [:p | Point x: p x negated y: p y negated].
        cs := self minkowskiHullOf: obsPts with: negatedRobot.
        ^self segmentFrom: (Point x: 0 y: 0) to: velocity intersectsConvex: cs
    ]

    createPolygon: numVertices name: aName [
        ^Polygon numVertices: numVertices name: (aName isNil ifTrue: [''] ifFalse: [aName copy])
    ]

    createLayer: aName [
        ^SpatialLayer name: (aName isNil ifTrue: [''] ifFalse: [aName copy])
    ]

    "--- private helpers ---"

    validVerticesOf: poly [
        | vs |
        poly isNil ifTrue: [^#()].
        vs := poly vertices.
        vs isNil ifTrue: [^#()].
        ^vs reject: [:v | v isNil]
    ]

    minkowskiHullOf: pts1 with: pts2 [
        | sums |
        (pts1 isEmpty or: [pts2 isEmpty]) ifTrue: [^#()].
        sums := OrderedCollection new.
        pts1 do: [:p |
            pts2 do: [:q |
                sums add: (Point x: p x + q x y: p y + q y)]].
        ^self convexHullOf: sums
    ]

    "Andrew's monotone chain; collinear points are removed; result is CCW."
    convexHullOf: points [
        | sorted unique lower upper |
        sorted := points asSortedCollection: [:p :q |
            p x < q x or: [p x = q x and: [p y <= q y]]].
        unique := OrderedCollection new.
        sorted do: [:p |
            (unique isEmpty
                or: [unique last x ~= p x or: [unique last y ~= p y]])
                ifTrue: [unique add: p]].
        unique size < 3 ifTrue: [^unique asArray].
        lower := OrderedCollection new.
        unique do: [:p |
            [lower size >= 2 and: [
                (self orient: (lower at: lower size - 1) to: lower last point: p) <= 0]]
                whileTrue: [lower removeLast].
            lower add: p].
        upper := OrderedCollection new.
        unique reverseDo: [:p |
            [upper size >= 2 and: [
                (self orient: (upper at: upper size - 1) to: upper last point: p) <= 0]]
                whileTrue: [upper removeLast].
            upper add: p].
        lower removeLast.
        upper removeLast.
        lower addAll: upper.
        ^lower asArray
    ]

    orient: a to: b point: c [
        "Cross product of (b - a) and (c - a)."
        ^((b x - a x) * (c y - a y)) - ((b y - a y) * (c x - a x))
    ]

    on: c within: a to: b [
        ^(c x between: (a x min: b x) and: (a x max: b x))
            and: [c y between: (a y min: b y) and: (a y max: b y)]
    ]

    pointInside: p convex: hull [
        "hull is CCW with at least 3 vertices; boundary counts as inside."
        | n a b |
        n := hull size.
        1 to: n do: [:i |
            a := hull at: i.
            b := hull at: (i \\ n) + 1.
            (self orient: a to: b point: p) < 0 ifTrue: [^false]].
        ^true
    ]

    segmentFrom: p to: q intersectsConvex: hull [
        | n |
        n := hull size.
        n = 0 ifTrue: [^false].
        (n >= 3 and: [self pointInside: p convex: hull]) ifTrue: [^true].
        1 to: n do: [:i |
            (self segment: p to: q intersects: (hull at: i) to: (hull at: (i \\ n) + 1))
                ifTrue: [^true]].
        ^false
    ]

    segment: p to: q intersects: a to: b [
        | d1 d2 d3 d4 |
        d1 := self orient: a to: b point: p.
        d2 := self orient: a to: b point: q.
        d3 := self orient: p to: q point: a.
        d4 := self orient: p to: q point: b.
        ((d1 * d2) < 0 and: [(d3 * d4) < 0]) ifTrue: [^true].
        (d1 = 0 and: [self on: p within: a to: b]) ifTrue: [^true].
        (d2 = 0 and: [self on: q within: a to: b]) ifTrue: [^true].
        (d3 = 0 and: [self on: a within: p to: q]) ifTrue: [^true].
        (d4 = 0 and: [self on: b within: p to: q]) ifTrue: [^true].
        ^false
    ]

]
