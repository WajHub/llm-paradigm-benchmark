# Test 3

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a Palindrome Tree (also known as Eertree) data structure in GNU Smalltalk by
subclassing PalindromeTree as PalindromeTreeImpl. The Eertree is a linear-time data
structure that implicitly represents all distinct palindromic substrings of a string. It
was introduced by Mikhail Rubinchik and Arseny M. Shur in 2014.

- Implement `eertreeBuild: aString length: len`: Build the palindrome tree for aString of
  length len. Return an Eertree object holding the nodes (each an EertreeNode with len,
  suffixLink, children, cnt, endPos). The tree must include two imaginary root nodes at
  indices 0 and 1: root 0 has len = -1 (the "odd root"), root 1 has len = 0 (the "even
  root"). After building, propagate occurrence counts from longer palindromes to shorter
  ones by traversing nodes in decreasing order of len and adding each node's cnt to its
  suffixLink's cnt. The final cnt of each node must equal the total number of times that
  palindrome appears as a substring in the input. Return nil if aString is nil and len > 0.

- Implement `eertreeCountDistinct: tree`: Answer the number of distinct palindromic
  substrings (i.e., the number of real nodes, excluding the two imaginary roots).

- Implement `eertreeCountOccurrences: tree pattern: pattern length: plen`: Find the node
  in the tree whose palindrome matches pattern (using endPos to locate the substring in
  the stored string) and answer its propagated cnt. Answer 0 if the pattern is not found,
  not a palindrome, or any argument is nil.

- Implement `eertreeLongestLength: tree`: Answer the maximum len among all real nodes.

Constraints:
  - Input strings contain only lowercase Latin letters ('a'..'z').
  - `eertreeBuild: nil length: n` with n > 0 must answer nil.
  - `eertreeBuild: '' length: 0` must produce a valid Eertree with only the two imaginary
    roots.
  - All query methods must answer 0 on nil input without raising an error.
  - Keep the contract (data classes and the PalindromeTree base class) in
    `PalindromeTree.st`; put the implementation in `PalindromeTreeImpl.st`.
  - Use idiomatic GNU Smalltalk.
```
