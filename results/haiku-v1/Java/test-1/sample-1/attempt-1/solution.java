The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public final class SpatialLogicImpl extends SpatialLogic {

    private static final double EPS = 1e-9;

    public SpatialLogicImpl() {
        super();
    }

    @Override
    public Polygon calculateCleanMinkowskiSum(Polygon poly1, Polygon poly2) {
        if (poly1 == null || poly2 == null) {
            return null;
        }
        List<Point> a = extractVertices(poly1);
        List<Point> b = extractVertices(poly2);
        if (a.isEmpty() || b.isEmpty()) {
            return createPolygon(0, "");
        }

        List<Point> sums = new ArrayList<>(a.size() * b.size());
        for (Point p : a) {
            for (Point q : b) {
                sums.add(new Point(p.x + q.x, p.y + q.y));
            }
        }

        List<Point> hull = convexHull(sums);
        String name = "minkowski(" + poly1.zoneName + "," + poly2.zoneName + ")";
        Polygon result = createPolygon(hull.size(), name);
        for (int i = 0; i < hull.size(); i++) {
            result.vertices[i] = new Point(hull.get(i));
        }
        result.numVertices = hull.size();
        result.isConvex = true;
        return result;
    }

    @Override
    public boolean checkDynamicCollision(Polygon obstacle, Polygon robot, Point velocity) {
        if (obstacle == null || robot == null || velocity == null) {
            return false;
        }
        List<Point> obs = extractVertices(obstacle);
        List<Point> rob = extractVertices(robot);
        if (obs.isEmpty() || rob.isEmpty()) {
            return false;
        }

        List<Point> cspPoints = new ArrayList<>(obs.size() * rob.size());
        for (Point o : obs) {
            for (Point r : rob) {
                cspPoints.add(new Point(o.x - r.x, o.y - r.y));
            }
        }
        List<Point> csp = convexHull(cspPoints);

        Point origin = new Point(0.0, 0.0);
        Point end = new Point(velocity.x, velocity.y);

        if (csp.size() >= 3) {
            if (containsInclusive(csp, origin) || containsInclusive(csp, end)) {
                return true;
            }
        }

        if (csp.size() == 1) {
            Point p = csp.get(0);
            return segmentsIntersect(origin, end, p, p);
        }
        if (csp.size() == 2) {
            return segmentsIntersect(origin, end, csp.get(0), csp.get(1));
        }

        int n = csp.size();
        for (int i = 0; i < n; i++) {
            Point q1 = csp.get(i);
            Point q2 = csp.get((i + 1) % n);
            if (segmentsIntersect(origin, end, q1, q2)) {
                return true;
            }
        }
        return false;
    }

    @Override
    public Polygon createPolygon(int numVertices, String name) {
        return new Polygon(numVertices, name);
    }

    @Override
    public SpatialLayer createLayer(String name) {
        return new SpatialLayer(name);
    }

    private static List<Point> extractVertices(Polygon poly) {
        List<Point> result = new ArrayList<>();
        if (poly == null || poly.vertices == null) {
            return result;
        }
        int count = Math.min(Math.max(poly.numVertices, 0), poly.vertices.length);
        for (int i = 0; i < count; i++) {
            Point p = poly.vertices[i];
            if (p != null) {
                result.add(new Point(p.x, p.y));
            }
        }
        return result;
    }

    private static List<Point> convexHull(List<Point> input) {
        List<Point> pts = new ArrayList<>(input);
        pts.sort(Comparator.comparingDouble((Point p) -> p.x).thenComparingDouble(p -> p.y));

        List<Point> unique = new ArrayList<>(pts.size());
        for (Point p : pts) {
            if (unique.isEmpty()) {
                unique.add(p);
            } else {
                Point last = unique.get(unique.size() - 1);
                if (Math.abs(last.x - p.x) > EPS || Math.abs(last.y - p.y) > EPS) {
                    unique.add(p);
                }
            }
        }

        int n = unique.size();
        if (n <= 1) {
            return unique;
        }

        Point[] h = new Point[2 * n];
        int k = 0;
        for (int i = 0; i < n; i++) {
            Point p = unique.get(i);
            while (k >= 2 && cross(h[k - 2], h[k - 1], p) <= EPS) {
                k--;
            }
            h[k++] = p;
        }
        int lowerSize = k + 1;
        for (int i = n - 2; i >= 0; i--) {
            Point p = unique.get(i);
            while (k >= lowerSize && cross(h[k - 2], h[k - 1], p) <= EPS) {
                k--;
            }
            h[k++] = p;
        }
        return new ArrayList<>(Arrays.asList(h).subList(0, k - 1));
    }

    private static double cross(Point o, Point a, Point b) {
        return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
    }

    private static boolean containsInclusive(List<Point> ccwHull, Point p) {
        int n = ccwHull.size();
        for (int i = 0; i < n; i++) {
            Point a = ccwHull.get(i);
            Point b = ccwHull.get((i + 1) % n);
            if (cross(a, b, p) < -EPS) {
                return false;
            }
        }
        return true;
    }

    private static boolean segmentsIntersect(Point p1, Point p2, Point q1, Point q2) {
        double d1 = orient(q1, q2, p1);
        double d2 = orient(q1, q2, p2);
        double d3 = orient(p1, p2, q1);
        double d4 = orient(p1, p2, q2);

        if (((d1 > EPS && d2 < -EPS) || (d1 < -EPS && d2 > EPS))
                && ((d3 > EPS && d4 < -EPS) || (d3 < -EPS && d4 > EPS))) {
            return true;
        }
        if (Math.abs(d1) <= EPS && onSegment(q1, q2, p1)) return true;
        if (Math.abs(d2) <= EPS && onSegment(q1, q2, p2)) return true;
        if (Math.abs(d3) <= EPS && onSegment(p1, p2, q1)) return true;
        if (Math.abs(d4) <= EPS && onSegment(p1, p2, q2)) return true;
        return false;
    }

    private static double orient(Point a, Point b, Point c) {
        return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    }

    private static boolean onSegment(Point a, Point b, Point c) {
        return c.x >= Math.min(a.x, b.x) - EPS && c.x <= Math.max(a.x, b.x) + EPS
                && c.y >= Math.min(a.y, b.y) - EPS && c.y <= Math.max(a.y, b.y) + EPS;
    }
}
