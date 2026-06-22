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