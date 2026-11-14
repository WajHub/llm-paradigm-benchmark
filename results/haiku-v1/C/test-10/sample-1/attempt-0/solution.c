#include <stdlib.h>
#include <string.h>
#include "order_stats.h"

static int cmp_int(const void* a, const void* b)
{
    int x = *(const int*)a;
    int y = *(const int*)b;
    return (x > y) - (x < y);
}

static void insertion_sort(int* a, int len)
{
    for (int i = 1; i < len; i++) {
        int v = a[i];
        int j = i - 1;
        while (j >= 0 && a[j] > v) {
            a[j + 1] = a[j];
            j--;
        }
        a[j + 1] = v;
    }
}

bool median_of_medians(const int* xs, int n, int* out)
{
    if (n <= 0) {
        return false;
    }
    int g = (n + 4) / 5;
    int* meds = (int*)malloc(sizeof(int) * (size_t)g);
    if (!meds) {
        return false;
    }
    for (int i = 0; i < g; i++) {
        int start = 5 * i;
        int len = (n - start < 5) ? (n - start) : 5;
        int buf[5];
        memcpy(buf, xs + start, sizeof(int) * (size_t)len);
        insertion_sort(buf, len);
        meds[i] = buf[(len - 1) / 2];
    }
    qsort(meds, (size_t)g, sizeof(int), cmp_int);
    *out = meds[(g - 1) / 2];
    free(meds);
    return true;
}

static void append_pivot(int** piv, int* np, int* cap, int p, bool* ok)
{
    if (!*ok) {
        return;
    }
    if (*np == *cap) {
        int newcap = (*cap == 0) ? 8 : (*cap * 2);
        int* tmp = (int*)realloc(*piv, sizeof(int) * (size_t)newcap);
        if (!tmp) {
            *ok = false;
            return;
        }
        *piv = tmp;
        *cap = newcap;
    }
    (*piv)[(*np)++] = p;
}

SelectResult* select_kth(const int* xs, int n, int k)
{
    if (n <= 0 || k < 0 || k >= n || xs == NULL) {
        return NULL;
    }

    SelectResult* res = (SelectResult*)malloc(sizeof(SelectResult));
    if (!res) {
        return NULL;
    }
    res->value = 0;
    res->pivots = NULL;
    res->num_pivots = 0;

    int* work = (int*)malloc(sizeof(int) * (size_t)n);
    int* lbuf = (int*)malloc(sizeof(int) * (size_t)n);
    int* gbuf = (int*)malloc(sizeof(int) * (size_t)n);
    if (!work || !lbuf || !gbuf) {
        free(work);
        free(lbuf);
        free(gbuf);
        free(res);
        return NULL;
    }

    memcpy(work, xs, sizeof(int) * (size_t)n);
    int curlen = n;
    int kk = k;
    int value = 0;
    int* piv = NULL;
    int np = 0;
    int cap = 0;
    bool ok = true;

    while (1) {
        if (curlen <= 5) {
            int small[5];
            memcpy(small, work, sizeof(int) * (size_t)curlen);
            insertion_sort(small, curlen);
            value = small[kk];
            break;
        }

        int p = 0;
        if (!median_of_medians(work, curlen, &p)) {
            ok = false;
            break;
        }
        append_pivot(&piv, &np, &cap, p, &ok);
        if (!ok) {
            break;
        }

        int nl = 0, ne = 0, ng = 0;
        for (int i = 0; i < curlen; i++) {
            int v = work[i];
            if (v < p) {
                lbuf[nl++] = v;
            } else if (v == p) {
                ne++;
            } else {
                gbuf[ng++] = v;
            }
        }

        if (kk < nl) {
            memcpy(work, lbuf, sizeof(int) * (size_t)nl);
            curlen = nl;
        } else if (kk < nl + ne) {
            value = p;
            break;
        } else {
            kk = kk - nl - ne;
            memcpy(work, gbuf, sizeof(int) * (size_t)ng);
            curlen = ng;
        }
    }

    free(work);
    free(lbuf);
    free(gbuf);

    if (!ok) {
        free(piv);
        free(res);
        return NULL;
    }

    res->value = value;
    if (np == 0) {
        free(piv);
        res->pivots = NULL;
    } else {
        res->pivots = piv;
    }
    res->num_pivots = np;
    return res;
}

void free_select_result(SelectResult* result)
{
    if (!result) {
        return;
    }
    free(result->pivots);
    free(result);
}

static int get_at(const SortedSource* s, long long i)
{
    return s->get(s, (int)i);
}

bool median_two_sorted(const SortedSource* a, const SortedSource* b, double* out)
{
    long long la = a->length;
    long long lb = b->length;
    long long N = la + lb;
    if (N == 0) {
        return false;
    }

    const SortedSource* A = a;
    const SortedSource* B = b;
    if (la > lb) {
        A = b;
        B = a;
    }
    long long m = A->length;
    long long n = B->length;

    long long half = (N + 1) / 2;
    long long lo = half - n > 0 ? half - n : 0;
    long long hi = m < half ? m : half;

    /* Find smallest i in [lo,hi] such that taking i from A and half-i from B
       gives a valid left part (B[j-1] <= A[i] when relevant). */
    while (lo < hi) {
        long long mid = lo + (hi - lo) / 2;
        long long j = half - mid;
        if (mid < m && j > 0 && get_at(B, j - 1) > get_at(A, mid)) {
            lo = mid + 1;
        } else {
            hi = mid;
        }
    }

    long long i = lo;
    long long j = half - i;

    /* left maximum */
    int lm = 0;
    bool have = false;
    if (i > 0) {
        lm = get_at(A, i - 1);
        have = true;
    }
    if (j > 0) {
        int v = get_at(B, j - 1);
        if (!have || v > lm) {
            lm = v;
        }
        have = true;
    }

    if (N % 2 == 1) {
        *out = (double)lm;
    } else {
        int rm = 0;
        bool hr = false;
        if (i < m) {
            rm = get_at(A, i);
            hr = true;
        }
        if (j < n) {
            int w = get_at(B, j);
            if (!hr || w < rm) {
                rm = w;
            }
            hr = true;
        }
        *out = ((double)lm + (double)rm) / 2.0;
    }
    return true;
}
