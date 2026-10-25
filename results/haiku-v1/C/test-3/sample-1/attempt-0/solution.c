#include "palindrome_tree.h"
#include <stdlib.h>
#include <string.h>

static int eertree_get_link(const Eertree* t, int cur, int i)
{
    const char* s = t->str;
    while (1) {
        int l = t->nodes[cur].len;
        int p = i - l - 1;
        if (p >= 0 && s[p] == s[i])
            return cur;
        cur = t->nodes[cur].suffix_link;
    }
}

Eertree* eertree_build(const char* s, int len)
{
    if (s == NULL || len < 0)
        return NULL;

    for (int k = 0; k < len; k++) {
        if (s[k] < 'a' || s[k] > 'z')
            return NULL;
    }

    Eertree* t = (Eertree*)calloc(1, sizeof(Eertree));
    if (t == NULL)
        return NULL;

    t->capacity = len + 3;
    t->nodes = (EertreeNode*)calloc((size_t)t->capacity, sizeof(EertreeNode));
    t->str = (char*)malloc((size_t)len + 1);
    if (t->nodes == NULL || t->str == NULL) {
        free(t->nodes);
        free(t->str);
        free(t);
        return NULL;
    }

    memcpy(t->str, s, (size_t)len);
    t->str[len] = '\0';
    t->str_len = len;

    /* imaginary roots */
    t->nodes[0].len = -1;
    t->nodes[0].suffix_link = 0;
    t->nodes[1].len = 0;
    t->nodes[1].suffix_link = 0;
    t->size = 2;
    t->last = 1;

    for (int i = 0; i < len; i++) {
        int c = s[i] - 'a';
        int cur = eertree_get_link(t, t->last, i);

        if (t->nodes[cur].children[c] != 0) {
            t->last = t->nodes[cur].children[c];
        } else {
            int idx = t->size++;
            t->nodes[idx].len = t->nodes[cur].len + 2;
            t->nodes[idx].end_pos = i;

            if (t->nodes[idx].len == 1) {
                t->nodes[idx].suffix_link = 1;
            } else {
                int w = eertree_get_link(t, t->nodes[cur].suffix_link, i);
                t->nodes[idx].suffix_link = t->nodes[w].children[c];
            }

            t->nodes[cur].children[c] = idx;
            t->last = idx;
        }

        t->nodes[t->last].cnt++;
    }

    /*
     * Propagate counts. A node's suffix link is always created before the
     * node itself (and has strictly smaller len), so processing nodes in
     * decreasing creation index is a valid decreasing-len order.
     */
    for (int v = t->size - 1; v >= 2; v--) {
        t->nodes[t->nodes[v].suffix_link].cnt += t->nodes[v].cnt;
    }

    return t;
}

int eertree_count_distinct(const Eertree* t)
{
    if (t == NULL)
        return 0;
    return t->size - 2;
}

long long eertree_count_occurrences(const Eertree* t, const char* pattern, int plen)
{
    if (t == NULL || pattern == NULL || plen <= 0)
        return 0;

    /* pattern must be a palindrome */
    for (int i = 0, j = plen - 1; i < j; i++, j--) {
        if (pattern[i] != pattern[j])
            return 0;
    }

    for (int v = 2; v < t->size; v++) {
        const EertreeNode* nd = &t->nodes[v];
        if (nd->len != plen)
            continue;
        int start = nd->end_pos - nd->len + 1;
        if (start < 0 || start + plen > t->str_len)
            continue;
        if (memcmp(t->str + start, pattern, (size_t)plen) == 0)
            return nd->cnt;
    }
    return 0;
}

int eertree_longest_length(const Eertree* t)
{
    if (t == NULL)
        return 0;
    int best = 0;
    for (int v = 2; v < t->size; v++) {
        if (t->nodes[v].len > best)
            best = t->nodes[v].len;
    }
    return best;
}

void eertree_free(Eertree* t)
{
    if (t == NULL)
        return;
    free(t->nodes);
    free(t->str);
    free(t);
}
