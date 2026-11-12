#ifndef SEQUENCE_ALIGNMENT_H
#define SEQUENCE_ALIGNMENT_H

/*
 * Global alignment of two strings with an affine gap penalty (Gotoh).
 * Strings are NUL-terminated, never NULL, and never contain '-'.
 * All four scoring parameters are >= 0.
 */

typedef struct {
    int score;          /* optimal global alignment score */
    char* aligned_a;    /* NUL-terminated, heap; a with '-' inserted */
    char* aligned_b;    /* NUL-terminated, heap; b with '-' inserted, same length as aligned_a */
} AlignmentResult;

/* Maximum score over all global alignments of a and b. */
int alignment_score(const char* a, const char* b,
                    int match_score, int mismatch_penalty, int gap_open, int gap_extend);

/* One optimal alignment and its score. Never NULL for valid input.
   Caller frees with free_alignment_result. */
AlignmentResult* alignment_align(const char* a, const char* b,
                                 int match_score, int mismatch_penalty, int gap_open, int gap_extend);

/* Frees the result and both strings. Accepts NULL. */
void free_alignment_result(AlignmentResult* result);

#endif
