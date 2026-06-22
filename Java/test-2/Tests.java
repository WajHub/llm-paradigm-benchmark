import java.util.Arrays;

public final class Tests {
    private static final ShortestPath SP = new ShortestPathImpl();

    private Tests() {
    }

    private static boolean distanceIs(double actual, double expected) {
        if (Double.isInfinite(expected)) {
            return Double.isInfinite(actual) && actual > 0;
        }
        return Math.abs(actual - expected) < 1e-9;
    }

    private static boolean checkDistance(ShortestPath.PathResult result, int target, double expected) {
        return distanceIs(SP.getShortestDistance(result, target), expected);
    }

    private static ShortestPath.Graph createLinearChain(int numVertices, double weight) {
        ShortestPath.Graph graph = SP.createGraph(numVertices);
        for (int i = 0; i < numVertices - 1; i++) {
            SP.addEdge(graph, i, i + 1, weight);
        }
        return graph;
    }

    private static boolean testAlgoA01LinearChain() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 1, 2, 2.0);
            SP.addEdge(graph, 2, 3, 3.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            boolean passed = true;
            if (!checkDistance(result, 0, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 1, 1.0)) {
                passed = false;
            }
            if (!checkDistance(result, 2, 3.0)) {
                passed = false;
            }
            if (!checkDistance(result, 3, 6.0)) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA02Diamond() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 0, 2, 4.0);
            SP.addEdge(graph, 1, 3, 6.0);
            SP.addEdge(graph, 2, 3, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            boolean passed = true;
            if (!checkDistance(result, 0, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 1, 1.0)) {
                passed = false;
            }
            if (!checkDistance(result, 2, 4.0)) {
                passed = false;
            }
            if (!checkDistance(result, 3, 5.0)) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA03Disconnected() {
        try {
            ShortestPath.Graph graph = SP.createGraph(5);
            SP.addEdge(graph, 0, 1, 2.0);
            SP.addEdge(graph, 1, 2, 3.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            boolean passed = true;
            if (!checkDistance(result, 0, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 1, 2.0)) {
                passed = false;
            }
            if (!checkDistance(result, 2, 5.0)) {
                passed = false;
            }
            if (!checkDistance(result, 3, Double.POSITIVE_INFINITY)) {
                passed = false;
            }
            if (!checkDistance(result, 4, Double.POSITIVE_INFINITY)) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA04SingleVertex() {
        try {
            ShortestPath.Graph graph = SP.createGraph(1);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            return checkDistance(result, 0, 0.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA05ParallelEdges() {
        try {
            ShortestPath.Graph graph = SP.createGraph(2);
            SP.addEdge(graph, 0, 1, 5.0);
            SP.addEdge(graph, 0, 1, 2.0);
            SP.addEdge(graph, 0, 1, 8.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            return checkDistance(result, 1, 2.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA06ZeroWeightEdges() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 0.0);
            SP.addEdge(graph, 1, 2, 0.0);
            SP.addEdge(graph, 2, 3, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            boolean passed = true;
            if (!checkDistance(result, 1, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 2, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 3, 1.0)) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA07NullGraph() {
        try {
            ShortestPath.PathResult result = SP.dijkstra(null, 0);
            return result == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA08InvalidSource() {
        try {
            ShortestPath.Graph graph = SP.createGraph(3);

            ShortestPath.PathResult resultHigh = SP.dijkstra(graph, 5);
            ShortestPath.PathResult resultLow = SP.dijkstra(graph, -1);

            return resultHigh == null && resultLow == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA09ComplexGraph() {
        try {
            ShortestPath.Graph graph = SP.createGraph(6);
            SP.addEdge(graph, 0, 1, 7.0);
            SP.addEdge(graph, 0, 2, 9.0);
            SP.addEdge(graph, 0, 5, 14.0);
            SP.addEdge(graph, 1, 2, 10.0);
            SP.addEdge(graph, 1, 3, 15.0);
            SP.addEdge(graph, 2, 3, 11.0);
            SP.addEdge(graph, 2, 5, 2.0);
            SP.addEdge(graph, 3, 4, 6.0);
            SP.addEdge(graph, 4, 5, 9.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            boolean passed = true;
            if (!checkDistance(result, 0, 0.0)) {
                passed = false;
            }
            if (!checkDistance(result, 1, 7.0)) {
                passed = false;
            }
            if (!checkDistance(result, 2, 9.0)) {
                passed = false;
            }
            if (!checkDistance(result, 3, 20.0)) {
                passed = false;
            }
            if (!checkDistance(result, 4, 26.0)) {
                passed = false;
            }
            if (!checkDistance(result, 5, 11.0)) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoA10Stress() {
        try {
            final int numVertices = 1000;
            ShortestPath.Graph graph = createLinearChain(numVertices, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            return checkDistance(result, 999, 999.0);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB01SimplePath() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 1, 2, 2.0);
            SP.addEdge(graph, 2, 3, 3.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 3);
            int[] expected = {0, 1, 2, 3};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB02DiamondPath() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 0, 2, 4.0);
            SP.addEdge(graph, 1, 3, 6.0);
            SP.addEdge(graph, 2, 3, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 3);
            int[] expected = {0, 2, 3};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB03SelfPath() {
        try {
            ShortestPath.Graph graph = SP.createGraph(3);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 1, 2, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 0);
            int[] expected = {0};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB04Unreachable() {
        try {
            ShortestPath.Graph graph = SP.createGraph(5);
            SP.addEdge(graph, 0, 1, 2.0);
            SP.addEdge(graph, 1, 2, 3.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 4);
            return path == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB05LongChain() {
        try {
            final int numVertices = 10;
            ShortestPath.Graph graph = createLinearChain(numVertices, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 9);
            int[] expected = new int[numVertices];
            for (int i = 0; i < numVertices; i++) {
                expected[i] = i;
            }
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB06Cycle() {
        try {
            ShortestPath.Graph graph = SP.createGraph(4);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 1, 2, 1.0);
            SP.addEdge(graph, 2, 0, 1.0);
            SP.addEdge(graph, 1, 3, 2.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 3);
            int[] expected = {0, 1, 3};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB07Star() {
        try {
            ShortestPath.Graph graph = SP.createGraph(5);
            SP.addEdge(graph, 0, 1, 2.0);
            SP.addEdge(graph, 0, 2, 3.0);
            SP.addEdge(graph, 0, 3, 1.0);
            SP.addEdge(graph, 0, 4, 5.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 3);
            int[] expected = {0, 3};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB08NullResult() {
        try {
            int[] path = SP.reconstructPath(null, 0);
            return path == null;
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB09Bidirectional() {
        try {
            ShortestPath.Graph graph = SP.createGraph(3);
            SP.addEdge(graph, 0, 1, 1.0);
            SP.addEdge(graph, 1, 0, 10.0);
            SP.addEdge(graph, 1, 2, 1.0);
            SP.addEdge(graph, 0, 2, 5.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 2);
            int[] expected = {0, 1, 2};
            return Arrays.equals(path, expected);
        } catch (Exception e) {
            return false;
        }
    }

    private static boolean testAlgoB10StressPath() {
        try {
            final int numVertices = 1000;
            ShortestPath.Graph graph = createLinearChain(numVertices, 1.0);

            ShortestPath.PathResult result = SP.dijkstra(graph, 0);
            if (result == null) {
                return false;
            }

            int[] path = SP.reconstructPath(result, 999);
            if (path == null) {
                return false;
            }

            boolean passed = true;
            if (path.length != numVertices) {
                passed = false;
            }
            if (path[0] != 0) {
                passed = false;
            }
            if (path[numVertices - 1] != 999) {
                passed = false;
            }
            return passed;
        } catch (Exception e) {
            return false;
        }
    }

    public static void main(String[] args) {
        int failedCount = 0;
        String[] failedTests = new String[50];
        int totalTests = 0;

        System.out.println("=== START ===");
        System.out.println();
        System.out.println("--- Algorithm A: Shortest Distances ---");
        totalTests++;
        if (testAlgoA01LinearChain()) {
            System.out.println("[PASS] Test A01 (Linear Chain)");
        } else {
            System.out.println("[FAIL] Test A01 (Linear Chain)");
            failedTests[failedCount++] = "Test A01 (Linear Chain)";
        }
        totalTests++;
        if (testAlgoA02Diamond()) {
            System.out.println("[PASS] Test A02 (Diamond)");
        } else {
            System.out.println("[FAIL] Test A02 (Diamond)");
            failedTests[failedCount++] = "Test A02 (Diamond)";
        }
        totalTests++;
        if (testAlgoA03Disconnected()) {
            System.out.println("[PASS] Test A03 (Disconnected)");
        } else {
            System.out.println("[FAIL] Test A03 (Disconnected)");
            failedTests[failedCount++] = "Test A03 (Disconnected)";
        }
        totalTests++;
        if (testAlgoA04SingleVertex()) {
            System.out.println("[PASS] Test A04 (Single Vertex)");
        } else {
            System.out.println("[FAIL] Test A04 (Single Vertex)");
            failedTests[failedCount++] = "Test A04 (Single Vertex)";
        }
        totalTests++;
        if (testAlgoA05ParallelEdges()) {
            System.out.println("[PASS] Test A05 (Parallel Edges)");
        } else {
            System.out.println("[FAIL] Test A05 (Parallel Edges)");
            failedTests[failedCount++] = "Test A05 (Parallel Edges)";
        }
        totalTests++;
        if (testAlgoA06ZeroWeightEdges()) {
            System.out.println("[PASS] Test A06 (Zero-Weight Edges)");
        } else {
            System.out.println("[FAIL] Test A06 (Zero-Weight Edges)");
            failedTests[failedCount++] = "Test A06 (Zero-Weight Edges)";
        }
        totalTests++;
        if (testAlgoA07NullGraph()) {
            System.out.println("[PASS] Test A07 (Null Graph)");
        } else {
            System.out.println("[FAIL] Test A07 (Null Graph)");
            failedTests[failedCount++] = "Test A07 (Null Graph)";
        }
        totalTests++;
        if (testAlgoA08InvalidSource()) {
            System.out.println("[PASS] Test A08 (Invalid Source)");
        } else {
            System.out.println("[FAIL] Test A08 (Invalid Source)");
            failedTests[failedCount++] = "Test A08 (Invalid Source)";
        }
        totalTests++;
        if (testAlgoA09ComplexGraph()) {
            System.out.println("[PASS] Test A09 (Complex Graph)");
        } else {
            System.out.println("[FAIL] Test A09 (Complex Graph)");
            failedTests[failedCount++] = "Test A09 (Complex Graph)";
        }
        totalTests++;
        if (testAlgoA10Stress()) {
            System.out.println("[PASS] Test A10 (Stress 1000-Chain)");
        } else {
            System.out.println("[FAIL] Test A10 (Stress 1000-Chain)");
            failedTests[failedCount++] = "Test A10 (Stress 1000-Chain)";
        }

        System.out.println();
        System.out.println("--- Algorithm B: Path Reconstruction ---");
        totalTests++;
        if (testAlgoB01SimplePath()) {
            System.out.println("[PASS] Test B01 (Simple Path)");
        } else {
            System.out.println("[FAIL] Test B01 (Simple Path)");
            failedTests[failedCount++] = "Test B01 (Simple Path)";
        }
        totalTests++;
        if (testAlgoB02DiamondPath()) {
            System.out.println("[PASS] Test B02 (Diamond Path)");
        } else {
            System.out.println("[FAIL] Test B02 (Diamond Path)");
            failedTests[failedCount++] = "Test B02 (Diamond Path)";
        }
        totalTests++;
        if (testAlgoB03SelfPath()) {
            System.out.println("[PASS] Test B03 (Self Path)");
        } else {
            System.out.println("[FAIL] Test B03 (Self Path)");
            failedTests[failedCount++] = "Test B03 (Self Path)";
        }
        totalTests++;
        if (testAlgoB04Unreachable()) {
            System.out.println("[PASS] Test B04 (Unreachable)");
        } else {
            System.out.println("[FAIL] Test B04 (Unreachable)");
            failedTests[failedCount++] = "Test B04 (Unreachable)";
        }
        totalTests++;
        if (testAlgoB05LongChain()) {
            System.out.println("[PASS] Test B05 (Long Chain)");
        } else {
            System.out.println("[FAIL] Test B05 (Long Chain)");
            failedTests[failedCount++] = "Test B05 (Long Chain)";
        }
        totalTests++;
        if (testAlgoB06Cycle()) {
            System.out.println("[PASS] Test B06 (Cycle)");
        } else {
            System.out.println("[FAIL] Test B06 (Cycle)");
            failedTests[failedCount++] = "Test B06 (Cycle)";
        }
        totalTests++;
        if (testAlgoB07Star()) {
            System.out.println("[PASS] Test B07 (Star)");
        } else {
            System.out.println("[FAIL] Test B07 (Star)");
            failedTests[failedCount++] = "Test B07 (Star)";
        }
        totalTests++;
        if (testAlgoB08NullResult()) {
            System.out.println("[PASS] Test B08 (Null Result)");
        } else {
            System.out.println("[FAIL] Test B08 (Null Result)");
            failedTests[failedCount++] = "Test B08 (Null Result)";
        }
        totalTests++;
        if (testAlgoB09Bidirectional()) {
            System.out.println("[PASS] Test B09 (Bidirectional)");
        } else {
            System.out.println("[FAIL] Test B09 (Bidirectional)");
            failedTests[failedCount++] = "Test B09 (Bidirectional)";
        }
        totalTests++;
        if (testAlgoB10StressPath()) {
            System.out.println("[PASS] Test B10 (Stress Path 1000-Chain)");
        } else {
            System.out.println("[FAIL] Test B10 (Stress Path 1000-Chain)");
            failedTests[failedCount++] = "Test B10 (Stress Path 1000-Chain)";
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
