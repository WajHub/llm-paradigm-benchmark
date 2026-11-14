object BTree {
  case class Node(keys: Vector[Int], children: Vector[Node])

  private val emptyTree: Node = Node(Vector(), Vector())

  private def isLeaf(n: Node): Boolean = n.children.isEmpty

  private def isFull(t: Int, n: Node): Boolean = n.keys.length == 2 * t - 1

  private def contains(x: Node, k: Int): Boolean = {
    val i = x.keys.count(_ < k)
    (i < x.keys.length && x.keys(i) == k) ||
      (!isLeaf(x) && contains(x.children(i), k))
  }

  private def insertSorted(keys: Vector[Int], k: Int): Vector[Int] = {
    val i = keys.count(_ < k)
    keys.take(i) ++ (k +: keys.drop(i))
  }

  private def splitChild(t: Int, x: Node, i: Int): Node = {
    val y = x.children(i)
    val med = y.keys(t - 1)
    val left = Node(y.keys.take(t - 1), if (isLeaf(y)) Vector() else y.children.take(t))
    val right = Node(y.keys.drop(t), if (isLeaf(y)) Vector() else y.children.drop(t))
    Node(
      x.keys.take(i) ++ (med +: x.keys.drop(i)),
      x.children.take(i) ++ Vector(left, right) ++ x.children.drop(i + 1)
    )
  }

  private def insertNonFull(t: Int, x: Node, k: Int): Node = {
    if (isLeaf(x)) Node(insertSorted(x.keys, k), Vector())
    else {
      val i0 = x.keys.count(_ < k)
      if (isFull(t, x.children(i0))) {
        val x1 = splitChild(t, x, i0)
        val i = if (k > x1.keys(i0)) i0 + 1 else i0
        x1.copy(children = x1.children.updated(i, insertNonFull(t, x1.children(i), k)))
      } else {
        x.copy(children = x.children.updated(i0, insertNonFull(t, x.children(i0), k)))
      }
    }
  }

  private def insertKey(t: Int, root: Node, k: Int): Node = {
    if (contains(root, k)) root
    else {
      val r =
        if (isFull(t, root)) splitChild(t, Node(Vector(), Vector(root)), 0)
        else root
      insertNonFull(t, r, k)
    }
  }

  private def maxKey(n: Node): Int =
    if (isLeaf(n)) n.keys.last else maxKey(n.children.last)

  private def minKey(n: Node): Int =
    if (isLeaf(n)) n.keys.head else minKey(n.children.head)

  // Ensures child i of x has at least t keys; returns new x and index of child covering the key.
  private def fix(t: Int, x: Node, i: Int): (Node, Int) = {
    val c = x.children(i)
    val leftHasSpare = i > 0 && x.children(i - 1).keys.length >= t
    val rightHasSpare = i < x.keys.length && x.children(i + 1).keys.length >= t
    if (leftHasSpare) {
      val l = x.children(i - 1)
      val lastKey = l.keys.last
      val newL = Node(l.keys.init, if (isLeaf(l)) Vector() else l.children.init)
      val newC = Node(
        x.keys(i - 1) +: c.keys,
        if (isLeaf(c)) Vector() else l.children.last +: c.children
      )
      val newX = Node(
        x.keys.updated(i - 1, lastKey),
        x.children.updated(i - 1, newL).updated(i, newC)
      )
      (newX, i)
    } else if (rightHasSpare) {
      val r = x.children(i + 1)
      val firstKey = r.keys.head
      val newR = Node(r.keys.tail, if (isLeaf(r)) Vector() else r.children.tail)
      val newC = Node(
        c.keys :+ x.keys(i),
        if (isLeaf(c)) Vector() else c.children :+ r.children.head
      )
      val newX = Node(
        x.keys.updated(i, firstKey),
        x.children.updated(i, newC).updated(i + 1, newR)
      )
      (newX, i)
    } else if (i < x.keys.length) {
      val r = x.children(i + 1)
      val merged = Node(c.keys ++ (x.keys(i) +: r.keys), c.children ++ r.children)
      val newX = Node(
        x.keys.take(i) ++ x.keys.drop(i + 1),
        x.children.updated(i, merged).take(i + 1) ++ x.children.drop(i + 2)
      )
      (newX, i)
    } else {
      val l = x.children(i - 1)
      val merged = Node(l.keys ++ (x.keys(i - 1) +: c.keys), l.children ++ c.children)
      val newX = Node(
        x.keys.take(i - 1) ++ x.keys.drop(i),
        x.children.take(i - 1) ++ (merged +: x.children.drop(i + 1))
      )
      (newX, i - 1)
    }
  }

  private def delete(t: Int, x: Node, k: Int): Node = {
    val i = x.keys.count(_ < k)
    val found = i < x.keys.length && x.keys(i) == k
    if (found) {
      if (isLeaf(x)) {
        x.copy(keys = x.keys.take(i) ++ x.keys.drop(i + 1))
      } else {
        val y = x.children(i)
        val z = x.children(i + 1)
        if (y.keys.length >= t) {
          val kp = maxKey(y)
          val y2 = delete(t, y, kp)
          x.copy(keys = x.keys.updated(i, kp), children = x.children.updated(i, y2))
        } else if (z.keys.length >= t) {
          val kpp = minKey(z)
          val z2 = delete(t, z, kpp)
          x.copy(keys = x.keys.updated(i, kpp), children = x.children.updated(i + 1, z2))
        } else {
          val merged = Node(y.keys ++ (k +: z.keys), y.children ++ z.children)
          val newX = Node(
            x.keys.take(i) ++ x.keys.drop(i + 1),
            x.children.updated(i, merged).take(i + 1) ++ x.children.drop(i + 2)
          )
          newX.copy(children = newX.children.updated(i, delete(t, merged, k)))
        }
      }
    } else if (isLeaf(x)) {
      x
    } else {
      val (x2, j) =
        if (x.children(i).keys.length == t - 1) fix(t, x, i)
        else (x, i)
      x2.copy(children = x2.children.updated(j, delete(t, x2.children(j), k)))
    }
  }

  private def shrink(root: Node): Node =
    if (root.keys.isEmpty && root.children.nonEmpty) root.children.head else root

  private def deleteKey(t: Int, root: Node, k: Int): Node =
    if (!contains(root, k)) root
    else shrink(delete(t, root, k))

  def insertAll(t: Int, keys: Vector[Int]): Option[Node] =
    if (t < 2) None
    else Some(keys.foldLeft(emptyTree)((root, k) => insertKey(t, root, k)))

  def deleteAll(t: Int, keys: Vector[Int], deletions: Vector[Int]): Option[Node] =
    if (t < 2) None
    else {
      val built = keys.foldLeft(emptyTree)((root, k) => insertKey(t, root, k))
      Some(deletions.foldLeft(built)((root, k) => deleteKey(t, root, k)))
    }
}
