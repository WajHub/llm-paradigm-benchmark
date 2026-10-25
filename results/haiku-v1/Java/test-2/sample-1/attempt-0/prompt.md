You are a Java programming expert. Your task is to implement the required methods in accordance with the provided class or interface.

- Implement `createGraph`: Create a directed weighted graph with the given number of vertices (0-indexed).
- Implement `addEdge`: Add a directed edge from vertex `from` to vertex `to` with the given non-negative weight. Support multiple edges between the same pair.
- Implement `dijkstra`: Run Dijkstra's algorithm from the given source vertex. Return a PathResult with shortest distances and predecessor array. Unreachable vertices must have distance Double.POSITIVE_INFINITY. Return null if graph is null or source out of bounds.
- Implement `getShortestDistance`: Return shortest distance to target. Return Double.POSITIVE_INFINITY if target out of bounds or result is null.
- Implement `reconstructPath`: Return int[] of vertex indices from source to target. Return null if unreachable, out of bounds, or result is null.
- Use a priority queue for O((V+E) log V) time complexity.
- Keep the contract in `ShortestPath.java`, the concrete solution in `ShortestPathImpl.java`.
- Return only raw Java code.

General Requirements:
- Use idiomatic Java.
- Use object-oriented design and model the domain with classes.
- Prefer standard library collections and utilities where appropriate.
- Return ONLY raw Java code (no Markdown tags, no ```java blocks, no side text). Your code will be directly saved to a .java file and compiled. Do not provide a main() method or test code.

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