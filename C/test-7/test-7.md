# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
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
```
