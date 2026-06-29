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
