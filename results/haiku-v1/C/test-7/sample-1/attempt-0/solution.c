#include <stdlib.h>
#include <string.h>
#include "sequence_alignment.h"

#define GOTOH_NEG (-(1LL << 60))

typedef long long ll;

static ll ll_max3(ll x, ll y, ll z)
{
    ll r = x;
    if (y > r) r = y;
    if (z > r) r = z;
    return r;
}

/* Allocates and fills the three Gotoh matrices. Returns 0 on success. */
static int gotoh_fill(const char *a, size_t n, const char *b, size_t m,
                      ll ma, ll mi, ll go, ll ge,
                      ll **Mout, ll **Xout, ll **Yout)
{
    size_t W = m + 1;
    size_t total = (n + 1) * W;
    ll open = go + ge;
    ll *M = (ll *)malloc(total * sizeof(ll));
    ll *X = (ll *)malloc(total * sizeof(ll));
    ll *Y = (ll *)malloc(total * sizeof(ll));
    size_t i, j;

    if (!M || !X || !Y) {
        free(M);
        free(X);
        free(Y);
        return -1;
    }

    for (i = 0; i <= n; i++) {
        for (j = 0; j <= m; j++) {
            size_t idx = i * W + j;
            if (i == 0 && j == 0) {
                M[idx] = 0;
                X[idx] = GOTOH_NEG;
                Y[idx] = GOTOH_NEG;
                continue;
            }
            /* M: column a[i-1] over b[j-1] */
            if (i > 0 && j > 0) {
                size_t p = (i - 1) * W + (j - 1);
                ll s = (a[i - 1] == b[j - 1]) ? ma : -mi;
                M[idx] = ll_max3(M[p], X[p], Y[p]) + s;
            } else {
                M[idx] = GOTOH_NEG;
            }
            /* X: column a[i-1] over '-' (gap in b) */
            if (i > 0) {
                size_t p = (i - 1) * W + j;
                X[idx] = ll_max3(M[p] - open, X[p] - ge, Y[p] - open);
            } else {
                X[idx] = GOTOH_NEG;
            }
            /* Y: column '-' over b[j-1] (gap in a) */
            if (j > 0) {
                size_t p = i * W + (j - 1);
                Y[idx] = ll_max3(M[p] - open, Y[p] - ge, X[p] - open);
            } else {
                Y[idx] = GOTOH_NEG;
            }
        }
    }

    *Mout = M;
    *Xout = X;
    *Yout = Y;
    return 0;
}

int alignment_score(const char *a, const char *b,
                    int match_score, int mismatch_penalty, int gap_open, int gap_extend)
{
    size_t n = strlen(a);
    size_t m = strlen(b);
    ll *M = NULL, *X = NULL, *Y = NULL;
    ll best;
    size_t idx;

    if (gotoh_fill(a, n, b, m, match_score, mismatch_penalty,
                   gap_open, gap_extend, &M, &X, &Y) != 0)
        return 0;

    idx = n * (m + 1) + m;
    best = M[idx];
    if (X[idx] > best) best = X[idx];
    if (Y[idx] > best) best = Y[idx];

    free(M);
    free(X);
    free(Y);
    return (int)best;
}

AlignmentResult *alignment_align(const char *a, const char *b,
                                 int match_score, int mismatch_penalty, int gap_open, int gap_extend)
{
    size_t n = strlen(a);
    size_t m = strlen(b);
    size_t W = m + 1;
    ll ma = match_score, mi = mismatch_penalty, go = gap_open, ge = gap_extend;
    ll open = go + ge;
    ll *M = NULL, *X = NULL, *Y = NULL;
    ll best;
    int state;
    size_t i, j, k;
    char *buf_a, *buf_b;
    AlignmentResult *res;

    if (gotoh_fill(a, n, b, m, ma, mi, go, ge, &M, &X, &Y) != 0)
        return NULL;

    buf_a = (char *)malloc(n + m + 1);
    buf_b = (char *)malloc(n + m + 1);
    res = (AlignmentResult *)malloc(sizeof(AlignmentResult));
    if (!buf_a || !buf_b || !res) {
        free(buf_a);
        free(buf_b);
        free(res);
        free(M);
        free(X);
        free(Y);
        return NULL;
    }

    i = n;
    j = m;
    best = M[i * W + j];
    state = 0;
    if (X[i * W + j] > best) { best = X[i * W + j]; state = 1; }
    if (Y[i * W + j] > best) { best = Y[i * W + j]; state = 2; }

    k = 0;
    while (i > 0 || j > 0) {
        size_t idx = i * W + j;
        if (state == 0) {
            size_t p = (i - 1) * W + (j - 1);
            ll s = (a[i - 1] == b[j - 1]) ? ma : -mi;
            ll v = M[idx] - s;
            buf_a[k] = a[i - 1];
            buf_b[k] = b[j - 1];
            if (M[p] == v) state = 0;
            else if (X[p] == v) state = 1;
            else state = 2;
            i--;
            j--;
        } else if (state == 1) {
            size_t p = (i - 1) * W + j;
            ll v = X[idx];
            buf_a[k] = a[i - 1];
            buf_b[k] = '-';
            if (M[p] - open == v) state = 0;
            else if (X[p] - ge == v) state = 1;
            else state = 2;
            i--;
        } else {
            size_t p = i * W + (j - 1);
            ll v = Y[idx];
            buf_a[k] = '-';
            buf_b[k] = b[j - 1];
            if (M[p] - open == v) state = 0;
            else if (Y[p] - ge == v) state = 2;
            else state = 1;
            j--;
        }
        k++;
    }

    /* reverse into final strings */
    {
        size_t len = k;
        char *out_a = (char *)malloc(len + 1);
        char *out_b = (char *)malloc(len + 1);
        size_t t;
        if (!out_a || !out_b) {
            free(out_a);
            free(out_b);
            free(buf_a);
            free(buf_b);
            free(res);
            free(M);
            free(X);
            free(Y);
            return NULL;
        }
        for (t = 0; t < len; t++) {
            out_a[t] = buf_a[len - 1 - t];
            out_b[t] = buf_b[len - 1 - t];
        }
        out_a[len] = '\0';
        out_b[len] = '\0';
        res->score = (int)best;
        res->aligned_a = out_a;
        res->aligned_b = out_b;
    }

    free(buf_a);
    free(buf_b);
    free(M);
    free(X);
    free(Y);
    return res;
}

void free_alignment_result(AlignmentResult *result)
{
    if (!result)
        return;
    free(result->aligned_a);
    free(result->aligned_b);
    free(result);
}
