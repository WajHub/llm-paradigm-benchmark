object Tests {
  import PalindromeTree._

  type TestCase = (String, () => Boolean)

  def check(name: String)(body: => Boolean): Boolean = {
    try {
      if (body) {
        println("[PASS] " + name)
        true
      } else {
        println("[FAIL] " + name)
        false
      }
    } catch {
      case _: Throwable =>
        println("[FAIL] " + name)
        false
    }
  }

  // ==========================================================================
  // Algorithm A: eertreeBuild, eertreeCountDistinct, eertreeLongestLength
  // ==========================================================================

  def testAlgoA01BasicAabaa(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 5 && eertreeLongestLength(Some(t)) == 5
      }
    } catch { case _: Throwable => false }

  def testAlgoA02SingleChar(): Boolean =
    try {
      eertreeBuild(Some("a"), 1) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 1 && eertreeLongestLength(Some(t)) == 1
      }
    } catch { case _: Throwable => false }

  def testAlgoA03AllSameChars(): Boolean =
    try {
      eertreeBuild(Some("aaaa"), 4) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 4 && eertreeLongestLength(Some(t)) == 4
      }
    } catch { case _: Throwable => false }

  def testAlgoA04NoInternalPalindromes(): Boolean =
    try {
      eertreeBuild(Some("abcde"), 5) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 5 && eertreeLongestLength(Some(t)) == 1
      }
    } catch { case _: Throwable => false }

  def testAlgoA05EmptyString(): Boolean =
    try {
      eertreeBuild(Some(""), 0) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 0 && eertreeLongestLength(Some(t)) == 0
      }
    } catch { case _: Throwable => false }

  def testAlgoA06NullInput(): Boolean =
    try {
      eertreeBuild(None, 5).isEmpty
    } catch { case _: Throwable => false }

  def testAlgoA07TwoCharPalindrome(): Boolean =
    try {
      eertreeBuild(Some("aa"), 2) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 2 && eertreeLongestLength(Some(t)) == 2
      }
    } catch { case _: Throwable => false }

  def testAlgoA08Abacaba(): Boolean =
    try {
      eertreeBuild(Some("abacaba"), 7) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 7 && eertreeLongestLength(Some(t)) == 7
      }
    } catch { case _: Throwable => false }

  def testAlgoA09Abba(): Boolean =
    try {
      eertreeBuild(Some("abba"), 4) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == 4 && eertreeLongestLength(Some(t)) == 4
      }
    } catch { case _: Throwable => false }

  def testAlgoA10NodeCountInvariant(): Boolean =
    try {
      val cases = List(("racecar", 7), ("aabbaa", 6), ("abcbaabcba", 10), ("zzzzzzzzz", 9))
      val ok = cases.forall { case (s, len) =>
        eertreeBuild(Some(s), len) match {
          case None => false
          case Some(t) =>
            val d = eertreeCountDistinct(Some(t))
            d <= len && d > 0
        }
      }
      ok && (eertreeBuild(Some("racecar"), 7) match {
        case None => false
        case Some(t) => eertreeCountDistinct(Some(t)) == 7
      })
    } catch { case _: Throwable => false }

  // ==========================================================================
  // Algorithm B: eertreeCountOccurrences
  // ==========================================================================

  def testAlgoB01SingleCharOccurrences(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("a"), 1) == 4
      }
    } catch { case _: Throwable => false }

  def testAlgoB02EvenPalindromeOccurrences(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("aa"), 2) == 2
      }
    } catch { case _: Throwable => false }

  def testAlgoB03FullStringPalindrome(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("aabaa"), 5) == 1
      }
    } catch { case _: Throwable => false }

  def testAlgoB04PatternNotInString(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("xyz"), 3) == 0
      }
    } catch { case _: Throwable => false }

  def testAlgoB05PatternNotAPalindrome(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("ab"), 2) == 0
      }
    } catch { case _: Throwable => false }

  def testAlgoB06OverlappingEvenPalindromes(): Boolean =
    try {
      // "aaaa": "aa" appears 3 times (overlapping: [0..1],[1..2],[2..3])
      eertreeBuild(Some("aaaa"), 4) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("aa"), 2) == 3
      }
    } catch { case _: Throwable => false }

  def testAlgoB07AllSameSingleChar(): Boolean =
    try {
      eertreeBuild(Some("aaaa"), 4) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("a"), 1) == 4
      }
    } catch { case _: Throwable => false }

  def testAlgoB08RepeatedPalindrome(): Boolean =
    try {
      // "abacaba": "aba" appears at [0..2] and [4..6] = 2 times
      eertreeBuild(Some("abacaba"), 7) match {
        case None => false
        case Some(t) => eertreeCountOccurrences(Some(t), Some("aba"), 3) == 2
      }
    } catch { case _: Throwable => false }

  def testAlgoB09NullArguments(): Boolean =
    try {
      eertreeBuild(Some("aabaa"), 5) match {
        case None => false
        case Some(t) =>
          eertreeCountOccurrences(None, Some("a"), 1) == 0 &&
            eertreeCountOccurrences(Some(t), None, 1) == 0 &&
            eertreeCountOccurrences(Some(t), Some("a"), 0) == 0 &&
            eertreeCountOccurrences(None, None, 0) == 0
      }
    } catch { case _: Throwable => false }

  def testAlgoB10StressTest(): Boolean =
    try {
      val n = 50000
      val s = "a" * n
      eertreeBuild(Some(s), n) match {
        case None => false
        case Some(t) =>
          eertreeCountDistinct(Some(t)) == n &&
            eertreeLongestLength(Some(t)) == n &&
            eertreeCountOccurrences(Some(t), Some("a"), 1) == n &&
            eertreeCountOccurrences(Some(t), Some("aa"), 2) == n - 1
      }
    } catch { case _: Throwable => false }

  val tests: List[TestCase] = List(
    ("Test A01 (Basic - aabaa)", () => testAlgoA01BasicAabaa()),
    ("Test A02 (Single Char)", () => testAlgoA02SingleChar()),
    ("Test A03 (All Same Chars - aaaa)", () => testAlgoA03AllSameChars()),
    ("Test A04 (No Internal Palindromes)", () => testAlgoA04NoInternalPalindromes()),
    ("Test A05 (Empty String)", () => testAlgoA05EmptyString()),
    ("Test A06 (NULL Input)", () => testAlgoA06NullInput()),
    ("Test A07 (Two-Char Palindrome - aa)", () => testAlgoA07TwoCharPalindrome()),
    ("Test A08 (Classic - abacaba)", () => testAlgoA08Abacaba()),
    ("Test A09 (Even Palindrome - abba)", () => testAlgoA09Abba()),
    ("Test A10 (Node Count Invariant)", () => testAlgoA10NodeCountInvariant()),
    ("Test B01 (Single Char Count)", () => testAlgoB01SingleCharOccurrences()),
    ("Test B02 (Even Palindrome Count)", () => testAlgoB02EvenPalindromeOccurrences()),
    ("Test B03 (Full String Palindrome)", () => testAlgoB03FullStringPalindrome()),
    ("Test B04 (Pattern Not In String)", () => testAlgoB04PatternNotInString()),
    ("Test B05 (Pattern Not A Palindrome)", () => testAlgoB05PatternNotAPalindrome()),
    ("Test B06 (Overlapping Even Palindromes)", () => testAlgoB06OverlappingEvenPalindromes()),
    ("Test B07 (All Same - Single Char)", () => testAlgoB07AllSameSingleChar()),
    ("Test B08 (Repeated Palindrome - aba)", () => testAlgoB08RepeatedPalindrome()),
    ("Test B09 (NULL Arguments)", () => testAlgoB09NullArguments()),
    ("Test B10 (Stress Test 50k chars)", () => testAlgoB10StressTest())
  )

  def main(args: Array[String]): Unit = {
    println("=== START ===")
    println()
    println("--- Algorithm A: Palindrome Tree Construction & Structural Queries ---")

    val algoATests = tests.take(10)
    val algoBTests = tests.drop(10)

    val resultsA = algoATests.map { case (name, test) => check(name)(test()) }

    println()
    println("--- Algorithm B: Occurrence Counting ---")

    val resultsB = algoBTests.map { case (name, test) => check(name)(test()) }

    val results = resultsA ++ resultsB
    val totalTests = tests.length
    val passedCount = results.count(identity)
    val failedCount = totalTests - passedCount
    val failedTests = tests.zip(results).collect { case ((name, _), false) => name }

    println()
    println("=== BENCHMARK RESULTS ===")
    println("Completed " + totalTests + " tests.")
    println("Passed: " + passedCount)
    println("Failed: " + failedCount)

    if (results.forall(identity)) {
      sys.exit(0)
    } else {
      println("Tests that failed:")
      failedTests.foreach(name => println(" - " + name))
      sys.exit(1)
    }
  }
}
