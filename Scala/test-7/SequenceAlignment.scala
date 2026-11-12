object SequenceAlignment {
  case class AlignResult(score: Int, alignedA: String, alignedB: String)

  def alignmentScore(a: String, b: String, matchScore: Int, mismatchPenalty: Int,
                     gapOpen: Int, gapExtend: Int): Int =
    sys.error("SequenceAlignment.alignmentScore not implemented")

  def align(a: String, b: String, matchScore: Int, mismatchPenalty: Int,
            gapOpen: Int, gapExtend: Int): AlignResult =
    sys.error("SequenceAlignment.align not implemented")
}
