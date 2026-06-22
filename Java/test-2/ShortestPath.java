import java.util.List;
import java.util.ArrayList;

public abstract class ShortestPath {
    protected ShortestPath() {}

    public static final class Edge {
        public int to;
        public double weight;
        public Edge(int to, double weight) { this.to = to; this.weight = weight; }
    }

    public static final class Graph {
        public List<List<Edge>> adjacency;
        public int numVertices;
        public Graph(int numVertices) {
            this.numVertices = Math.max(numVertices, 0);
            this.adjacency = new ArrayList<>();
            for (int i = 0; i < this.numVertices; i++)
                this.adjacency.add(new ArrayList<>());
        }
    }

    public static final class PathResult {
        public double[] distances;
        public int[] predecessors;
        public int source;
        public PathResult(int numVertices, int source) {
            this.distances = new double[numVertices];
            this.predecessors = new int[numVertices];
            this.source = source;
        }
    }

    public abstract Graph createGraph(int numVertices);
    public abstract void addEdge(Graph graph, int from, int to, double weight);
    public abstract PathResult dijkstra(Graph graph, int source);
    public abstract double getShortestDistance(PathResult result, int target);
    public abstract int[] reconstructPath(PathResult result, int target);
}
