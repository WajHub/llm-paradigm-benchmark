import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
public class SpatialLogicImpl extends SpatialLogic {
    @Override
public Polygon createPolygon(int numVertices, String name) {
    return new Polygon(numVertices, name);
}

@Override
public SpatialLayer createLayer(String name) {
    return new SpatialLayer(name);
}

@Override
public Polygon calculateCleanMinkowskiSum(Polygon poly1, Polygon poly2) {
    if (poly1 == null || poly2 == null || poly1.numVertices == 0 || poly2.numVertices == 0) {
        return new Polygon(0, "");
    }

    // Ensure polygons are convex and vertices are ordered CCW for the algorithm to work correctly.
    // The problem states inputs are convex polygons. We assume standard CCW ordering or handle it.
    // Minkowski Sum of two convex polygons is convex.
    
    List<Point> sumPoints = new ArrayList<>();
    
    // Find the vertex with the lowest y (and leftmost x if tie) for each polygon to start the merge
    int idx1 = findLowestVertex(poly1);
    int idx2 = findLowestVertex(poly2);
    
    int n1 = poly1.numVertices;
    int n2 = poly2.numVertices;
    
    int i = 0;
    int j = 0;
    
    // We will traverse the edges of both polygons in angular order.
    // Since they are convex, we can merge their edge vectors sorted by angle.
    
    List<Point> edges1 = getEdgeVectors(poly1, idx1);
    List<Point> edges2 = getEdgeVectors(poly2, idx2);
    
    // Current point is sum of starting vertices
    double cx = poly1.vertices[idx1].x + poly2.vertices[idx2].x;
    double cy = poly1.vertices[idx1].y + poly2.vertices[idx2].y;
    
    sumPoints.add(new Point(cx, cy));
    
    int p1 = 0;
    int p2 = 0;
    
    while (p1 < n1 && p2 < n2) {
        Point e1 = edges1.get(p1);
        Point e2 = edges2.get(p2);
        
        double cross = crossProduct(e1, e2);
        
        if (cross >= 0) {
            cx += e1.x;
            cy += e1.y;
            sumPoints.add(new Point(cx, cy));
            p1++;
        } 
        if (cross <= 0) {
            cx += e2.x;
            cy += e2.y;
            sumPoints.add(new Point(cx, cy));
            p2++;
        }
    }
    
    while (p1 < n1) {
        Point e1 = edges1.get(p1);
        cx += e1.x;
        cy += e1.y;
        sumPoints.add(new Point(cx, cy));
        p1++;
    }
    
    while (p2 < n2) {
        Point e2 = edges2.get(p2);
        cx += e2.x;
        cy += e2.y;
        sumPoints.add(new Point(cx, cy));
        p2++;
    }
    
    // The last point should be the same as the first point (closed loop). Remove duplicate.
    if (sumPoints.size() > 1) {
        Point first = sumPoints.get(0);
        Point last = sumPoints.get(sumPoints.size() - 1);
        if (Math.abs(first.x - last.x) < 1e-9 && Math.abs(first.y - last.y) < 1e-9) {
            sumPoints.remove(sumPoints.size() - 1);
        }
    }
    
    // Clean collinear points
    List<Point> cleaned = removeCollinearPoints(sumPoints);
    
    // Construct result polygon
    Polygon result = new Polygon(cleaned.size(), "");
    result.isConvex = true;
    for (int k = 0; k < cleaned.size(); k++) {
        result.vertices[k] = new Point(cleaned.get(k));
    }
    result.numVertices = cleaned.size();
    
    return result;
}

@Override
public boolean checkDynamicCollision(Polygon obstacle, Polygon robot, Point velocity) {
    if (obstacle == null || robot == null || velocity == null) {
        return false;
    }
    
    // Configuration Space Obstacle (CSO) = Minkowski Sum of Obstacle and (-Robot)
    // To compute -Robot, we negate all vertices of the robot.
    
    Polygon negRobot = negatePolygon(robot);
    
    // Calculate Minkowski Sum: Obstacle + (-Robot)
    Polygon cso = calculateCleanMinkowskiSum(obstacle, negRobot);
    
    if (cso.numVertices == 0) {
        return false;
    }
    
    // The robot's reference point (usually origin or centroid, but here we assume the translation applies to the whole shape)
    // moves from (0,0) to velocity.
    // We need to check if the line segment from (0,0) to velocity intersects the CSO.
    // Or more precisely, if the origin is inside the CSO expanded by the sweep?
    // Standard approach: The swept volume of the robot relative to the obstacle is the Minkowski Sum of the CSO and the segment [0, velocity].
    // Collision occurs if the Origin (0,0) is contained in this swept volume?
    // Actually, simpler: Check if the segment from StartPos to EndPos intersects the CSO.
    // Assuming robot starts at position P and moves by V. Relative to obstacle, Robot moves by V.
    // In Config Space, the point representing Robot's position moves from InitialConfig to InitialConfig + V.
    // Usually, we define the CSO such that if the Robot's reference point is inside the CSO, they collide.
    // So we check if the segment connecting the initial reference point (let's assume 0,0 relative to itself for simplicity of the 'relative' movement logic) 
    // Wait, the standard formulation:
    // Let A be obstacle, B be robot.
    // Collision exists if (A + (-B)) intersects the path of the reference point.
    // If the robot moves by velocity V, the reference point moves along segment S from P_start to P_start + V.
    // However, the problem doesn't specify a start position. It implies checking if *any* intersection happens along the linear path defined by velocity.
    // Typically, this implies checking if the segment from (0,0) to velocity intersects the CSO, assuming the "current" position is the origin of the configuration space?
    // Or does it mean the robot is currently at some position and we want to know if moving by `velocity` causes a crash?
    // Without a start position, we usually assume the check is for the sweep relative to the current configuration being "touching" or "about to touch".
    // But a common interpretation in these specific coding challenges is:
    // Does the segment from (0,0) to `velocity` intersect the CSO? 
    // OR: Is the origin inside the CSO? (Static collision).
    // If the origin is inside the CSO, they are already colliding.
    // If not, does the ray/segment from origin in direction of velocity enter the CSO?
    
    // Let's assume the question implies: The robot is currently at a position such that its reference point is at the origin of the CSO? 
    // No, that would mean static collision.
    // Let's look at the arguments: `obstacle`, `robot`, `velocity`.
    // If the robot is far away, velocity doesn't matter unless it's huge.
    // Usually, `checkDynamicCollision` in this context assumes the robot is at a specific starting position relative to the obstacle.
    // Since no start position is given, it's highly likely that the "Robot" and "Obstacle" are defined in the same coordinate system, 
    // and we are checking if the translation of the Robot by `velocity` causes an intersection.
    // This is equivalent to: Does the segment from `0` to `velocity` intersect the CSO (where CSO = Obstacle (+) (-Robot))?
    // Wait, if the robot is at position P, the config space point is P.
    // If we don't have P, we can't solve it generally.
    // HOWEVER, often in these simplified problems, the "Robot" polygon is defined around its local origin, and the "Obstacle" is in world space.
    // And the "Velocity" is the displacement.
    // If the start position isn't provided, there might be an implicit assumption that we are checking if the *swept shape* of the robot (from 0 to V) intersects the obstacle.
    // Swept Shape = Minkowski Sum(Robot, Segment(0, V)).
    // Intersection(SweptShape, Obstacle) != empty.
    // This is equivalent to: Intersection(Robot, Obstacle (+) Segment(0, -V)) != empty?
    // Or: Distance(Obstacle, Robot) <= projection?
    
    // Let's stick to the most robust interpretation of "Configuration Space Approach":
    // 1. Compute CSO = Obstacle (+) (-Robot).
    // 2. The robot's reference point travels along a path. If the start position is not given, 
    //    it is impossible to determine collision unless we assume the start position is the Origin (0,0) in the CSO frame?
    //    If the start position is (0,0), then we check if Segment((0,0), Velocity) intersects CSO.
    
    // Let's implement: Check if Segment(Point(0,0), Velocity) intersects Polygon CSO.
    // Also check if (0,0) is inside CSO (static collision at start).
    
    Point start = new Point(0, 0);
    Point end = new Point(velocity.x, velocity.y);
    
    // 1. Check if start point is inside CSO
    if (isPointInPolygon(start, cso)) {
        return true;
    }
    
    // 2. Check if any edge of CSO intersects the segment (start, end)
    for (int i = 0; i < cso.numVertices; i++) {
        Point v1 = cso.vertices[i];
        Point v2 = cso.vertices[(i + 1) % cso.numVertices];
        
        if (segmentsIntersect(start, end, v1, v2)) {
            return true;
        }
    }
    
    return false;
}

// Helper methods

private int findLowestVertex(Polygon poly) {
    int idx = 0;
    for (int i = 1; i < poly.numVertices; i++) {
        if (poly.vertices[i].y < poly.vertices[idx].y ||
            (poly.vertices[i].y == poly.vertices[idx].y && poly.vertices[i].x < poly.vertices[idx].x)) {
            idx = i;
        }
    }
    return idx;
}

private List<Point> getEdgeVectors(Polygon poly, int startIdx) {
    List<Point> edges = new ArrayList<>();
    int n = poly.numVertices;
    for (int i = 0; i < n; i++) {
        Point curr = poly.vertices[(startIdx + i) % n];
        Point next = poly.vertices[(startIdx + i + 1) % n];
        edges.add(new Point(next.x - curr.x, next.y - curr.y));
    }
    return edges;
}

private double crossProduct(Point a, Point b) {
    return a.x * b.y - a.y * b.x;
}

private List<Point> removeCollinearPoints(List<Point> points) {
    if (points.size() <= 3) {
        return points;
    }
    
    List<Point> result = new ArrayList<>();
    int n = points.size();
    
    for (int i = 0; i < n; i++) {
        Point prev = points.get((i - 1 + n) % n);
        Point curr = points.get(i);
        Point next = points.get((i + 1) % n);
        
        // Vector prev->curr
        double dx1 = curr.x - prev.x;
        double dy1 = curr.y - prev.y;
        
        // Vector curr->next
        double dx2 = next.x - curr.x;
        double dy2 = next.y - curr.y;
        
        // Cross product
        double cross = dx1 * dy2 - dy1 * dx2;
        
        // If cross product is not zero (with tolerance), keep curr
        if (Math.abs(cross) > 1e-9) {
            result.add(curr);
        }
    }
    
    // Handle case where all points are collinear (shouldn't happen for valid convex polygons with area > 0)
    if (result.isEmpty()) {
         // Return original if degenerate? Or just first 2? 
         // For a convex polygon, if all are collinear, it's a line segment or point.
         // The Minkowski sum of degenerate polygons is degenerate.
         // Let's return the first point to be safe, or the original list.
         // Given "strictly extreme points", a line segment has 2 extreme points.
         // This logic is complex for degenerate cases. Assuming non-degenerate convex polygons.
         return points; 
    }
    
    return result;
}

private Polygon negatePolygon(Polygon poly) {
    Polygon neg = new Polygon(poly.numVertices, "");
    neg.numVertices = poly.numVertices;
    neg.isConvex = poly.isConvex;
    // Negate vertices and reverse order to maintain CCW if original was CCW?
    // If original is CCW, negating coordinates reflects across origin. Order becomes CW.
    // We need CCW for Minkowski sum algorithm.
    // So we fill in reverse order.
    for (int i = 0; i < poly.numVertices; i++) {
        Point p = poly.vertices[i];
        neg.vertices[poly.numVertices - 1 - i] = new Point(-p.x, -p.y);
    }
    return neg;
}

private boolean isPointInPolygon(Point p, Polygon poly) {
    // Ray casting algorithm
    boolean inside = false;
    int n = poly.numVertices;
    if (n == 0) return false;
    
    for (int i = 0, j = n - 1; i < n; j = i++) {
        double xi = poly.vertices[i].x, yi = poly.vertices[i].y;
        double xj = poly.vertices[j].x, yj = poly.vertices[j].y;
        
        boolean intersect = ((yi > p.y) != (yj > p.y))
                && (p.x < (xj - xi) * (p.y - yi) / (yj - yi) + xi);
        if (intersect) inside = !inside;
    }
    return inside;
}

private boolean segmentsIntersect(Point p1, Point p2, Point q1, Point q2) {
    double d1 = crossProductDirection(q1, q2, p1);
    double d2 = crossProductDirection(q1, q2, p2);
    double d3 = crossProductDirection(p1, p2, q1);
    double d4 = crossProductDirection(p1, p2, q2);
    
    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
        return true;
    }
    
    // Check collinear cases
    if (Math.abs(d1) < 1e-9 && onSegment(q1, q2, p1)) return true;
    if (Math.abs(d2) < 1e-9 && onSegment(q1, q2, p2)) return true;
    if (Math.abs(d3) < 1e-9 && onSegment(p1, p2, q1)) return true;
    if (Math.abs(d4) < 1e-9 && onSegment(p1, p2, q2)) return true;
    
    return false;
}

private double crossProductDirection(Point a, Point b, Point c) {
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
}

private boolean onSegment(Point a, Point b, Point c) {
    // Check if c lies on segment ab
    if (Math.min(a.x, b.x) <= c.x + 1e-9 && c.x <= Math.max(a.x, b.x) + 1e-9 &&
        Math.min(a.y, b.y) <= c.y + 1e-9 && c.y <= Math.max(a.y, b.y) + 1e-9) {
        return true;
    }
    return false;
}
}