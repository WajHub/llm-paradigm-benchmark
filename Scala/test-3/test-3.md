# Test 3

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a Palindrome Tree (also known as Eertree) data structure in Scala using the
object PalindromeTree. The Eertree is a linear-time data structure that implicitly
represents all distinct palindromic substrings of a string. It was introduced by Mikhail
Rubinchik and Arseny M. Shur in 2014.

- Implement `eertreeBuild(s: Option[String], len: Int): Option[Eertree]`: Build the
  palindrome tree for string `s` of length `len`. Represent the tree as
  `Eertree(nodes, size, last, str, strLen)` where nodes is a Vector of
  `Node(len, suffixLink, children, cnt, endPos)`. The tree must include two imaginary root
  nodes at indices 0 and 1: root 0 has len = -1 (the "odd root"), root 1 has len = 0 (the
  "even root"). After building, propagate occurrence counts from longer palindromes to
  shorter ones by traversing nodes in decreasing order of len and adding each node's cnt
  to its suffixLink's cnt. The final cnt of each node must equal the total number of times
  that palindrome appears as a substring in the input.

- Implement `eertreeCountDistinct(t: Option[Eertree]): Int`: Return the number of distinct
  palindromic substrings (i.e., the number of real nodes, excluding the two imaginary
  roots).

- Implement `eertreeCountOccurrences(t: Option[Eertree], pattern: Option[String], plen: Int): Long`:
  Find the node in the tree whose palindrome matches `pattern` (using endPos to locate the
  substring in the stored string) and return its propagated cnt. Return 0 if the pattern is
  not found, not a palindrome, or any argument is None.

- Implement `eertreeLongestLength(t: Option[Eertree]): Int`: Return the maximum len among
  all real nodes.

Constraints:
  - Input strings contain only lowercase Latin letters ('a'..'z').
  - `eertreeBuild(None, n)` with n > 0 must return None.
  - `eertreeBuild(Some(""), 0)` must return a valid Eertree with only the two imaginary
    roots.
  - All query functions must return 0 on None input without throwing.
  - Keep the contract (case classes and signatures) in `PalindromeTree.scala`.
  - Use idiomatic Scala with immutable data structures.
```
