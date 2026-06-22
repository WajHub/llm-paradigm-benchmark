#ifndef PALINDROME_TREE_H
#define PALINDROME_TREE_H

#define EERTREE_ALPHA 26

typedef struct {
    int len;
    int suffix_link;
    int children[EERTREE_ALPHA];
    long long cnt;
    int end_pos;
} EertreeNode;

typedef struct {
    EertreeNode* nodes;
    int size;
    int capacity;
    int last;
    char* str;
    int str_len;
} Eertree;

Eertree*  eertree_build(const char* s, int len);
int       eertree_count_distinct(const Eertree* t);
long long eertree_count_occurrences(const Eertree* t, const char* pattern, int plen);
int       eertree_longest_length(const Eertree* t);
void      eertree_free(Eertree* t);

#endif
