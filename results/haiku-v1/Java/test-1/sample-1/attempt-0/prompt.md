You are a Java programming expert. Your task is to implement the required methods in accordance with the provided class or interface.

- Implement `calculateCleanMinkowskiSum`: calculate the Minkowski sum of two convex polygons and return a new polygon representing only the convex hull of the resulting point cloud. The returned polygon must contain strictly extreme points only, with collinear edge points removed, ordered counter-clockwise.
- Implement `checkDynamicCollision`: determine whether a moving robot polygon intersects a stationary obstacle polygon at any point along a linear path defined by the velocity vector. Use the Minkowski sum configuration-space approach to prevent tunneling.
- Implement `createPolygon` and `createLayer`: allocate the required objects and safely copy the provided names into the corresponding fields.
- Use object-oriented Java and model the domain with classes.
- Keep the contract in `SpatialLogic.java`, the concrete solution will live in `SpatialLogicImpl.java`.
- Return only raw Java code.

General Requirements:
- Use idiomatic Java.
- Use object-oriented design and model the domain with classes.
- Prefer standard library collections and utilities where appropriate.
- Return ONLY raw Java code (no Markdown tags, no ```java blocks, no side text). Your code will be directly saved to a .java file and compiled. Do not provide a main() method or test code.

public abstract class SpatialLogic {
    protected SpatialLogic() {
    }

    public static final class Point {
        public double x;
        public double y;

        public Point(double x, double y) {
            this.x = x;
            this.y = y;
        }

        public Point(Point other) {
            this(other.x, other.y);
        }
    }

    public static final class Polygon {
        public Point[] vertices;
        public int numVertices;
        public boolean isConvex;
        public String zoneName;

        public Polygon(int numVertices, String name) {
            this.vertices = numVertices > 0 ? new Point[numVertices] : new Point[0];
            this.numVertices = Math.max(numVertices, 0);
            this.isConvex = false;
            this.zoneName = name == null ? "" : name;
        }
    }

    public static final class SpatialLayer {
        public Polygon[] polygons;
        public int polygonCount;
        public String layerName;

        public SpatialLayer(String name) {
            this.polygons = new Polygon[0];
            this.polygonCount = 0;
            this.layerName = name == null ? "" : name;
        }
    }

    public abstract Polygon calculateCleanMinkowskiSum(Polygon poly1, Polygon poly2);

    public abstract boolean checkDynamicCollision(Polygon obstacle, Polygon robot, Point velocity);

    public abstract Polygon createPolygon(int numVertices, String name);

    public abstract SpatialLayer createLayer(String name);
}