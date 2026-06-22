SpatialLogic subclass: SpatialLogicImpl [
    createPolygon: numVertices name: aName [
    ]

    createLayer: aName [
    ]

    calculateCleanMinkowskiSum: poly1 with: poly2 [
    ]

    checkDynamicCollision: obstacle robot: robot velocity: velocity [
    ]

    reflectedPolygon: aPolygon [
    ]

    convexHullFromPoints: points [
    ]

    crossFrom: a through: b to: c [
    ]

    point: point insideConvexPolygon: polygon [
    ]

    segmentFrom: p1 to: p2 intersectsPolygon: polygon [
    ]

    segment: p1 to: p2 intersectsSegment: q1 to: q2 [
    ]

    orientation: a b: b c: c [
    ]

    point: p onSegmentFrom: a to: b [
    ]
]