import scala.annotation.tailrec

object PalindromeTree {
  val EertreeAlpha = 26

  case class Node(
    len: Int,
    suffixLink: Int,
    children: Vector[Int],
    cnt: Long,
    endPos: Int
  )

  case class Eertree(
    nodes: Vector[Node],
    size: Int,
    last: Int,
    str: String,
    strLen: Int
  )

  private case class BuildState(nodes: Vector[Node], last: Int)

  private val Roots: Vector[Node] = Vector(
    Node(-1, 0, Vector.fill(EertreeAlpha)(0), 0L, -1), // odd root
    Node(0, 0, Vector.fill(EertreeAlpha)(0), 0L, -1)   // even root
  )

  // Walks suffix links from `start` until finding a palindrome suffix of s[0..i]
  // that can be extended by s(i) on both sides.
  @tailrec
  private def findExtendable(s: String, nodes: Vector[Node], cur: Int, i: Int): Int = {
    val p = i - nodes(cur).len - 1
    if (p >= 0 && s(p) == s(i)) cur
    else findExtendable(s, nodes, nodes(cur).suffixLink, i)
  }

  private def insert(s: String, st: BuildState, i: Int): BuildState = {
    val c = s(i) - 'a'
    val nodes = st.nodes
    val cur = findExtendable(s, nodes, st.last, i)
    val existing = nodes(cur).children(c)

    if (existing != 0) {
      val n = nodes(existing)
      BuildState(nodes.updated(existing, n.copy(cnt = n.cnt + 1)), existing)
    } else {
      val newLen = nodes(cur).len + 2
      val link =
        if (newLen == 1) 1
        else {
          val w = findExtendable(s, nodes, nodes(cur).suffixLink, i)
          nodes(w).children(c)
        }
      val newIdx = nodes.length
      val newNode = Node(newLen, link, Vector.fill(EertreeAlpha)(0), 1L, i)
      val parent = nodes(cur)
      val updatedParent = parent.copy(children = parent.children.updated(c, newIdx))
      val nodes1 = nodes.updated(cur, updatedParent) :+ newNode
      BuildState(nodes1, newIdx)
    }
  }

  private def propagate(nodes: Vector[Node]): Vector[Node] = {
    val order = (2 until nodes.length).sortBy(i => -nodes(i).len)
    order.foldLeft(nodes) { (ns, idx) =>
      val link = ns(idx).suffixLink
      ns.updated(link, ns(link).copy(cnt = ns(link).cnt + ns(idx).cnt))
    }
  }

  private def buildFrom(str: String, n: Int): Eertree = {
    val init = BuildState(Roots, 0)
    val st = (0 until n).foldLeft(init)((acc, i) => insert(str, acc, i))
    val nodes = propagate(st.nodes)
    Eertree(nodes, nodes.length, st.last, str, n)
  }

  def eertreeBuild(s: Option[String], len: Int): Option[Eertree] =
    (s, len) match {
      case (None, n) if n > 0 => None
      case (None, _)          => Some(buildFrom("", 0))
      case (Some(str), n) if n < 0 || str.length < n => None
      case (Some(str), n)     => Some(buildFrom(str.take(n), n))
    }

  def eertreeCountDistinct(t: Option[Eertree]): Int =
    t.map(e => math.max(e.nodes.length - 2, 0)).getOrElse(0)

  def eertreeCountOccurrences(t: Option[Eertree], pattern: Option[String], plen: Int): Long =
    (t, pattern) match {
      case (Some(e), Some(p)) if p.length == plen && plen > 0 && p == p.reverse =>
        (2 until e.nodes.length)
          .find { idx =>
            val n = e.nodes(idx)
            n.len == plen && n.endPos - n.len + 1 >= 0 &&
              e.str.substring(n.endPos - n.len + 1, n.endPos + 1) == p
          }
          .map(idx => e.nodes(idx).cnt)
          .getOrElse(0L)
      case _ => 0L
    }

  def eertreeLongestLength(t: Option[Eertree]): Int =
    t.map { e =>
      (2 until e.nodes.length).foldLeft(0)((acc, i) => math.max(acc, e.nodes(i).len))
    }.getOrElse(0)
}
