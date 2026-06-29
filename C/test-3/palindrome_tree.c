#include <stdlib.h>
#include <string.h>
#include "palindrome_tree.h"
Eertree* eertree_build(const char* s, int len) {
if (len < 0) return NULL;
if (len > 0 && !s) return NULL;
Eertree* t = malloc(sizeof(Eertree));
if (!t) return NULL;

t->str_len = len;
t->str = malloc(len + 1);
if (!t->str) { free(t); return NULL; }
if (s) strcpy(t->str, s);
else t->str[0] = '\0';
t->str[len] = '\0';

t->capacity = len + 2;
t->nodes = calloc(t->capacity, sizeof(EertreeNode));
if (!t->nodes) { free(t->str); free(t); return NULL; }
t->size = 2;
t->last = 1;

t->nodes[0].len = -1;
t->nodes[0].suffix_link = 0;
t->nodes[0].cnt = 0;
t->nodes[0].end_pos = -1;
memset(t->nodes[0].children, 0, sizeof(t->nodes[0].children));

t->nodes[1].len = 0;
t->nodes[1].suffix_link = 0;
t->nodes[1].cnt = 0;
t->nodes[1].end_pos = -1;
memset(t->nodes[1].children, 0, sizeof(t->nodes[1].children));

for (int pos = 0; pos < len; pos++) {
    int c = t->str[pos] - 'a';
    int curr = t->last;
    while (1) {
        int pos_len = t->nodes[curr].len;
        if (pos - pos_len - 1 >= 0 && t->str[pos - pos_len - 1] == t->str[pos])
            break;
        curr = t->nodes[curr].suffix_link;
    }

    if (t->nodes[curr].children[c]) {
        t->last = t->nodes[curr].children[c];
        t->nodes[t->last].cnt++;
        continue;
    }

    int new_idx = t->size++;
    t->nodes[new_idx].len = t->nodes[curr].len + 2;
    t->nodes[new_idx].cnt = 1;
    t->nodes[new_idx].end_pos = pos;
    memset(t->nodes[new_idx].children, 0, sizeof(t->nodes[new_idx].children));
    t->nodes[curr].children[c] = new_idx;

    if (t->nodes[new_idx].len == 1) {
        t->nodes[new_idx].suffix_link = 1;
    } else {
        int temp = t->nodes[curr].suffix_link;
        while (1) {
            int pos_len = t->nodes[temp].len;
            if (pos - pos_len - 1 >= 0 && t->str[pos - pos_len - 1] == t->str[pos])
                break;
            temp = t->nodes[temp].suffix_link;
        }
        t->nodes[new_idx].suffix_link = t->nodes[temp].children[c];
    }
    t->last = new_idx;
}

for (int i = t->size - 1; i >= 2; i--) {
    t->nodes[t->nodes[i].suffix_link].cnt += t->nodes[i].cnt;
}

return t;
}
int eertree_count_distinct(const Eertree* t) {
if (!t) return 0;
return t->size - 2;
}
long long eertree_count_occurrences(const Eertree* t, const char* pattern, int plen) {
if (!t || !pattern || plen <= 0) return 0;
const char* found = strstr(t->str, pattern);
if (!found) return 0;
int idx = (int)(found - t->str);
for (int i = 0; i < plen / 2; i++) {
if (pattern[i] != pattern[plen - 1 - i]) return 0;
}
for (int i = 2; i < t->size; i++) {
if (t->nodes[i].len == plen && t->nodes[i].end_pos == idx + plen - 1) {
return t->nodes[i].cnt;
}
}
return 0;
}
int eertree_longest_length(const Eertree* t) {
if (!t) return 0;
int max_len = 0;
for (int i = 2; i < t->size; i++) {
if (t->nodes[i].len > max_len) max_len = t->nodes[i].len;
}
return max_len;
}
void eertree_free(Eertree* t) {
if (!t) return;
free(t->nodes);
free(t->str);
free(t);
}