# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement global sequence alignment with an affine gap penalty (Gotoh's algorithm) in
Free Pascal in the unit sequence_alignment (file sequence_alignment.pas). The unit already
declares the result type and the three routines; keep the interface unchanged and
implement AlignmentScore, AlignmentAlign and FreeAlignmentResult in the implementation
section.

Definitions (every rule below is checked by the tests):
  * Inputs: two AnsiStrings A and B (possibly empty) of ASCII letters; they never contain
    '-'. Characters are compared exactly (case-sensitive). The four parameters MatchScore,
    MismatchPenalty, GapOpen, GapExtend are all >= 0 (GapExtend may be 0).
  * An alignment of A and B is a pair of equal-length strings A', B' over the letters
    plus the gap character '-' such that deleting every '-' from A' gives A and from B'
    gives B, and NO column has '-' in both rows.
  * Score of an alignment:
      - every column with two characters: +MatchScore if they are equal, -MismatchPenalty
        otherwise;
      - every gap, i.e. every MAXIMAL run of consecutive '-' in the same row, of length
        L >= 1, costs GapOpen + L * GapExtend (subtracted). So a gap of length 3 costs
        GapOpen + 3*GapExtend: the first gap character also pays GapExtend.
  * A gap in one row may be immediately followed (or preceded) by a gap in the other row,
    e.g. the columns  A-  over  -C . These are two separate gaps and each pays its own
    GapOpen. Your DP must allow these transitions (gap-in-A <-> gap-in-B), otherwise some
    optimal alignments are missed.
  * Global alignment: leading and trailing gaps are penalised exactly like inner gaps
    (no free end gaps, no local alignment, no clamping at 0). Scores may be negative.

- Implement `AlignmentScore(const A, B: AnsiString; MatchScore, MismatchPenalty, GapOpen,
  GapExtend: LongInt): LongInt`: return the maximum score over all alignments.
  * '' vs '' -> 0.
  * '' vs a string of length L (either order) -> -(GapOpen + L * GapExtend).

- Implement `AlignmentAlign(<same parameters>): PAlignmentResult`: return a newly
  allocated record (New) with
  * Score    = the maximum score (same value as AlignmentScore),
  * AlignedA = A', AlignedB = B' : one optimal alignment, with '-' as gap character, whose
    score by the definition above equals Score.
  * Never return nil. '' vs '' -> Score 0, AlignedA = '' and AlignedB = ''.
    'ACG' vs '' -> AlignedA = 'ACG', AlignedB = '---'.
  * If several optimal alignments exist, any of them is accepted (the tests recompute the
    score of your strings and check all the rules above).

- Implement `FreeAlignmentResult(var R: PAlignmentResult)`: Dispose the record (its
  AnsiString fields are released by Dispose) and set R to nil. FreeAlignmentResult(nil)
  is a no-op. The caller owns every returned record and frees it with this procedure.

Algorithm requirements:
  - Use Gotoh's O(Length(A) * Length(B)) dynamic programming with three tables (column
    of two characters / A-character over gap / gap over B-character, or an equivalent
    formulation) and a traceback that switches between the tables. Do NOT enumerate
    alignments; inputs have more than 100 characters.
  - Use a "minus infinity" sentinel that cannot overflow LongInt when penalties are
    subtracted from it.
  - Strings are 1-based in Pascal (A[1] .. A[Length(A)]).

Pascal notes:
  - Pascal is case-insensitive: the parameters are named A and B, so do NOT declare local
    variables named a or b (or anything else that clashes with a parameter name), and do
    not name anything Result except the function result.
  - The program is run under valgrind and must not leak memory.
```
