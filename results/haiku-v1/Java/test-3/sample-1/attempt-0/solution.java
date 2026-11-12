import java.util.Arrays;

public final class PalindromeTreeImpl extends PalindromeTree {

    public PalindromeTreeImpl() {
        super();
    }

    @Override
    public Eertree eertreeBuild(String s, int len) {
        if (s == null) {
            if (len > 0) {
                return null;
            }
            s = "";
        }
        int n = Math.max(0, Math.min(len, s.length()));

        Eertree t = new Eertree();
        t.capacity = n + 2;
        t.nodes = new Node[t.capacity];
        t.str = s.substring(0, n);
        t.strLen = n;

        Node oddRoot = new Node();
        oddRoot.len = -1;
        oddRoot.suffixLink = 0;
        t.nodes[0] = oddRoot;

        Node evenRoot = new Node();
        evenRoot.len = 0;
        evenRoot.suffixLink = 0;
        t.nodes[1] = evenRoot;

        t.size = 2;
        t.last = 1;

        for (int i = 0; i < n; i++) {
            addCharacter(t, i);
        }

        propagateCounts(t, n);
        return t;
    }

    private static void addCharacter(Eertree t, int i) {
        int c = charIndex(t.str.charAt(i));
        int cur = getLink(t, t.last, i);

        if (t.nodes[cur].children[c] == 0) {
            int w = t.size++;
            Node node = new Node();
            node.len = t.nodes[cur].len + 2;
            node.endPos = i;

            if (node.len == 1) {
                node.suffixLink = 1;
            } else {
                int p = getLink(t, t.nodes[cur].suffixLink, i);
                node.suffixLink = t.nodes[p].children[c];
            }

            t.nodes[w] = node;
            t.nodes[cur].children[c] = w;
            t.last = w;
        } else {
            t.last = t.nodes[cur].children[c];
        }

        t.nodes[t.last].cnt++;
    }

    private static int getLink(Eertree t, int v, int i) {
        while (true) {
            int l = t.nodes[v].len;
            int j = i - 1 - l;
            if (j >= 0 && t.str.charAt(j) == t.str.charAt(i)) {
                return v;
            }
            v = t.nodes[v].suffixLink;
        }
    }

    private static int charIndex(char ch) {
        if (ch < 'a' || ch > 'z') {
            throw new IllegalArgumentException("Only lowercase Latin letters are allowed: " + ch);
        }
        return ch - 'a';
    }

    private static void propagateCounts(Eertree t, int n) {
        int realCount = t.size - 2;
        if (realCount <= 0) {
            return;
        }

        // Counting sort of real nodes by len, descending.
        int[] freq = new int[n + 2];
        for (int v = 2; v < t.size; v++) {
            freq[t.nodes[v].len]++;
        }
        int[] start = new int[n + 2];
        int pos = 0;
        for (int L = n; L >= 0; L--) {
            start[L] = pos;
            pos += freq[L];
        }
        int[] order = new int[realCount];
        for (int v = 2; v < t.size; v++) {
            order[start[t.nodes[v].len]++] = v;
        }

        for (int idx = 0; idx < realCount; idx++) {
            int v = order[idx];
            t.nodes[t.nodes[v].suffixLink].cnt += t.nodes[v].cnt;
        }
    }

    @Override
    public int eertreeCountDistinct(Eertree t) {
        if (t == null || t.nodes == null) {
            return 0;
        }
        return Math.max(0, t.size - 2);
    }

    @Override
    public long eertreeCountOccurrences(Eertree t, String pattern, int plen) {
        if (t == null || t.nodes == null || pattern == null || t.str == null) {
            return 0;
        }
        if (plen <= 0 || plen > pattern.length()) {
            return 0;
        }
        String p = pattern.substring(0, plen);
        if (!isPalindrome(p)) {
            return 0;
        }
        for (int v = 2; v < t.size; v++) {
            Node node = t.nodes[v];
            if (node.len == plen) {
                int start = node.endPos - plen + 1;
                if (start >= 0 && t.str.regionMatches(start, p, 0, plen)) {
                    return node.cnt;
                }
            }
        }
        return 0;
    }

    @Override
    public int eertreeLongestLength(Eertree t) {
        if (t == null || t.nodes == null) {
            return 0;
        }
        int best = 0;
        for (int v = 2; v < t.size; v++) {
            best = Math.max(best, t.nodes[v].len);
        }
        return best;
    }

    private static boolean isPalindrome(String s) {
        int i = 0;
        int j = s.length() - 1;
        while (i < j) {
            if (s.charAt(i) != s.charAt(j)) {
                return false;
            }
            i++;
            j--;
        }
        return true;
    }
}
