# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement global sequence alignment with an affine gap penalty (Gotoh's algorithm)
in SWI-Prolog in the module sequence_alignment (file sequence_alignment.pl).
Implement alignment_score/7 and alignment_align/7.

Inputs: A and B are atoms (e.g. 'GATTACA', or '' for the empty sequence) made of
letters only; they never contain the character '-'. Characters are compared exactly
(case-sensitive). MatchScore, MismatchPenalty, GapOpen and GapExtend are integers
>= 0 (any of them may be 0).

Definitions:
  * An alignment of A and B is a pair of atoms A', B' of equal length over the
    characters of A/B plus the gap character '-', such that removing every '-' from
    A' gives A, removing every '-' from B' gives B, and no column has '-' in both
    rows.
  * Score of an alignment = sum over the columns without '-' of +MatchScore if the
    two characters are equal and -MismatchPenalty otherwise, MINUS, for every gap,
    GapOpen + L * GapExtend, where a gap is a maximal run of consecutive '-' in the
    same row and L >= 1 is its length. So a gap of length 3 costs
    GapOpen + 3 * GapExtend (the first gap character also pays GapExtend).
  * A gap in one row may be immediately followed by a gap in the other row (e.g.
    columns A over '-' followed by '-' over C, i.e. A'='A-', B'='-C'); these are two
    separate gaps and each pays its own GapOpen. Such alignments must be considered
    (the DP needs transitions between the two gap states), otherwise some optima are
    missed.
  * Global alignment: leading and trailing gaps are penalised like any other gap
    (no free end gaps, no local alignment, no clamping at 0). Scores may be negative.

- Implement `alignment_score(+A, +B, +MatchScore, +MismatchPenalty, +GapOpen, +GapExtend, -Score)`:
  Score is the maximum score (an integer) over all alignments of A and B.
  * alignment_score('', '', ...) gives 0.
  * Empty vs a sequence of length L (L >= 1) gives -(GapOpen + L * GapExtend).

- Implement `alignment_align(+A, +B, +MatchScore, +MismatchPenalty, +GapOpen, +GapExtend, -Result)`:
  Result = alignment(Score, AlignedA, AlignedB) where Score is the maximum score
  (same value as alignment_score/7) and AlignedA, AlignedB are ATOMS forming one
  alignment of A and B (as defined above) whose score is exactly Score.
  * If several optimal alignments exist, any of them is accepted; when the optimum
    is unique the exact atoms are checked.
  * alignment_align('', '', ...) gives alignment(0, '', '').
  * Example: alignment_align('AC', '', 1, 1, 2, 1, R) gives
    R = alignment(-4, 'AC', '--').

Algorithm requirements:
  - Use Gotoh's O(len(A) * len(B)) dynamic programming with three tables (best
    alignment of the prefixes ending in a match/mismatch column, ending in a gap in
    B, ending in a gap in A) or an equivalent formulation, and a traceback that can
    switch between the tables. Do not enumerate alignments: inputs have more than
    100 characters.
  - Both predicates are deterministic (a single answer).

Constraints:
  - Results are compared with == / =:=: Score must be an integer, AlignedA and
    AlignedB must be atoms (not strings or code lists).
```
