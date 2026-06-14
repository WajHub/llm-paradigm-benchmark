public final class Tests {
    private static final SpatialLogic LOGIC = new SpatialLogicImpl();

    private Tests() {
    }

    private static boolean containsPoint(SpatialLogic.Polygon polygon, double x, double y) {
        if (polygon == null || polygon.vertices == null) {
            return false;
        }
        for (int i = 0; i < polygon.numVertices; i++) {
            if (Math.abs(polygon.vertices[i].x - x) < 0.001 && Math.abs(polygon.vertices[i].y - y) < 0.001) {
                return true;
            }
        }
        return false;
    }

    private static boolean testAlgoA01BasicSquares() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(4, "Z1");
        poly1.vertices[0] = new SpatialLogic.Point(0, 0);
        poly1.vertices[1] = new SpatialLogic.Point(2, 0);
        poly1.vertices[2] = new SpatialLogic.Point(2, 2);
        poly1.vertices[3] = new SpatialLogic.Point(0, 2);
        poly1.numVertices = 4;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(4, "Z2");
        poly2.vertices[0] = new SpatialLogic.Point(0, 0);
        poly2.vertices[1] = new SpatialLogic.Point(2, 0);
        poly2.vertices[2] = new SpatialLogic.Point(2, 2);
        poly2.vertices[3] = new SpatialLogic.Point(0, 2);
        poly2.numVertices = 4;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 4) {
            passed = false;
        }
        if (!containsPoint(result, 0, 0)) {
            passed = false;
        }
        if (!containsPoint(result, 4, 0)) {
            passed = false;
        }
        if (!containsPoint(result, 4, 4)) {
            passed = false;
        }
        if (!containsPoint(result, 0, 4)) {
            passed = false;
        }
        return passed;
    }

    private static boolean testAlgoA02PointAndPolygon() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(1, "Point");
        poly1.vertices[0] = new SpatialLogic.Point(5, 5);
        poly1.numVertices = 1;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(3, "Triangle");
        poly2.vertices[0] = new SpatialLogic.Point(0, 0);
        poly2.vertices[1] = new SpatialLogic.Point(1, 0);
        poly2.vertices[2] = new SpatialLogic.Point(0, 1);
        poly2.numVertices = 3;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 3) {
            passed = false;
        }
        if (!containsPoint(result, 5, 5)) {
            passed = false;
        }
        if (!containsPoint(result, 6, 5)) {
            passed = false;
        }
        if (!containsPoint(result, 5, 6)) {
            passed = false;
        }
        return passed;
    }

    private static boolean testAlgoA03CollinearSimplification() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(3, "Tri1");
        poly1.vertices[0] = new SpatialLogic.Point(0, 0);
        poly1.vertices[1] = new SpatialLogic.Point(2, 0);
        poly1.vertices[2] = new SpatialLogic.Point(0, 2);
        poly1.numVertices = 3;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(3, "Tri2");
        poly2.vertices[0] = new SpatialLogic.Point(0, 0);
        poly2.vertices[1] = new SpatialLogic.Point(2, 0);
        poly2.vertices[2] = new SpatialLogic.Point(0, 2);
        poly2.numVertices = 3;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 3) {
            passed = false;
        }
        if (!containsPoint(result, 0, 0)) {
            passed = false;
        }
        if (!containsPoint(result, 4, 0)) {
            passed = false;
        }
        if (!containsPoint(result, 0, 4)) {
            passed = false;
        }
        return passed;
    }

    private static boolean testAlgoA04NegativeCoordinates() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(4, "NegSq");
        poly1.vertices[0] = new SpatialLogic.Point(-5, -5);
        poly1.vertices[1] = new SpatialLogic.Point(-3, -5);
        poly1.vertices[2] = new SpatialLogic.Point(-3, -3);
        poly1.vertices[3] = new SpatialLogic.Point(-5, -3);
        poly1.numVertices = 4;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(4, "PosSq");
        poly2.vertices[0] = new SpatialLogic.Point(1, 1);
        poly2.vertices[1] = new SpatialLogic.Point(2, 1);
        poly2.vertices[2] = new SpatialLogic.Point(2, 2);
        poly2.vertices[3] = new SpatialLogic.Point(1, 2);
        poly2.numVertices = 4;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 4) {
            passed = false;
        }
        if (!containsPoint(result, -4, -4)) {
            passed = false;
        }
        if (!containsPoint(result, -1, -1)) {
            passed = false;
        }
        return passed;
    }

    private static boolean testAlgoA05SinglePoints() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(1, "Pt1");
        poly1.vertices[0] = new SpatialLogic.Point(-2.5, 3.5);
        poly1.numVertices = 1;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(1, "Pt2");
        poly2.vertices[0] = new SpatialLogic.Point(2.5, -3.5);
        poly2.numVertices = 1;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 1) {
            passed = false;
        }
        if (!containsPoint(result, 0.0, 0.0)) {
            passed = false;
        }
        return passed;
    }

    private static boolean testAlgoA06EmptyFirstPolygon() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(0, "Empty");
        poly1.vertices = null;
        poly1.numVertices = 0;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(2, "Line");
        poly2.vertices[0] = new SpatialLogic.Point(0, 0);
        poly2.vertices[1] = new SpatialLogic.Point(1, 1);
        poly2.numVertices = 2;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = result.numVertices == 0;
        return passed;
    }

    private static boolean testAlgoA07EmptySecondPolygon() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(2, "Line");
        poly1.vertices[0] = new SpatialLogic.Point(0, 0);
        poly1.vertices[1] = new SpatialLogic.Point(1, 1);
        poly1.numVertices = 2;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(0, "Empty");
        poly2.vertices = null;
        poly2.numVertices = 0;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = result.numVertices == 0;
        return passed;
    }

    private static boolean testAlgoA08NullArguments() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(1, "Pt");
        poly1.vertices[0] = new SpatialLogic.Point(0, 0);
        poly1.numVertices = 1;
        poly1.isConvex = true;

        SpatialLogic.Polygon result1 = LOGIC.calculateCleanMinkowskiSum(null, poly1);
        SpatialLogic.Polygon result2 = LOGIC.calculateCleanMinkowskiSum(poly1, null);
        SpatialLogic.Polygon result3 = LOGIC.calculateCleanMinkowskiSum(null, null);

        return result1 == null && result2 == null && result3 == null;
    }

    private static boolean testAlgoA09FlatPolygon() {
        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(2, "Line1");
        poly1.vertices[0] = new SpatialLogic.Point(0, 0);
        poly1.vertices[1] = new SpatialLogic.Point(2, 0);
        poly1.numVertices = 2;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(2, "Line2");
        poly2.vertices[0] = new SpatialLogic.Point(0, 0);
        poly2.vertices[1] = new SpatialLogic.Point(3, 0);
        poly2.numVertices = 2;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        if (result == null) {
            return false;
        }

        boolean passed = true;
        if (result.numVertices != 2) {
            passed = false;
        }
        if (!containsPoint(result, 0, 0)) {
            passed = false;
        }
        if (!containsPoint(result, 5, 0)) {
            passed = false;
        }

        return passed;
    }

    private static boolean testAlgoA10StressTest() {
        int size = 500;
        SpatialLogic.Point[] largeArr = new SpatialLogic.Point[size];
        for (int i = 0; i < size; i++) {
            largeArr[i] = new SpatialLogic.Point(Math.cos(2.0 * Math.PI * i / size), Math.sin(2.0 * Math.PI * i / size));
        }

        SpatialLogic.Polygon poly1 = new SpatialLogic.Polygon(size, "Circle1");
        poly1.vertices = largeArr;
        poly1.numVertices = size;
        poly1.isConvex = true;

        SpatialLogic.Polygon poly2 = new SpatialLogic.Polygon(size, "Circle2");
        poly2.vertices = largeArr;
        poly2.numVertices = size;
        poly2.isConvex = true;

        SpatialLogic.Polygon result = LOGIC.calculateCleanMinkowskiSum(poly1, poly2);
        boolean passed;
        if (result == null) {
            passed = false;
        } else {
            passed = result.numVertices > 0;
        }

        return passed;
    }

    private static boolean testAlgoB01TunnelingCollision() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(5, 0);
        obstacle.vertices[1] = new SpatialLogic.Point(6, 0);
        obstacle.vertices[2] = new SpatialLogic.Point(6, 1);
        obstacle.vertices[3] = new SpatialLogic.Point(5, 1);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(10.0, 0.0);
        return LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB02ClearMiss() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(0, 5);
        obstacle.vertices[1] = new SpatialLogic.Point(1, 5);
        obstacle.vertices[2] = new SpatialLogic.Point(1, 6);
        obstacle.vertices[3] = new SpatialLogic.Point(0, 6);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(10.0, 0.0);
        return !LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB03StaticOverlap() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(2, 0);
        robot.vertices[2] = new SpatialLogic.Point(2, 2);
        robot.vertices[3] = new SpatialLogic.Point(0, 2);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(1, 1);
        obstacle.vertices[1] = new SpatialLogic.Point(3, 1);
        obstacle.vertices[2] = new SpatialLogic.Point(3, 3);
        obstacle.vertices[3] = new SpatialLogic.Point(1, 3);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(0.0, 0.0);
        return LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB04StaticMiss() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(10, 10);
        obstacle.vertices[1] = new SpatialLogic.Point(11, 10);
        obstacle.vertices[2] = new SpatialLogic.Point(11, 11);
        obstacle.vertices[3] = new SpatialLogic.Point(10, 11);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(0.0, 0.0);
        return !LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB05MovingAway() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(-5, 0);
        obstacle.vertices[1] = new SpatialLogic.Point(-4, 0);
        obstacle.vertices[2] = new SpatialLogic.Point(-4, 1);
        obstacle.vertices[3] = new SpatialLogic.Point(-5, 1);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(10.0, 0.0);
        return !LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB06DiagonalTunneling() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(5, 5);
        obstacle.vertices[1] = new SpatialLogic.Point(7, 5);
        obstacle.vertices[2] = new SpatialLogic.Point(7, 7);
        obstacle.vertices[3] = new SpatialLogic.Point(5, 7);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(10.0, 10.0);
        return LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB07EdgeGrazing() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(0, 0);
        robot.vertices[1] = new SpatialLogic.Point(1, 0);
        robot.vertices[2] = new SpatialLogic.Point(1, 1);
        robot.vertices[3] = new SpatialLogic.Point(0, 1);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(0, 1);
        obstacle.vertices[1] = new SpatialLogic.Point(1, 1);
        obstacle.vertices[2] = new SpatialLogic.Point(1, 2);
        obstacle.vertices[3] = new SpatialLogic.Point(0, 2);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(10.0, 0.0);
        return LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB08NegativeVelocity() {
        SpatialLogic.Polygon robot = new SpatialLogic.Polygon(4, "Robot");
        robot.vertices[0] = new SpatialLogic.Point(10, 10);
        robot.vertices[1] = new SpatialLogic.Point(11, 10);
        robot.vertices[2] = new SpatialLogic.Point(11, 11);
        robot.vertices[3] = new SpatialLogic.Point(10, 11);
        robot.numVertices = 4;
        robot.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(4, 4);
        obstacle.vertices[1] = new SpatialLogic.Point(6, 4);
        obstacle.vertices[2] = new SpatialLogic.Point(6, 6);
        obstacle.vertices[3] = new SpatialLogic.Point(4, 6);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(-10.0, -10.0);
        return LOGIC.checkDynamicCollision(obstacle, robot, velocity);
    }

    private static boolean testAlgoB09EmptyPolygons() {
        SpatialLogic.Polygon empty = new SpatialLogic.Polygon(0, "Empty");
        empty.vertices = null;
        empty.numVertices = 0;
        empty.isConvex = true;

        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(0, 0);
        obstacle.vertices[1] = new SpatialLogic.Point(1, 0);
        obstacle.vertices[2] = new SpatialLogic.Point(1, 1);
        obstacle.vertices[3] = new SpatialLogic.Point(0, 1);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(5.0, 5.0);

        boolean col1 = LOGIC.checkDynamicCollision(obstacle, empty, velocity);
        boolean col2 = LOGIC.checkDynamicCollision(empty, obstacle, velocity);

        return !col1 && !col2;
    }

    private static boolean testAlgoB10NullArguments() {
        SpatialLogic.Polygon obstacle = new SpatialLogic.Polygon(4, "Obstacle");
        obstacle.vertices[0] = new SpatialLogic.Point(0, 0);
        obstacle.vertices[1] = new SpatialLogic.Point(1, 0);
        obstacle.vertices[2] = new SpatialLogic.Point(1, 1);
        obstacle.vertices[3] = new SpatialLogic.Point(0, 1);
        obstacle.numVertices = 4;
        obstacle.isConvex = true;

        SpatialLogic.Point velocity = new SpatialLogic.Point(5.0, 5.0);

        boolean col1 = LOGIC.checkDynamicCollision(null, obstacle, velocity);
        boolean col2 = LOGIC.checkDynamicCollision(obstacle, null, velocity);
        boolean col3 = LOGIC.checkDynamicCollision(null, null, velocity);

        return !col1 && !col2 && !col3;
    }

    public static void main(String[] args) {
        int failedCount = 0;
        String[] failedTests = new String[50];
        int totalTests = 0;

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Clean Minkowski Sum (Convex Hull) ---");
        totalTests++;
        if (testAlgoA01BasicSquares()) {
            System.out.println("[PASS] Test A01 (Basic Squares Hull)");
        } else {
            System.out.println("[FAIL] Test A01 (Basic Squares Hull)");
            failedTests[failedCount++] = "Test A01 (Basic Squares Hull)";
        }
        totalTests++;
        if (testAlgoA02PointAndPolygon()) {
            System.out.println("[PASS] Test A02 (Point and Polygon)");
        } else {
            System.out.println("[FAIL] Test A02 (Point and Polygon)");
            failedTests[failedCount++] = "Test A02 (Point and Polygon)";
        }
        totalTests++;
        if (testAlgoA03CollinearSimplification()) {
            System.out.println("[PASS] Test A03 (Collinear Simplification)");
        } else {
            System.out.println("[FAIL] Test A03 (Collinear Simplification)");
            failedTests[failedCount++] = "Test A03 (Collinear Simplification)";
        }
        totalTests++;
        if (testAlgoA04NegativeCoordinates()) {
            System.out.println("[PASS] Test A04 (Negative Coordinates)");
        } else {
            System.out.println("[FAIL] Test A04 (Negative Coordinates)");
            failedTests[failedCount++] = "Test A04 (Negative Coordinates)";
        }
        totalTests++;
        if (testAlgoA05SinglePoints()) {
            System.out.println("[PASS] Test A05 (Single Points)");
        } else {
            System.out.println("[FAIL] Test A05 (Single Points)");
            failedTests[failedCount++] = "Test A05 (Single Points)";
        }
        totalTests++;
        if (testAlgoA06EmptyFirstPolygon()) {
            System.out.println("[PASS] Test A06 (Empty First Polygon)");
        } else {
            System.out.println("[FAIL] Test A06 (Empty First Polygon)");
            failedTests[failedCount++] = "Test A06 (Empty First Polygon)";
        }
        totalTests++;
        if (testAlgoA07EmptySecondPolygon()) {
            System.out.println("[PASS] Test A07 (Empty Second Polygon)");
        } else {
            System.out.println("[FAIL] Test A07 (Empty Second Polygon)");
            failedTests[failedCount++] = "Test A07 (Empty Second Polygon)";
        }
        totalTests++;
        if (testAlgoA08NullArguments()) {
            System.out.println("[PASS] Test A08 (Null Arguments)");
        } else {
            System.out.println("[FAIL] Test A08 (Null Arguments)");
            failedTests[failedCount++] = "Test A08 (Null Arguments)";
        }
        totalTests++;
        if (testAlgoA09FlatPolygon()) {
            System.out.println("[PASS] Test A09 (Flat Polygons / Lines)");
        } else {
            System.out.println("[FAIL] Test A09 (Flat Polygons / Lines)");
            failedTests[failedCount++] = "Test A09 (Flat Polygons / Lines)";
        }
        totalTests++;
        if (testAlgoA10StressTest()) {
            System.out.println("[PASS] Test A10 (Stress Test 500x500)");
        } else {
            System.out.println("[FAIL] Test A10 (Stress Test 500x500)");
            failedTests[failedCount++] = "Test A10 (Stress Test 500x500)";
        }

        System.out.println();
        System.out.println("--- Algorithm B: Dynamic Collision Detection ---");
        totalTests++;
        if (testAlgoB01TunnelingCollision()) {
            System.out.println("[PASS] Test B01 (Tunneling Collision)");
        } else {
            System.out.println("[FAIL] Test B01 (Tunneling Collision)");
            failedTests[failedCount++] = "Test B01 (Tunneling Collision)";
        }
        totalTests++;
        if (testAlgoB02ClearMiss()) {
            System.out.println("[PASS] Test B02 (Clear Miss)");
        } else {
            System.out.println("[FAIL] Test B02 (Clear Miss)");
            failedTests[failedCount++] = "Test B02 (Clear Miss)";
        }
        totalTests++;
        if (testAlgoB03StaticOverlap()) {
            System.out.println("[PASS] Test B03 (Static Overlap)");
        } else {
            System.out.println("[FAIL] Test B03 (Static Overlap)");
            failedTests[failedCount++] = "Test B03 (Static Overlap)";
        }
        totalTests++;
        if (testAlgoB04StaticMiss()) {
            System.out.println("[PASS] Test B04 (Static Miss)");
        } else {
            System.out.println("[FAIL] Test B04 (Static Miss)");
            failedTests[failedCount++] = "Test B04 (Static Miss)";
        }
        totalTests++;
        if (testAlgoB05MovingAway()) {
            System.out.println("[PASS] Test B05 (Moving Away)");
        } else {
            System.out.println("[FAIL] Test B05 (Moving Away)");
            failedTests[failedCount++] = "Test B05 (Moving Away)";
        }
        totalTests++;
        if (testAlgoB06DiagonalTunneling()) {
            System.out.println("[PASS] Test B06 (Diagonal Tunneling)");
        } else {
            System.out.println("[FAIL] Test B06 (Diagonal Tunneling)");
            failedTests[failedCount++] = "Test B06 (Diagonal Tunneling)";
        }
        totalTests++;
        if (testAlgoB07EdgeGrazing()) {
            System.out.println("[PASS] Test B07 (Edge Grazing)");
        } else {
            System.out.println("[FAIL] Test B07 (Edge Grazing)");
            failedTests[failedCount++] = "Test B07 (Edge Grazing)";
        }
        totalTests++;
        if (testAlgoB08NegativeVelocity()) {
            System.out.println("[PASS] Test B08 (Negative Velocity)");
        } else {
            System.out.println("[FAIL] Test B08 (Negative Velocity)");
            failedTests[failedCount++] = "Test B08 (Negative Velocity)";
        }
        totalTests++;
        if (testAlgoB09EmptyPolygons()) {
            System.out.println("[PASS] Test B09 (Empty Polygons)");
        } else {
            System.out.println("[FAIL] Test B09 (Empty Polygons)");
            failedTests[failedCount++] = "Test B09 (Empty Polygons)";
        }
        totalTests++;
        if (testAlgoB10NullArguments()) {
            System.out.println("[PASS] Test B10 (NULL Arguments)");
        } else {
            System.out.println("[FAIL] Test B10 (NULL Arguments)");
            failedTests[failedCount++] = "Test B10 (NULL Arguments)";
        }

        System.out.println();
        System.out.println("=== BENCHMARK RESULTS ===");
        System.out.println("Completed " + totalTests + " tests.");

        if (failedCount == 0) {
            System.out.println("All tests passed!");
            System.exit(0);
        }

        System.out.println("Tests that failed (" + failedCount + "):");
        for (int i = 0; i < failedCount; i++) {
            System.out.println(" - " + failedTests[i]);
        }
        System.exit(1);
    }
}