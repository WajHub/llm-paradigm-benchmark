object OrderStats {
  case class SelectResult(value: Int, pivots: Vector[Int])

  // Read-only sorted (non-decreasing) sequence; get(index) is 0-based, 0 <= index < length.
  // Every get call is counted by the tests; reading length is free.
  trait SortedSource {
    def length: Int
    def get(index: Int): Int
  }

  private def lowerMedian(group: Vector[Int]): Int = {
    val sorted = group.sorted
    sorted((sorted.length - 1) / 2)
  }

  def medianOfMedians(xs: Vector[Int]): Option[Int] =
    if (xs.isEmpty) None
    else Some(lowerMedian(xs.grouped(5).map(lowerMedian).toVector))

  def selectKth(xs: Vector[Int], k: Int): Option[SelectResult] =
    if (k < 0 || k >= xs.length) None
    else {
      @annotation.tailrec
      def loop(cur: Vector[Int], kk: Int, pivots: Vector[Int]): SelectResult =
        if (cur.length <= 5) SelectResult(cur.sorted.apply(kk), pivots)
        else {
          val p = medianOfMedians(cur).get
          val l = cur.filter(_ < p)
          val e = cur.count(_ == p)
          val g = cur.filter(_ > p)
          val np = pivots :+ p
          if (kk < l.length) loop(l, kk, np)
          else if (kk < l.length + e) SelectResult(p, np)
          else loop(g, kk - l.length - e, np)
        }
      Some(loop(xs, k, Vector.empty))
    }

  def medianTwoSorted(a0: SortedSource, b0: SortedSource): Option[Double] = {
    val total: Long = a0.length.toLong + b0.length.toLong
    if (total == 0L) None
    else {
      val (a, b) = if (a0.length <= b0.length) (a0, b0) else (b0, a0)
      val m: Long = a.length.toLong
      val n: Long = b.length.toLong
      val half: Long = (total + 1L) / 2L

      def readA(i: Long): Long = a.get(i.toInt).toLong
      def readB(j: Long): Long = b.get(j.toInt).toLong

      // Binary search for the smallest i in [0, m] such that a(i) >= b(j-1), j = half - i.
      var lo = 0L
      var hi = m
      while (lo < hi) {
        val mid = (lo + hi) / 2L
        val j = half - mid
        if (mid < m && j > 0L && readA(mid) < readB(j - 1L)) lo = mid + 1L
        else hi = mid
      }

      val i = lo
      val j = half - i

      val leftA = if (i == 0L) Long.MinValue else readA(i - 1L)
      val leftB = if (j == 0L) Long.MinValue else readB(j - 1L)
      val rightA = if (i == m) Long.MaxValue else readA(i)
      val rightB = if (j == n) Long.MaxValue else readB(j)

      val maxLeft = math.max(leftA, leftB)
      val minRight = math.min(rightA, rightB)

      if (total % 2L == 1L) Some(maxLeft.toDouble)
      else Some((maxLeft.toDouble + minRight.toDouble) / 2.0)
    }
  }
}
