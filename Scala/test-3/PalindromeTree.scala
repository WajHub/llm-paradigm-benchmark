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

  def eertreeBuild(s: Option[String], len: Int): Option[Eertree] =
    sys.error("PalindromeTree.eertreeBuild not implemented")

  def eertreeCountDistinct(t: Option[Eertree]): Int =
    sys.error("PalindromeTree.eertreeCountDistinct not implemented")

  def eertreeCountOccurrences(t: Option[Eertree], pattern: Option[String], plen: Int): Long =
    sys.error("PalindromeTree.eertreeCountOccurrences not implemented")

  def eertreeLongestLength(t: Option[Eertree]): Int =
    sys.error("PalindromeTree.eertreeLongestLength not implemented")
}
