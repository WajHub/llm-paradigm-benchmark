You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

Implement global sequence alignment with an affine gap penalty (Gotoh's algorithm)
in C using the header file sequence_alignment.h.

Inputs: two NUL-terminated strings `a` and `b` (never NULL, possibly empty) made of
printable ASCII letters; they never contain '-'. Characters are compared exactly
(case-sensitive). The four parameters `match_score`, `mismatch_penalty`, `gap_open`
and `gap_extend` are all >= 0.

Definitions:
  * An alignment of a and b is a pair of equal-length strings A', B' over the
    alphabet plus the gap character '-', such that removing every '-' from A'
    gives a and removing every '-' from B' gives b, and NO column has '-' in both
    rows.
  * Score of an alignment:
      - every column without '-' scores +match_score if the two characters are
        equal and -mismatch_penalty otherwise;
      - every gap, i.e. every MAXIMAL run of consecutive '-' in the same row, of
        length L >= 1 costs gap_open + L * gap_extend (subtracted from the score).
        So a gap of length 3 costs gap_open + 3 * gap_extend (the first gap
        character also pays gap_extend).
  * A gap in one row may be immediately followed by a gap in the other row
    (e.g. columns "A-" over "-C"); these are two separate gaps and each pays its
    own gap_open. Your DP must allow this transition (gap-in-a <-> gap-in-b),
    otherwise some optimal alignments are missed.
  * Global alignment: leading and trailing gaps are penalised like any other gap
    (no free end gaps, no local alignment). The score may be negative; never clamp
    it at 0.

- Implement `alignment_score`: Return the maximum score over all alignments of a
  and b. Empty vs empty gives 0; empty vs a string of length L gives
  -(gap_open + L * gap_extend).

- Implement `alignment_align`: Return a freshly malloc'd AlignmentResult holding
  one optimal alignment: `aligned_a` and `aligned_b` are freshly malloc'd,
  NUL-terminated strings (A' and B' above, equal length, '-' as gap character) and
  `score` is the optimal score, which must equal the score of the returned strings
  under the definition above. If several optimal alignments exist, any one of them
  is accepted. Empty vs empty gives score 0 and two empty strings ("" - still heap
  allocated, not NULL). Never return NULL for valid input. The caller owns the
  result and releases it with `free_alignment_result`.

- Implement `free_alignment_result`: Free the result and both strings.
  `free_alignment_result(NULL)` is a no-op.

Algorithm requirement:
  - Use Gotoh's O(len(a) * len(b)) dynamic programming with three matrices (best
    score ending in a match/mismatch column, ending with a gap in b, ending with a
    gap in a) or an equivalent formulation; the traceback must move between the
    three matrices. Do NOT enumerate alignments - inputs of length > 100 are tested.

Constraints:
  - No memory leaks (verified by valgrind); free every temporary allocation.
  - All functions must handle their edge cases (empty strings) without crashing.

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

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