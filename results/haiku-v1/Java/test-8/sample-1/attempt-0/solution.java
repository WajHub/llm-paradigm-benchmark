import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class TspApproxImpl extends TspApprox {

    @Override
    public int mstWeight(int[][] points) {
        if (points == null || points.length <= 1) {
            return 0;
        }
        return SpanningTree.of(points).weight;
    }

    @Override
    public TourResult doubleTree(int[][] points) {
        if (points == null || points.length == 0) {
            return null;
        }
        SpanningTree tree = SpanningTree.of(points);
        List<Integer> order = new ArrayList<>(points.length);
        tree.preorder(0, -1, order);
        int[] tour = order.stream().mapToInt(Integer::intValue).toArray();
        return new TourResult(tour, tourCost(points, tour));
    }

    @Override
    public int matchingWeight(int[][] points) {
        if (points == null || points.length <= 1) {
            return 0;
        }
        SpanningTree tree = SpanningTree.of(points);
        int[] odd = tree.oddDegreeVertices();
        return new MinMatching(points, odd).minCost();
    }

    @Override
    public TourResult christofides(int[][] points) {
        if (points == null || points.length == 0) {
            return null;
        }
        int n = points.length;
        if (n == 1) {
            return new TourResult(new int[] {0}, 0);
        }

        SpanningTree tree = SpanningTree.of(points);
        int[] odd = tree.oddDegreeVertices();
        List<int[]> multiEdges = new ArrayList<>(tree.edges);
        multiEdges.addAll(new MinMatching(points, odd).pairs());

        List<Integer> circuit = EulerCircuit.find(n, multiEdges, 0);

        boolean[] seen = new boolean[n];
        int[] tour = new int[n];
        int idx = 0;
        for (int v : circuit) {
            if (!seen[v]) {
                seen[v] = true;
                tour[idx++] = v;
            }
        }
        return new TourResult(tour, tourCost(points, tour));
    }

    private static int dist(int[] p, int[] q) {
        return Math.abs(p[0] - q[0]) + Math.abs(p[1] - q[1]);
    }

    private static int tourCost(int[][] points, int[] tour) {
        int n = tour.length;
        int cost = 0;
        for (int i = 0; i < n; i++) {
            cost += dist(points[tour[i]], points[tour[(i + 1) % n]]);
        }
        return cost;
    }

    /** Minimum spanning tree built by Prim's algorithm started from vertex 0. */
    private static final class SpanningTree {
        final int n;
        final List<int[]> edges = new ArrayList<>();
        final List<List<Integer>> adj = new ArrayList<>();
        final int[] degree;
        int weight;

        private SpanningTree(int n) {
            this.n = n;
            this.degree = new int[n];
            for (int i = 0; i < n; i++) {
                adj.add(new ArrayList<>());
            }
        }

        static SpanningTree of(int[][] pts) {
            int n = pts.length;
            SpanningTree t = new SpanningTree(n);
            if (n <= 1) {
                return t;
            }
            boolean[] inTree = new boolean[n];
            int[] key = new int[n];
            inTree[0] = true;
            for (int v = 1; v < n; v++) {
                key[v] = dist(pts[0], pts[v]);
            }
            for (int step = 1; step < n; step++) {
                int v = -1;
                for (int c = 0; c < n; c++) {
                    if (!inTree[c] && (v == -1 || key[c] < key[v])) {
                        v = c;
                    }
                }
                int parent = -1;
                for (int u = 0; u < n; u++) {
                    if (inTree[u] && dist(pts[u], pts[v]) == key[v]) {
                        parent = u;
                        break;
                    }
                }
                t.addEdge(parent, v);
                t.weight += key[v];
                inTree[v] = true;
                for (int w = 0; w < n; w++) {
                    if (!inTree[w]) {
                        int d = dist(pts[v], pts[w]);
                        if (d < key[w]) {
                            key[w] = d;
                        }
                    }
                }
            }
            for (List<Integer> list : t.adj) {
                Collections.sort(list);
            }
            return t;
        }

        private void addEdge(int u, int v) {
            edges.add(new int[] {u, v});
            adj.get(u).add(v);
            adj.get(v).add(u);
            degree[u]++;
            degree[v]++;
        }

        int[] oddDegreeVertices() {
            return java.util.stream.IntStream.range(0, n)
                    .filter(i -> degree[i] % 2 == 1)
                    .toArray();
        }

        void preorder(int v, int parent, List<Integer> order) {
            order.add(v);
            for (int u : adj.get(v)) {
                if (u != parent) {
                    preorder(u, v, order);
                }
            }
        }
    }

    /** Exact minimum-weight perfect matching over a small vertex set via bitmask DP. */
    private static final class MinMatching {
        private final int[][] pts;
        private final int[] odd;
        private final int full;
        private final int[] memo;

        MinMatching(int[][] pts, int[] odd) {
            this.pts = pts;
            this.odd = odd;
            this.full = (1 << odd.length) - 1;
            this.memo = new int[1 << odd.length];
            Arrays.fill(memo, -1);
        }

        int minCost() {
            return solve(0);
        }

        List<int[]> pairs() {
            List<int[]> result = new ArrayList<>();
            int mask = 0;
            while (mask != full) {
                int i = Integer.numberOfTrailingZeros(~mask);
                int current = solve(mask);
                boolean found = false;
                for (int j = i + 1; j < odd.length && !found; j++) {
                    if ((mask & (1 << j)) != 0) {
                        continue;
                    }
                    int next = mask | (1 << i) | (1 << j);
                    int c = dist(pts[odd[i]], pts[odd[j]]);
                    if (c + solve(next) == current) {
                        result.add(new int[] {odd[i], odd[j]});
                        mask = next;
                        found = true;
                    }
                }
            }
            return result;
        }

        /** Minimum cost to pair all vertices not contained in mask. */
        private int solve(int mask) {
            if (mask == full) {
                return 0;
            }
            if (memo[mask] >= 0) {
                return memo[mask];
            }
            int i = Integer.numberOfTrailingZeros(~mask);
            int best = Integer.MAX_VALUE;
            for (int j = i + 1; j < odd.length; j++) {
                if ((mask & (1 << j)) != 0) {
                    continue;
                }
                int c = dist(pts[odd[i]], pts[odd[j]]) + solve(mask | (1 << i) | (1 << j));
                if (c < best) {
                    best = c;
                }
            }
            memo[mask] = best;
            return best;
        }
    }

    /** Hierholzer's algorithm on a multigraph given as an edge list. */
    private static final class EulerCircuit {
        static List<Integer> find(int n, List<int[]> edges, int start) {
            List<List<Integer>> incident = new ArrayList<>(n);
            for (int i = 0; i < n; i++) {
                incident.add(new ArrayList<>());
            }
            for (int e = 0; e < edges.size(); e++) {
                int[] ed = edges.get(e);
                incident.get(ed[0]).add(e);
                incident.get(ed[1]).add(e);
            }
            boolean[] used = new boolean[edges.size()];
            int[] ptr = new int[n];
            List<Integer> circuit = new ArrayList<>();
            List<Integer> stack = new ArrayList<>();
            stack.add(start);
            while (!stack.isEmpty()) {
                int v = stack.get(stack.size() - 1);
                List<Integer> inc = incident.get(v);
                while (ptr[v] < inc.size() && used[inc.get(ptr[v])]) {
                    ptr[v]++;
                }
                if (ptr[v] < inc.size()) {
                    int e = inc.get(ptr[v]);
                    used[e] = true;
                    int[] ed = edges.get(e);
                    int other = ed[0] == v ? ed[1] : ed[0];
                    stack.add(other);
                } else {
                    circuit.add(stack.remove(stack.size() - 1));
                }
            }
            Collections.reverse(circuit);
            return circuit;
        }
    }
}
