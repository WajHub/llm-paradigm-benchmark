# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement global sequence alignment with an affine gap penalty (Gotoh's algorithm) in
Java in the class SequenceAlignmentImpl (file SequenceAlignmentImpl.java), which extends
the abstract class SequenceAlignment. The base class already defines the result type
SequenceAlignment.AlignResult; implement alignmentScore and align.

Inputs (always valid): a and b are non-null strings of ASCII letters (possibly empty,
never containing '-'); characters are compared exactly (case-sensitive). matchScore,
mismatchPenalty, gapOpen and gapExtend are all >= 0 (any of them may be 0).

Definitions:
  * An alignment of a and b is a pair of strings A', B' of EQUAL length over the input
    characters plus the gap character '-', such that removing every '-' from A' gives a,
    removing every '-' from B' gives b, and no column contains '-' in both rows.
  * Score of an alignment:
      - every column without '-': +matchScore if the two characters are equal,
        -mismatchPenalty otherwise;
      - every gap, i.e. a MAXIMAL run of consecutive '-' in the same row, of length
        L >= 1 costs gapOpen + L * gapExtend (subtracted). So a gap of length 3 costs
        gapOpen + 3 * gapExtend: the first '-' of a gap also pays gapExtend.
  * A gap in one row may be immediately followed by a gap in the other row (e.g. the
    columns "A-" over "-C"). These are two separate gaps and each pays its own gapOpen.
    Your DP must allow these transitions (gap-in-a <-> gap-in-b), otherwise some optimal
    alignments are missed.
  * Global alignment: leading and trailing gaps are penalised like any other gap (no free
    end gaps, no local alignment). The score may be negative; never clamp it at 0.

- Implement `int alignmentScore(String a, String b, int matchScore, int mismatchPenalty,
  int gapOpen, int gapExtend)`: return the maximum score over all alignments of a and b.
  * Both empty -> 0.
  * One string empty, the other of length L > 0 -> -(gapOpen + L * gapExtend).

- Implement `AlignResult align(String a, String b, int matchScore, int mismatchPenalty,
  int gapOpen, int gapExtend)`: return one optimal alignment as
  new AlignResult(score, alignedA, alignedB), where alignedA / alignedB are the two rows
  (gap character '-'), and score is the maximum score (equal to alignmentScore for the
  same input and equal to the score of the returned rows by the definition above).
  * Never return null. Both empty -> AlignResult(0, "", "").
  * If several optimal alignments exist, any one of them is accepted.

Complexity: use Gotoh's O(len(a) * len(b)) dynamic programming with three tables
(best alignment ending in a match/mismatch column, ending in a gap in b, ending in a gap
in a) and a traceback that switches between the tables. Do not enumerate alignments —
inputs of length > 100 are tested.

Keep the contract in SequenceAlignment.java; put the solution in SequenceAlignmentImpl.java.
```
