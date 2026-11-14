import scala.annotation.tailrec

object SequenceAlignment {
  case class AlignResult(score: Int, alignedA: String, alignedB: String)

  // Sentinel for unreachable DP states; large enough negative to never win,
  // small enough in magnitude that adding/subtracting penalties cannot overflow.
  private val NEG: Int = Int.MinValue / 4

  // DP state identifiers
  private val MatchState = 0 // column pairs a[i-1] with b[j-1]
  private val GapInB = 1     // column pairs a[i-1] with '-'
  private val GapInA = 2     // column pairs '-' with b[j-1]

  private def subst(x: Char, y: Char, matchScore: Int, mismatchPenalty: Int): Int =
    if (x == y) matchScore else -mismatchPenalty

  private case class Tables(m: Array[Array[Int]], x: Array[Array[Int]], y: Array[Array[Int]])

  /** Gotoh's three-table DP. Tables are filled in row-major order. */
  private def fill(a: String, b: String, matchScore: Int, mismatchPenalty: Int,
                   gapOpen: Int, gapExtend: Int): Tables = {
    val n = a.length
    val k = b.length
    val open = gapOpen + gapExtend
    val mt = Array.fill(n + 1, k + 1)(NEG)
    val xt = Array.fill(n + 1, k + 1)(NEG)
    val yt = Array.fill(n + 1, k + 1)(NEG)
    mt(0)(0) = 0

    for (i <- 0 to n; j <- 0 to k) {
      if (i > 0 && j > 0) {
        val best = math.max(mt(i - 1)(j - 1), math.max(xt(i - 1)(j - 1), yt(i - 1)(j - 1)))
        mt(i)(j) = best + subst(a(i - 1), b(j - 1), matchScore, mismatchPenalty)
      }
      if (i > 0) {
        xt(i)(j) = math.max(mt(i - 1)(j) - open,
          math.max(xt(i - 1)(j) - gapExtend, yt(i - 1)(j) - open))
      }
      if (j > 0) {
        yt(i)(j) = math.max(mt(i)(j - 1) - open,
          math.max(yt(i)(j - 1) - gapExtend, xt(i)(j - 1) - open))
      }
    }
    Tables(mt, xt, yt)
  }

  def alignmentScore(a: String, b: String, matchScore: Int, mismatchPenalty: Int,
                     gapOpen: Int, gapExtend: Int): Int = {
    val t = fill(a, b, matchScore, mismatchPenalty, gapOpen, gapExtend)
    val n = a.length
    val k = b.length
    math.max(t.m(n)(k), math.max(t.x(n)(k), t.y(n)(k)))
  }

  def align(a: String, b: String, matchScore: Int, mismatchPenalty: Int,
            gapOpen: Int, gapExtend: Int): AlignResult = {
    val t = fill(a, b, matchScore, mismatchPenalty, gapOpen, gapExtend)
    val n = a.length
    val k = b.length
    val open = gapOpen + gapExtend

    val best = math.max(t.m(n)(k), math.max(t.x(n)(k), t.y(n)(k)))
    val startState =
      if (t.m(n)(k) == best) MatchState
      else if (t.x(n)(k) == best) GapInB
      else GapInA

    // Traceback: follow the predecessor that produced each table value.
    @tailrec
    def trace(i: Int, j: Int, state: Int, acc: List[(Char, Char)]): List[(Char, Char)] = {
      if (i == 0 && j == 0) acc
      else state match {
        case MatchState =>
          val v = t.m(i)(j) - subst(a(i - 1), b(j - 1), matchScore, mismatchPenalty)
          val prev =
            if (t.m(i - 1)(j - 1) == v) MatchState
            else if (t.x(i - 1)(j - 1) == v) GapInB
            else GapInA
          trace(i - 1, j - 1, prev, (a(i - 1), b(j - 1)) :: acc)
        case GapInB =>
          val v = t.x(i)(j)
          val prev =
            if (t.m(i - 1)(j) - open == v) MatchState
            else if (t.x(i - 1)(j) - gapExtend == v) GapInB
            else GapInA
          trace(i - 1, j, prev, (a(i - 1), '-') :: acc)
        case _ => // GapInA
          val v = t.y(i)(j)
          val prev =
            if (t.m(i)(j - 1) - open == v) MatchState
            else if (t.y(i)(j - 1) - gapExtend == v) GapInA
            else GapInB
          trace(i, j - 1, prev, ('-', b(j - 1)) :: acc)
      }
    }

    val columns = trace(n, k, startState, Nil)
    AlignResult(best, columns.map(_._1).mkString, columns.map(_._2).mkString)
  }
}
