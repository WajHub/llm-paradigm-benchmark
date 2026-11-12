You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

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

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

:- module(palindrome_tree, [
    eertree_build/3,
    eertree_count_distinct/2,
    eertree_count_occurrences/4,
    eertree_longest_length/2
]).

% Eertree (palindrome tree) representation: eertree(Nodes, Size, Last, Str, StrLen)
% where Nodes is a list of node(Len, SuffixLink, Children, Cnt, EndPos) terms
% (index 0 = odd root with Len = -1, index 1 = even root with Len = 0),
% Children maps a letter to a child node index, Str is the stored input atom and
% StrLen its length.
%
% The input string is an atom of lowercase Latin letters ('a'..'z'), or the atom
% `none` to denote an absent (NULL) string. Absent trees/patterns are `none`.

eertree_build(_, _, _) :-
    throw(error(existence_error(procedure, eertree_build/3), _)).

eertree_count_distinct(_, _) :-
    throw(error(existence_error(procedure, eertree_count_distinct/2), _)).

eertree_count_occurrences(_, _, _, _) :-
    throw(error(existence_error(procedure, eertree_count_occurrences/4), _)).

eertree_longest_length(_, _) :-
    throw(error(existence_error(procedure, eertree_longest_length/2), _)).