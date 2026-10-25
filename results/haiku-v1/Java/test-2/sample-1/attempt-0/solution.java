import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Deque;
import java.util.List;
import java.util.PriorityQueue;

public final class ShortestPathImpl extends ShortestPath {

    private static final class QueueEntry {
        private final int vertex;
        private final double distance;

        private QueueEntry(int vertex, double distance) {
            this.vertex = vertex;
            this.distance = distance;
        }
    }

    public ShortestPathImpl() {
        super();
    }

    @Override
    public Graph createGraph(int numVertices) {
        return new Graph(numVertices);
    }

    @Override
    public void addEdge(Graph graph, int from, int to, double weight) {
        if (graph == null) {
            throw new IllegalArgumentException("Graph must not be null");
        }
        if (from < 0 || from >= graph.numVertices) {
            throw new IllegalArgumentException("Invalid 'from' vertex: " + from);
        }
        if (to < 0 || to >= graph.numVertices) {
            throw new IllegalArgumentException("Invalid 'to' vertex: " + to);
        }
        if (Double.isNaN(weight) || weight < 0) {
            throw new IllegalArgumentException("Edge weight must be non-negative: " + weight);
        }
        graph.adjacency.get(from).add(new Edge(to, weight));
    }

    @Override
    public PathResult dijkstra(Graph graph, int source) {
        if (graph == null || source < 0 || source >= graph.numVertices) {
            return null;
        }

        int n = graph.numVertices;
        PathResult result = new PathResult(n, source);
        Arrays.fill(result.distances, Double.POSITIVE_INFINITY);
        Arrays.fill(result.predecessors, -1);
        result.distances[source] = 0.0;

        PriorityQueue<QueueEntry> queue = new PriorityQueue<>(
                (a, b) -> Double.compare(a.distance, b.distance));
        queue.offer(new QueueEntry(source, 0.0));

        while (!queue.isEmpty()) {
            QueueEntry current = queue.poll();
            int u = current.vertex;

            if (current.distance > result.distances[u]) {
                continue;
            }

            for (Edge edge : graph.adjacency.get(u)) {
                int v = edge.to;
                double candidate = result.distances[u] + edge.weight;
                if (candidate < result.distances[v]) {
                    result.distances[v] = candidate;
                    result.predecessors[v] = u;
                    queue.offer(new QueueEntry(v, candidate));
                }
            }
        }

        return result;
    }

    @Override
    public double getShortestDistance(PathResult result, int target) {
        if (result == null || result.distances == null
                || target < 0 || target >= result.distances.length) {
            return Double.POSITIVE_INFINITY;
        }
        return result.distances[target];
    }

    @Override
    public int[] reconstructPath(PathResult result, int target) {
        if (result == null || result.distances == null || result.predecessors == null
                || target < 0 || target >= result.distances.length
                || target >= result.predecessors.length) {
            return null;
        }
        if (Double.isInfinite(result.distances[target])) {
            return null;
        }

        Deque<Integer> path = new ArrayDeque<>();
        int current = target;
        int steps = 0;
        int limit = result.predecessors.length;

        while (current != -1) {
            if (steps++ > limit) {
                return null;
            }
            path.addFirst(current);
            if (current == result.source) {
                break;
            }
            current = result.predecessors[current];
        }

        if (path.isEmpty() || path.peekFirst() != result.source) {
            return null;
        }

        List<Integer> list = new ArrayList<>(path);
        int[] output = new int[list.size()];
        for (int i = 0; i < output.length; i++) {
            output[i] = list.get(i);
        }
        return output;
    }
}
