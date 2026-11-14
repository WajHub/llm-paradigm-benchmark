import java.util.ArrayList;
import java.util.List;

public final class BTreeImpl extends BTree {

    @Override
    public Node insertAll(int t, int[] keys) {
        if (t < 2) {
            return null;
        }
        Node root = emptyRoot();
        for (int k : keys) {
            root = insert(root, t, k);
        }
        return root;
    }

    @Override
    public Node deleteAll(int t, int[] keys, int[] deletions) {
        if (t < 2) {
            return null;
        }
        Node root = insertAll(t, keys);
        for (int k : deletions) {
            if (!contains(root, k)) {
                continue;
            }
            deleteFrom(root, t, k);
            if (root.keys.isEmpty() && !root.children.isEmpty()) {
                root = root.children.get(0);
            }
        }
        return root;
    }

    private static Node emptyRoot() {
        return new Node(new ArrayList<>(), new ArrayList<>());
    }

    private static boolean isLeaf(Node n) {
        return n.children.isEmpty();
    }

    private static boolean isFull(Node n, int t) {
        return n.keys.size() == 2 * t - 1;
    }

    private static int lowerBound(List<Integer> keys, int k) {
        int i = 0;
        while (i < keys.size() && keys.get(i) < k) {
            i++;
        }
        return i;
    }

    private static boolean contains(Node root, int k) {
        Node x = root;
        while (true) {
            int i = lowerBound(x.keys, k);
            if (i < x.keys.size() && x.keys.get(i) == k) {
                return true;
            }
            if (isLeaf(x)) {
                return false;
            }
            x = x.children.get(i);
        }
    }

    private static Node insert(Node root, int t, int k) {
        if (contains(root, k)) {
            return root;
        }
        if (isFull(root, t)) {
            List<Node> kids = new ArrayList<>();
            kids.add(root);
            root = new Node(new ArrayList<>(), kids);
            splitChild(t, root, 0);
        }
        Node x = root;
        while (true) {
            if (isLeaf(x)) {
                x.keys.add(lowerBound(x.keys, k), k);
                return root;
            }
            int i = lowerBound(x.keys, k);
            if (isFull(x.children.get(i), t)) {
                splitChild(t, x, i);
                if (k > x.keys.get(i)) {
                    i++;
                }
            }
            x = x.children.get(i);
        }
    }

    private static void splitChild(int t, Node x, int i) {
        Node y = x.children.get(i);
        Node z = new Node(new ArrayList<>(), new ArrayList<>());
        int median = y.keys.get(t - 1);
        z.keys.addAll(y.keys.subList(t, 2 * t - 1));
        y.keys.subList(t - 1, y.keys.size()).clear();
        if (!isLeaf(y)) {
            z.children.addAll(y.children.subList(t, 2 * t));
            y.children.subList(t, y.children.size()).clear();
        }
        x.keys.add(i, median);
        x.children.add(i + 1, z);
    }

    private static void deleteFrom(Node x, int t, int k) {
        int i = lowerBound(x.keys, k);
        if (i < x.keys.size() && x.keys.get(i) == k) {
            if (isLeaf(x)) {
                x.keys.remove(i);
                return;
            }
            Node y = x.children.get(i);
            Node z = x.children.get(i + 1);
            if (y.keys.size() >= t) {
                int pred = maxKey(y);
                deleteFrom(y, t, pred);
                x.keys.set(i, pred);
            } else if (z.keys.size() >= t) {
                int succ = minKey(z);
                deleteFrom(z, t, succ);
                x.keys.set(i, succ);
            } else {
                y.keys.add(k);
                y.keys.addAll(z.keys);
                y.children.addAll(z.children);
                x.keys.remove(i);
                x.children.remove(i + 1);
                deleteFrom(y, t, k);
            }
            return;
        }

        Node c = x.children.get(i);
        if (c.keys.size() == t - 1) {
            boolean hasLeft = i > 0;
            boolean hasRight = i < x.children.size() - 1;
            if (hasLeft && x.children.get(i - 1).keys.size() >= t) {
                Node left = x.children.get(i - 1);
                c.keys.add(0, x.keys.get(i - 1));
                x.keys.set(i - 1, left.keys.remove(left.keys.size() - 1));
                if (!isLeaf(left)) {
                    c.children.add(0, left.children.remove(left.children.size() - 1));
                }
            } else if (hasRight && x.children.get(i + 1).keys.size() >= t) {
                Node right = x.children.get(i + 1);
                c.keys.add(x.keys.get(i));
                x.keys.set(i, right.keys.remove(0));
                if (!isLeaf(right)) {
                    c.children.add(right.children.remove(0));
                }
            } else if (hasRight) {
                Node right = x.children.get(i + 1);
                c.keys.add(x.keys.remove(i));
                c.keys.addAll(right.keys);
                c.children.addAll(right.children);
                x.children.remove(i + 1);
            } else {
                Node left = x.children.get(i - 1);
                left.keys.add(x.keys.remove(i - 1));
                left.keys.addAll(c.keys);
                left.children.addAll(c.children);
                x.children.remove(i);
                c = left;
            }
        }
        deleteFrom(c, t, k);
    }

    private static int maxKey(Node n) {
        Node x = n;
        while (!isLeaf(x)) {
            x = x.children.get(x.children.size() - 1);
        }
        return x.keys.get(x.keys.size() - 1);
    }

    private static int minKey(Node n) {
        Node x = n;
        while (!isLeaf(x)) {
            x = x.children.get(0);
        }
        return x.keys.get(0);
    }
}
