public class ShortestPathImpl extends ShortestPath {
    @Override
    public Graph createGraph(int numVertices) {
        throw new UnsupportedOperationException("createGraph not implemented");
    }

    @Override
    public void addEdge(Graph graph, int from, int to, double weight) {
        throw new UnsupportedOperationException("addEdge not implemented");
    }

    @Override
    public PathResult dijkstra(Graph graph, int source) {
        throw new UnsupportedOperationException("dijkstra not implemented");
    }

    @Override
    public double getShortestDistance(PathResult result, int target) {
        throw new UnsupportedOperationException("getShortestDistance not implemented");
    }

    @Override
    public int[] reconstructPath(PathResult result, int target) {
        throw new UnsupportedOperationException("reconstructPath not implemented");
    }
}
