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
    ("test_algo_a_01_basic_aabaa", () => testAlgoA01BasicAabaa()),
    ("test_algo_a_02_single_char", () => testAlgoA02SingleChar()),
    ("test_algo_a_03_all_same_chars", () => testAlgoA03AllSameChars()),
    ("test_algo_a_04_no_internal_palindromes", () => testAlgoA04NoInternalPalindromes()),
    ("test_algo_a_05_empty_string", () => testAlgoA05EmptyString()),
    ("test_algo_a_06_null_input", () => testAlgoA06NullInput()),
    ("test_algo_a_07_two_char_palindrome", () => testAlgoA07TwoCharPalindrome()),
    ("test_algo_a_08_abacaba", () => testAlgoA08Abacaba()),
    ("test_algo_a_09_abba", () => testAlgoA09Abba()),
    ("test_algo_a_10_node_count_invariant", () => testAlgoA10NodeCountInvariant()),
    ("test_algo_b_01_single_char_occurrences", () => testAlgoB01SingleCharOccurrences()),
    ("test_algo_b_02_even_palindrome_occurrences", () => testAlgoB02EvenPalindromeOccurrences()),
    ("test_algo_b_03_full_string_palindrome", () => testAlgoB03FullStringPalindrome()),
    ("test_algo_b_04_pattern_not_in_string", () => testAlgoB04PatternNotInString()),
    ("test_algo_b_05_pattern_not_a_palindrome", () => testAlgoB05PatternNotAPalindrome()),
    ("test_algo_b_06_overlapping_even_palindromes", () => testAlgoB06OverlappingEvenPalindromes()),
    ("test_algo_b_07_all_same_single_char", () => testAlgoB07AllSameSingleChar()),
    ("test_algo_b_08_repeated_palindrome", () => testAlgoB08RepeatedPalindrome()),
    ("test_algo_b_09_null_arguments", () => testAlgoB09NullArguments()),
    ("test_algo_b_10_stress_test", () => testAlgoB10StressTest())
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
