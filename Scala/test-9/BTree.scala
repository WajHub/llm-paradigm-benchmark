object BTree {
  // A leaf has children == Vector.empty; an internal node with k keys has exactly k + 1 children.
  case class Node(keys: Vector[Int], children: Vector[Node])

  def insertAll(t: Int, keys: Vector[Int]): Option[Node] =
    sys.error("BTree.insertAll not implemented")

  def deleteAll(t: Int, keys: Vector[Int], deletions: Vector[Int]): Option[Node] =
    sys.error("BTree.deleteAll not implemented")
}
