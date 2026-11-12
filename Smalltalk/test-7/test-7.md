# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement global sequence alignment with an AFFINE gap penalty (Gotoh's algorithm) in
GNU Smalltalk in the class SequenceAlignmentImpl (file SequenceAlignmentImpl.st), which
subclasses the abstract class SequenceAlignment. The result class AlignmentResult
(class-side constructor `AlignmentResult score: anInteger alignedA: aString alignedB: aString`,
accessors score, alignedA, alignedB) is already defined. Implement
scoreOf:with:match:mismatch:gapOpen:gapExtend: and align:with:match:mismatch:gapOpen:gapExtend:.
Put the solution in SequenceAlignmentImpl.st.

Inputs (the same for both methods):
  * a, b: Strings of letters (possibly empty, never containing $-). Characters are
    compared exactly (case-sensitive).
  * matchScore, mismatchPenalty, gapOpen, gapExtend: Integers >= 0 (gapExtend may be 0).

Definitions:
  * An alignment of a and b is a pair of Strings A', B' of EQUAL length over the letters
    plus the gap character $- such that removing every $- from A' gives a, removing every
    $- from B' gives b, and NO column has $- in both rows.
  * Score of an alignment = sum over the columns without $-: +matchScore if the two
    characters are equal, -mismatchPenalty otherwise; MINUS, for every gap (a maximal run
    of consecutive $- in the same row) of length L >= 1: gapOpen + (L * gapExtend).
    So a single gap of length 3 costs gapOpen + 3 * gapExtend (the first gap character
    also pays gapExtend).
  * A gap in one row may be immediately followed by a gap in the other row (e.g. the
    columns A- over -C); they are two separate gaps and each pays its own gapOpen. Your
    DP must allow the transitions gap-in-a <-> gap-in-b, otherwise some optima are missed
    (two adjacent single gaps can be cheaper than one expensive mismatch).
  * GLOBAL alignment: leading and trailing gaps are penalised like any other gap (no free
    end gaps, no local alignment). The score may be negative; never clamp at 0.

- Implement `scoreOf: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen
  gapExtend: gapExtend`: answer the MAXIMUM score over all alignments, as an Integer.
  Empty vs empty answers 0; empty vs a String of length L answers
  -(gapOpen + (L * gapExtend)).

- Implement `align: a with: b match: matchScore mismatch: mismatchPenalty gapOpen: gapOpen
  gapExtend: gapExtend`: answer an AlignmentResult (never nil) holding one optimal
  alignment: score = the maximum score (same value as scoreOf:...), alignedA = A',
  alignedB = B' (Strings using $- for gaps). The score of the returned strings, computed
  by the definition above, must equal score. Empty vs empty answers score 0 with two
  empty Strings. If several optimal alignments exist, any one of them is accepted.

Algorithm requirements:
  - Use Gotoh's O(size(a) * size(b)) dynamic programming with three tables (last column
    is a(i)/b(j), a(i)/$-, or $-/b(j)), or an equivalent; trace back through the three
    tables to rebuild the alignment. Do NOT enumerate alignments: the tests include
    strings of length 120 and 110.
  - Strings are 1-based in Smalltalk (a at: 1 is the first character).
```
