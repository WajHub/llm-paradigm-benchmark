# Test 2

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a Palindrome Tree (also known as Eertree) data structure in C using the header
file palindrome_tree.h. The Eertree is a linear-time data structure that implicitly
represents all distinct palindromic substrings of a string. It was introduced by
Mikhail Rubinchik and Arseny M. Shur in 2014.

- Implement `eertree_build`: Build the palindrome tree for a given string of length `len`
  in O(n) time. The tree must include two imaginary root nodes at indices 0 and 1:
  root 0 has len = -1 (the "odd root"), root 1 has len = 0 (the "even root").
  After building, propagate occurrence counts from longer palindromes to shorter ones
  by traversing nodes in decreasing order of `len` and adding each node's `cnt` to
  its suffix_link's `cnt`. The final `cnt` of each node must equal the total number
  of times that palindrome appears as a substring in the input.

- Implement `eertree_count_distinct`: Return the number of distinct palindromic
  substrings (i.e., the number of real nodes, excluding the two imaginary roots).

- Implement `eertree_count_occurrences`: Find the node in the tree whose palindrome
  matches `pattern` (using `end_pos` to locate the substring in the stored string)
  and return its propagated `cnt`. Return 0 if pattern is not found, not a palindrome,
  or any argument is NULL.

- Implement `eertree_longest_length`: Return the maximum `len` among all real nodes.

- Implement `eertree_free`: Free all dynamically allocated memory (nodes array, str).
  Must not leak memory (verified by valgrind).

Constraints:
  - Input strings contain only lowercase Latin letters ('a'..'z').
  - `eertree_build(NULL, n)` must return NULL.
  - `eertree_build(s, 0)` must return a valid Eertree with only the two imaginary roots.
  - All query functions must return 0 (or NULL) on NULL input without crashing.
```
