Object subclass: Tests [
    | logic |

    Tests class >> new [
        ^super new init
    ]

    init [
        logic := SpatialLogicImpl new.
    ]

    containsPoint: polygon x: px y: py [
        polygon isNil ifTrue: [^false].
        polygon vertices isNil ifTrue: [^false].
        1 to: polygon numVertices do: [:i |
            | v |
            v := polygon vertices at: i.
            ((v x - px) abs < 0.001 and: [(v y - py) abs < 0.001])
                ifTrue: [^true]
        ].
        ^false
    ]

    "======================================================================"
    " Algorithm A: calculate_clean_minkowski_sum (Convex Hull)             "
    "======================================================================"

    testAlgoA01BasicSquares [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 4 name: 'Z1'.
        poly1 vertices at: 1 put: (Point x: 0 y: 0).
        poly1 vertices at: 2 put: (Point x: 2 y: 0).
        poly1 vertices at: 3 put: (Point x: 2 y: 2).
        poly1 vertices at: 4 put: (Point x: 0 y: 2).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 4 name: 'Z2'.
        poly2 vertices at: 1 put: (Point x: 0 y: 0).
        poly2 vertices at: 2 put: (Point x: 2 y: 0).
        poly2 vertices at: 3 put: (Point x: 2 y: 2).
        poly2 vertices at: 4 put: (Point x: 0 y: 2).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 4 ifFalse: [passed := false].
        (self containsPoint: result x: 0 y: 0) ifFalse: [passed := false].
        (self containsPoint: result x: 4 y: 0) ifFalse: [passed := false].
        (self containsPoint: result x: 4 y: 4) ifFalse: [passed := false].
        (self containsPoint: result x: 0 y: 4) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA02PointAndPolygon [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 1 name: 'Point'.
        poly1 vertices at: 1 put: (Point x: 5 y: 5).
        poly1 numVertices: 1.
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 3 name: 'Triangle'.
        poly2 vertices at: 1 put: (Point x: 0 y: 0).
        poly2 vertices at: 2 put: (Point x: 1 y: 0).
        poly2 vertices at: 3 put: (Point x: 0 y: 1).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 3 ifFalse: [passed := false].
        (self containsPoint: result x: 5 y: 5) ifFalse: [passed := false].
        (self containsPoint: result x: 6 y: 5) ifFalse: [passed := false].
        (self containsPoint: result x: 5 y: 6) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA03CollinearSimplification [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 3 name: 'Tri1'.
        poly1 vertices at: 1 put: (Point x: 0 y: 0).
        poly1 vertices at: 2 put: (Point x: 2 y: 0).
        poly1 vertices at: 3 put: (Point x: 0 y: 2).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 3 name: 'Tri2'.
        poly2 vertices at: 1 put: (Point x: 0 y: 0).
        poly2 vertices at: 2 put: (Point x: 2 y: 0).
        poly2 vertices at: 3 put: (Point x: 0 y: 2).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 3 ifFalse: [passed := false].
        (self containsPoint: result x: 0 y: 0) ifFalse: [passed := false].
        (self containsPoint: result x: 4 y: 0) ifFalse: [passed := false].
        (self containsPoint: result x: 0 y: 4) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA04NegativeCoordinates [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 4 name: 'NegSq'.
        poly1 vertices at: 1 put: (Point x: -5 y: -5).
        poly1 vertices at: 2 put: (Point x: -3 y: -5).
        poly1 vertices at: 3 put: (Point x: -3 y: -3).
        poly1 vertices at: 4 put: (Point x: -5 y: -3).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 4 name: 'PosSq'.
        poly2 vertices at: 1 put: (Point x: 1 y: 1).
        poly2 vertices at: 2 put: (Point x: 2 y: 1).
        poly2 vertices at: 3 put: (Point x: 2 y: 2).
        poly2 vertices at: 4 put: (Point x: 1 y: 2).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 4 ifFalse: [passed := false].
        (self containsPoint: result x: -4 y: -4) ifFalse: [passed := false].
        (self containsPoint: result x: -1 y: -1) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA05SinglePoints [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 1 name: 'Pt1'.
        poly1 vertices at: 1 put: (Point x: -2.5 y: 3.5).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 1 name: 'Pt2'.
        poly2 vertices at: 1 put: (Point x: 2.5 y: -3.5).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 1 ifFalse: [passed := false].
        (self containsPoint: result x: 0.0 y: 0.0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA06EmptyFirstPolygon [
        | poly1 poly2 result |
        poly1 := Polygon numVertices: 0 name: 'Empty'.
        poly1 vertices: nil.
        poly1 numVertices: 0.
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 2 name: 'Line'.
        poly2 vertices at: 1 put: (Point x: 0 y: 0).
        poly2 vertices at: 2 put: (Point x: 1 y: 1).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].
        ^result numVertices = 0
    ]

    testAlgoA07EmptySecondPolygon [
        | poly1 poly2 result |
        poly1 := Polygon numVertices: 2 name: 'Line'.
        poly1 vertices at: 1 put: (Point x: 0 y: 0).
        poly1 vertices at: 2 put: (Point x: 1 y: 1).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 0 name: 'Empty'.
        poly2 vertices: nil.
        poly2 numVertices: 0.
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].
        ^result numVertices = 0
    ]

    testAlgoA08NilArguments [
        | poly1 result1 result2 result3 |
        poly1 := Polygon numVertices: 1 name: 'Pt'.
        poly1 vertices at: 1 put: (Point x: 0 y: 0).
        poly1 isConvex: true.

        result1 := logic calculateCleanMinkowskiSum: nil with: poly1.
        result2 := logic calculateCleanMinkowskiSum: poly1 with: nil.
        result3 := logic calculateCleanMinkowskiSum: nil with: nil.

        ^result1 isNil and: [result2 isNil and: [result3 isNil]]
    ]

    testAlgoA09FlatPolygon [
        | poly1 poly2 result passed |
        poly1 := Polygon numVertices: 2 name: 'Line1'.
        poly1 vertices at: 1 put: (Point x: 0 y: 0).
        poly1 vertices at: 2 put: (Point x: 2 y: 0).
        poly1 isConvex: true.

        poly2 := Polygon numVertices: 2 name: 'Line2'.
        poly2 vertices at: 1 put: (Point x: 0 y: 0).
        poly2 vertices at: 2 put: (Point x: 3 y: 0).
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].

        passed := true.
        result numVertices = 2 ifFalse: [passed := false].
        (self containsPoint: result x: 0 y: 0) ifFalse: [passed := false].
        (self containsPoint: result x: 5 y: 0) ifFalse: [passed := false].
        ^passed
    ]

    testAlgoA10StressTest [
        | size largeArr poly1 poly2 result pi |
        size := 500.
        pi := 3.14159265358979323846.
        largeArr := Array new: size.
        1 to: size do: [:i |
            | angle |
            angle := 2.0 * pi * (i - 1) / size.
            largeArr at: i put: (Point x: angle cos y: angle sin)
        ].

        poly1 := Polygon numVertices: size name: 'Circle1'.
        poly1 vertices: largeArr.
        poly1 isConvex: true.

        poly2 := Polygon numVertices: size name: 'Circle2'.
        poly2 vertices: largeArr copy.
        poly2 isConvex: true.

        result := logic calculateCleanMinkowskiSum: poly1 with: poly2.
        result isNil ifTrue: [^false].
        ^result numVertices > 0
    ]

    "======================================================================"
    " Algorithm B: check_dynamic_collision (Bullet-Tunneling Prevention)   "
    "======================================================================"

    testAlgoB01TunnelingCollision [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 5 y: 0).
        obstacle vertices at: 2 put: (Point x: 6 y: 0).
        obstacle vertices at: 3 put: (Point x: 6 y: 1).
        obstacle vertices at: 4 put: (Point x: 5 y: 1).
        obstacle isConvex: true.

        velocity := Point x: 10.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = true
    ]

    testAlgoB02ClearMiss [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 0 y: 5).
        obstacle vertices at: 2 put: (Point x: 1 y: 5).
        obstacle vertices at: 3 put: (Point x: 1 y: 6).
        obstacle vertices at: 4 put: (Point x: 0 y: 6).
        obstacle isConvex: true.

        velocity := Point x: 10.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = false
    ]

    testAlgoB03StaticOverlap [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 2 y: 0).
        robot vertices at: 3 put: (Point x: 2 y: 2).
        robot vertices at: 4 put: (Point x: 0 y: 2).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 1 y: 1).
        obstacle vertices at: 2 put: (Point x: 3 y: 1).
        obstacle vertices at: 3 put: (Point x: 3 y: 3).
        obstacle vertices at: 4 put: (Point x: 1 y: 3).
        obstacle isConvex: true.

        velocity := Point x: 0.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = true
    ]

    testAlgoB04StaticMiss [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 10 y: 10).
        obstacle vertices at: 2 put: (Point x: 11 y: 10).
        obstacle vertices at: 3 put: (Point x: 11 y: 11).
        obstacle vertices at: 4 put: (Point x: 10 y: 11).
        obstacle isConvex: true.

        velocity := Point x: 0.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = false
    ]

    testAlgoB05MovingAway [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: -5 y: 0).
        obstacle vertices at: 2 put: (Point x: -4 y: 0).
        obstacle vertices at: 3 put: (Point x: -4 y: 1).
        obstacle vertices at: 4 put: (Point x: -5 y: 1).
        obstacle isConvex: true.

        velocity := Point x: 10.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = false
    ]

    testAlgoB06DiagonalTunneling [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 5 y: 5).
        obstacle vertices at: 2 put: (Point x: 7 y: 5).
        obstacle vertices at: 3 put: (Point x: 7 y: 7).
        obstacle vertices at: 4 put: (Point x: 5 y: 7).
        obstacle isConvex: true.

        velocity := Point x: 10.0 y: 10.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = true
    ]

    testAlgoB07EdgeGrazing [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 0 y: 0).
        robot vertices at: 2 put: (Point x: 1 y: 0).
        robot vertices at: 3 put: (Point x: 1 y: 1).
        robot vertices at: 4 put: (Point x: 0 y: 1).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 0 y: 1).
        obstacle vertices at: 2 put: (Point x: 1 y: 1).
        obstacle vertices at: 3 put: (Point x: 1 y: 2).
        obstacle vertices at: 4 put: (Point x: 0 y: 2).
        obstacle isConvex: true.

        velocity := Point x: 10.0 y: 0.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = true
    ]

    testAlgoB08NegativeVelocity [
        | robot obstacle velocity |
        robot := Polygon numVertices: 4 name: 'Robot'.
        robot vertices at: 1 put: (Point x: 10 y: 10).
        robot vertices at: 2 put: (Point x: 11 y: 10).
        robot vertices at: 3 put: (Point x: 11 y: 11).
        robot vertices at: 4 put: (Point x: 10 y: 11).
        robot isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 4 y: 4).
        obstacle vertices at: 2 put: (Point x: 6 y: 4).
        obstacle vertices at: 3 put: (Point x: 6 y: 6).
        obstacle vertices at: 4 put: (Point x: 4 y: 6).
        obstacle isConvex: true.

        velocity := Point x: -10.0 y: -10.0.
        ^(logic checkDynamicCollision: obstacle robot: robot velocity: velocity) = true
    ]

    testAlgoB09EmptyPolygons [
        | empty obstacle velocity col1 col2 |
        empty := Polygon numVertices: 0 name: 'Empty'.
        empty vertices: nil.
        empty numVertices: 0.
        empty isConvex: true.

        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 0 y: 0).
        obstacle vertices at: 2 put: (Point x: 1 y: 0).
        obstacle vertices at: 3 put: (Point x: 1 y: 1).
        obstacle vertices at: 4 put: (Point x: 0 y: 1).
        obstacle isConvex: true.

        velocity := Point x: 5.0 y: 5.0.

        col1 := logic checkDynamicCollision: obstacle robot: empty velocity: velocity.
        col2 := logic checkDynamicCollision: empty robot: obstacle velocity: velocity.

        ^col1 = false and: [col2 = false]
    ]

    testAlgoB10NilArguments [
        | obstacle velocity col1 col2 col3 |
        obstacle := Polygon numVertices: 4 name: 'Obstacle'.
        obstacle vertices at: 1 put: (Point x: 0 y: 0).
        obstacle vertices at: 2 put: (Point x: 1 y: 0).
        obstacle vertices at: 3 put: (Point x: 1 y: 1).
        obstacle vertices at: 4 put: (Point x: 0 y: 1).
        obstacle isConvex: true.

        velocity := Point x: 5.0 y: 5.0.

        col1 := logic checkDynamicCollision: nil robot: obstacle velocity: velocity.
        col2 := logic checkDynamicCollision: obstacle robot: nil velocity: velocity.
        col3 := logic checkDynamicCollision: nil robot: nil velocity: velocity.

        ^col1 = false and: [col2 = false and: [col3 = false]]
    ]

    "======================================================================"
    " Test Runner                                                          "
    "======================================================================"

    runAll [
        | failedCount totalTests failedTests |
        failedCount := 0.
        totalTests := 0.
        failedTests := OrderedCollection new.

        Transcript show: '=== START ==='; cr.
        Transcript cr.
        Transcript show: '--- Algorithm A: Clean Minkowski Sum (Convex Hull) ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoA01BasicSquares] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A01 (Basic Squares Hull)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A01 (Basic Squares Hull)'; cr.
                      failedTests add: 'Test A01 (Basic Squares Hull)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA02PointAndPolygon] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A02 (Point and Polygon)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A02 (Point and Polygon)'; cr.
                      failedTests add: 'Test A02 (Point and Polygon)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA03CollinearSimplification] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A03 (Collinear Simplification)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A03 (Collinear Simplification)'; cr.
                      failedTests add: 'Test A03 (Collinear Simplification)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA04NegativeCoordinates] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A04 (Negative Coordinates)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A04 (Negative Coordinates)'; cr.
                      failedTests add: 'Test A04 (Negative Coordinates)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA05SinglePoints] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A05 (Single Points)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A05 (Single Points)'; cr.
                      failedTests add: 'Test A05 (Single Points)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA06EmptyFirstPolygon] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A06 (Empty First Polygon)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A06 (Empty First Polygon)'; cr.
                      failedTests add: 'Test A06 (Empty First Polygon)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA07EmptySecondPolygon] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A07 (Empty Second Polygon)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A07 (Empty Second Polygon)'; cr.
                      failedTests add: 'Test A07 (Empty Second Polygon)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA08NilArguments] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A08 (Nil Arguments)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A08 (Nil Arguments)'; cr.
                      failedTests add: 'Test A08 (Nil Arguments)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA09FlatPolygon] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A09 (Flat Polygons / Lines)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A09 (Flat Polygons / Lines)'; cr.
                      failedTests add: 'Test A09 (Flat Polygons / Lines)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoA10StressTest] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test A10 (Stress Test 500x500)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test A10 (Stress Test 500x500)'; cr.
                      failedTests add: 'Test A10 (Stress Test 500x500)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '--- Algorithm B: Dynamic Collision Detection ---'; cr.

        totalTests := totalTests + 1.
        ([self testAlgoB01TunnelingCollision] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B01 (Tunneling Collision)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B01 (Tunneling Collision)'; cr.
                      failedTests add: 'Test B01 (Tunneling Collision)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB02ClearMiss] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B02 (Clear Miss)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B02 (Clear Miss)'; cr.
                      failedTests add: 'Test B02 (Clear Miss)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB03StaticOverlap] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B03 (Static Overlap)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B03 (Static Overlap)'; cr.
                      failedTests add: 'Test B03 (Static Overlap)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB04StaticMiss] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B04 (Static Miss)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B04 (Static Miss)'; cr.
                      failedTests add: 'Test B04 (Static Miss)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB05MovingAway] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B05 (Moving Away)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B05 (Moving Away)'; cr.
                      failedTests add: 'Test B05 (Moving Away)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB06DiagonalTunneling] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B06 (Diagonal Tunneling)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B06 (Diagonal Tunneling)'; cr.
                      failedTests add: 'Test B06 (Diagonal Tunneling)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB07EdgeGrazing] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B07 (Edge Grazing)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B07 (Edge Grazing)'; cr.
                      failedTests add: 'Test B07 (Edge Grazing)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB08NegativeVelocity] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B08 (Negative Velocity)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B08 (Negative Velocity)'; cr.
                      failedTests add: 'Test B08 (Negative Velocity)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB09EmptyPolygons] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B09 (Empty Polygons)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B09 (Empty Polygons)'; cr.
                      failedTests add: 'Test B09 (Empty Polygons)'.
                      failedCount := failedCount + 1].

        totalTests := totalTests + 1.
        ([self testAlgoB10NilArguments] on: Error do: [:e | false])
            ifTrue:  [Transcript show: '[PASS] Test B10 (Nil Arguments)'; cr]
            ifFalse: [Transcript show: '[FAIL] Test B10 (Nil Arguments)'; cr.
                      failedTests add: 'Test B10 (Nil Arguments)'.
                      failedCount := failedCount + 1].

        Transcript cr.
        Transcript show: '=== BENCHMARK RESULTS ==='; cr.
        Transcript show: 'Completed ', totalTests printString, ' tests.'; cr.

        failedCount = 0
            ifTrue: [
                Transcript show: 'All tests passed!'; cr.
                ObjectMemory quit: 0
            ]
            ifFalse: [
                Transcript show: 'Tests that failed (', failedCount printString, '):'; cr.
                failedTests do: [:t | Transcript show: ' - ', t; cr].
                ObjectMemory quit: 1
            ]
    ]
]

Tests new runAll.
