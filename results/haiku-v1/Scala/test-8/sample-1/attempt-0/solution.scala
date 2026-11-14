import scala.collection.mutable

object TspApprox {
  case class TourResult(tour: Vector[Int], cost: Int)

  private def dist(p: (Int, Int), q: (Int, Int)): Int =
    math.abs(p._1 - q._1) + math.abs(p._2 - q._2)

  // Prim's algorithm from vertex 0; returns map v -> parent(v) for every v != 0.
  private def mstParents(points: Vector[(Int, Int)]): Map[Int, Int] = {
    val n = points.length

    @annotation.tailrec
    def loop(tree: Vector[Int], parent: Map[Int, Int]): Map[Int, Int] =
      if (tree.length == n) parent
      else {
        val (_, v, u) = (0 until n).filterNot(tree.contains).map { v =>
          val (k, u) = tree.map(w => (dist(points(w), points(v)), w)).min
          (k, v, u)
        }.min
        loop(tree :+ v, parent + (v -> u))
      }

    if (n <= 1) Map.empty[Int, Int] else loop(Vector(0), Map.empty[Int, Int])
  }

  private def tourCost(points: Vector[(Int, Int)], tour: Vector[Int]): Int = {
    val n = tour.length
    (0 until n).map(i => dist(points(tour(i)), points(tour((i + 1) % n)))).sum
  }

  private def oddVertices(n: Int, parents: Map[Int, Int]): Vector[Int] = {
    val deg = parents.foldLeft(Vector.fill(n)(0)) {
      case (acc, (v, p)) => acc.updated(v, acc(v) + 1).updated(p, acc(p) + 1)
    }
    (0 until n).filter(v => deg(v) % 2 == 1).toVector
  }

  // Exact minimum-weight perfect matching on the vertices in `odd` (bitmask memo DP).
  private def matchingPairs(points: Vector[(Int, Int)], odd: Vector[Int]): (Int, List[(Int, Int)]) = {
    val m = odd.length
    val memo = mutable.HashMap.empty[Int, (Int, List[(Int, Int)])]

    def best(mask: Int): (Int, List[(Int, Int)]) =
      if (mask == 0) (0, Nil)
      else memo.get(mask) match {
        case Some(r) => r
        case None =>
          val i = Integer.numberOfTrailingZeros(mask)
          val rest = mask & ~(1 << i)
          val r = (0 until m).filter(j => (rest & (1 << j)) != 0)
            .foldLeft((Int.MaxValue, List.empty[(Int, Int)])) {
              case (acc, j) =>
                val (c, ps) = best(rest & ~(1 << j))
                val cand = c + dist(points(odd(i)), points(odd(j)))
                if (cand < acc._1) (cand, (odd(i), odd(j)) :: ps) else acc
            }
          memo += (mask -> r)
          r
      }

    best((1 << m) - 1)
  }

  def mstWeight(points: Vector[(Int, Int)]): Int =
    mstParents(points).foldLeft(0) {
      case (acc, (v, p)) => acc + dist(points(v), points(p))
    }

  def doubleTree(points: Vector[(Int, Int)]): Option[TourResult] = {
    val n = points.length
    if (n == 0) None
    else {
      val parents = mstParents(points)
      val children: Map[Int, Vector[Int]] =
        parents.toVector.groupBy(_._2).map { case (p, vs) => p -> vs.map(_._1).sorted }

      def pre(v: Int): Vector[Int] =
        v +: children.getOrElse(v, Vector.empty[Int]).flatMap(pre)

      val tour = pre(0)
      Some(TourResult(tour, tourCost(points, tour)))
    }
  }

  def matchingWeight(points: Vector[(Int, Int)]): Int = {
    val n = points.length
    if (n <= 1) 0
    else {
      val parents = mstParents(points)
      matchingPairs(points, oddVertices(n, parents))._1
    }
  }

  def christofides(points: Vector[(Int, Int)]): Option[TourResult] = {
    val n = points.length
    if (n == 0) None
    else if (n == 1) Some(TourResult(Vector(0), 0))
    else {
      val parents = mstParents(points)
      val mst: Vector[(Int, Int)] = parents.toVector
      val odd = oddVertices(n, parents)
      val (_, matched) = matchingPairs(points, odd)
      val edges: Vector[(Int, Int)] = mst ++ matched.toVector

      val adj: Vector[Vector[(Int, Int)]] = (0 until n).map { v =>
        edges.zipWithIndex.collect {
          case ((a, b), e) if a == v => (e, b)
          case ((a, b), e) if b == v => (e, a)
        }.toVector
      }.toVector

      // Hierholzer's algorithm on the multigraph
      val used = Array.fill(edges.length)(false)
      val ptr = Array.fill(n)(0)
      val stack = mutable.Stack[Int](0)
      val circuit = mutable.ListBuffer[Int]()

      while (stack.nonEmpty) {
        val v = stack.top
        while (ptr(v) < adj(v).length && used(adj(v)(ptr(v))._1)) ptr(v) += 1
        if (ptr(v) < adj(v).length) {
          val (e, w) = adj(v)(ptr(v))
          used(e) = true
          stack.push(w)
        } else {
          circuit += stack.pop()
        }
      }

      // Shortcut: keep first occurrence of each vertex
      val tour = circuit.toVector.foldLeft((Vector.empty[Int], Set.empty[Int])) {
        case ((acc, seen), v) =>
          if (seen(v)) (acc, seen) else (acc :+ v, seen + v)
      }._1

      Some(TourResult(tour, tourCost(points, tour)))
    }
  }
}
