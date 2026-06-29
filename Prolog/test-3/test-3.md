# Test 3

## Prompt - `TASK-SPECIFIC REQUIREMENTS`

```
Implement a Palindrome Tree (also known as Eertree) data structure in SWI-Prolog using
the module palindrome_tree. The Eertree is a linear-time data structure that implicitly
represents all distinct palindromic substrings of a string. It was introduced by Mikhail
Rubinchik and Arseny M. Shur in 2014.

- Implement `eertree_build(+String, +Len, -Tree)`: Build the palindrome tree for an atom
  `String` of length `Len`. Represent the tree as `eertree(Nodes, Size, Last, Str, StrLen)`
  where Nodes is a list of `node(Len, SuffixLink, Children, Cnt, EndPos)` terms. The tree
  must include two imaginary root nodes at indices 0 and 1: root 0 has Len = -1 (the "odd
  root"), root 1 has Len = 0 (the "even root"). After building, propagate occurrence
  counts from longer palindromes to shorter ones by traversing nodes in decreasing order
  of Len and adding each node's Cnt to its SuffixLink's Cnt. The final Cnt of each node
  must equal the total number of times that palindrome appears as a substring in the input.

- Implement `eertree_count_distinct(+Tree, -Count)`: Unify Count with the number of
  distinct palindromic substrings (i.e., the number of real nodes, excluding the two
  imaginary roots).

- Implement `eertree_count_occurrences(+Tree, +Pattern, +PLen, -Count)`: Find the node in
  the tree whose palindrome matches the atom `Pattern` (using EndPos to locate the
  substring in the stored string) and unify Count with its propagated Cnt. Count = 0 if
  the pattern is not found, not a palindrome, or any argument is `none`.

- Implement `eertree_longest_length(+Tree, -Length)`: Unify Length with the maximum Len
  among all real nodes.

Constraints:
  - Input strings are atoms containing only lowercase Latin letters ('a'..'z').
  - `eertree_build(none, N, Tree)` with N > 0 must unify Tree with `none`.
  - `eertree_build('', 0, Tree)` must produce a valid Eertree with only the two imaginary
    roots.
  - All query predicates must unify the count with 0 on `none` input without throwing.
  - Use the `none` atom for absent/null values.
  - Use idiomatic SWI-Prolog.
```
