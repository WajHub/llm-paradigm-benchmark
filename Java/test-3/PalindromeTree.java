public abstract class PalindromeTree {
    protected PalindromeTree() {
    }

    public static final int EERTREE_ALPHA = 26;

    public static final class Node {
        public int len;
        public int suffixLink;
        public int[] children;
        public long cnt;
        public int endPos;

        public Node() {
            this.children = new int[EERTREE_ALPHA];
        }
    }

    public static final class Eertree {
        public Node[] nodes;
        public int size;
        public int capacity;
        public int last;
        public String str;
        public int strLen;
    }

    public abstract Eertree eertreeBuild(String s, int len);

    public abstract int eertreeCountDistinct(Eertree t);

    public abstract long eertreeCountOccurrences(Eertree t, String pattern, int plen);

    public abstract int eertreeLongestLength(Eertree t);
}
