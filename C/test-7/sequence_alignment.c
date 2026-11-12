#include "sequence_alignment.h"
#include <stdlib.h>

int alignment_score(const char* a, const char* b,
                    int match_score, int mismatch_penalty, int gap_open, int gap_extend) {
    (void)a; (void)b; (void)match_score; (void)mismatch_penalty; (void)gap_open; (void)gap_extend;
    return -9999;
}

AlignmentResult* alignment_align(const char* a, const char* b,
                                 int match_score, int mismatch_penalty, int gap_open, int gap_extend) {
    (void)a; (void)b; (void)match_score; (void)mismatch_penalty; (void)gap_open; (void)gap_extend;
    return NULL;
}

void free_alignment_result(AlignmentResult* result) {
    (void)result;
}
