# Test 7

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement global sequence alignment with an affine gap penalty (Gotoh's
algorithm) in Scala 2.11 in the object SequenceAlignment (file
SequenceAlignment.scala). The object already defines the result type
AlignResult(score: Int, alignedA: String, alignedB: String); implement
alignmentScore and align.

Parameters (both functions): a: String, b: String, matchScore: Int,
mismatchPenalty: Int, gapOpen: Int, gapExtend: Int.
  * All four numeric parameters are >= 0.
  * a and b contain only ASCII letters (never '-'); they may be empty.
    Characters are compared exactly (case-sensitive).

Definitions:
  * An alignment of a and b is a pair of strings (A', B') of equal length over
    the input characters plus the gap character '-', such that removing every
    '-' from A' gives a, removing every '-' from B' gives b, and NO column has
    '-' in both rows.
  * Score of an alignment:
      - every column without '-' adds +matchScore if the two characters are
        equal, and -mismatchPenalty otherwise;
      - every gap, i.e. a MAXIMAL run of consecutive '-' in the same row, of
        length L >= 1 subtracts gapOpen + L * gapExtend.
        (A gap of length 3 costs gapOpen + 3 * gapExtend: the first gap
        character also pays gapExtend.)
  * A gap in one row may be immediately followed by a gap in the other row,
    e.g. the columns
        A-
        -C
    These are two separate gaps and each pays its own gapOpen. Such
    alignments must be reachable by your DP (allow transitions between the
    "gap in a" and "gap in b" states), otherwise some optima are missed.
  * This is GLOBAL alignment: leading and trailing gaps are penalised exactly
    like any other gap (no free end gaps, no local alignment, no clamping of
    scores at 0). Scores may be negative.

- Implement `alignmentScore(...): Int`: return the maximum score over all
  alignments of a and b.
  * a == "" and b == "": 0.
  * One string empty, the other of length L > 0: -(gapOpen + L * gapExtend).

- Implement `align(...): AlignResult`: return one optimal alignment:
  * score = the maximum score (same value as alignmentScore),
  * alignedA / alignedB = the two rows A' and B' of an alignment whose score
    (computed by the definition above) equals that maximum.
  * Use '-' as the gap character.
  * a == "" and b == "": AlignResult(0, "", "").
  * If several optimal alignments exist, any one of them is accepted.

Requirements:
  - Use Gotoh's O(len(a) * len(b)) dynamic programming with three tables
    (best score ending in a match/mismatch column, ending with a gap in b,
    ending with a gap in a) or an equivalent formulation, and a traceback
    that follows the table/state the optimum came from. Do NOT enumerate
    alignments; the inputs can be over 100 characters long.
  - The tests recompute the score of the returned rows from the definition
    above and compare it with the score field.
  - Use Scala 2.11 syntax and standard library only (no Scala 3 syntax, no
    2.12/2.13-only APIs such as LazyList or .to(List)).
```
