import java.util.List;

public abstract class BTree {
    protected BTree() {}

    public static final class Node {
        public final List<Integer> keys;      // strictly ascending
        public final List<Node> children;     // empty for a leaf, otherwise keys.size() + 1 entries
        public Node(List<Integer> keys, List<Node> children) {
            this.keys = keys;
            this.children = children;
        }
    }

    public abstract Node insertAll(int t, int[] keys);
    public abstract Node deleteAll(int t, int[] keys, int[] deletions);
}
