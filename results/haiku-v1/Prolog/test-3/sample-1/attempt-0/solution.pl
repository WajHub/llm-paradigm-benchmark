:- module(palindrome_tree, [
    eertree_build/3,
    eertree_count_distinct/2,
    eertree_count_occurrences/4,
    eertree_longest_length/2
]).

:- use_module(library(assoc)).

% Eertree (palindrome tree) representation: eertree(Nodes, Size, Last, Str, StrLen)
% where Nodes is a list of node(Len, SuffixLink, Children, Cnt, EndPos) terms
% (index 0 = odd root with Len = -1, index 1 = even root with Len = 0),
% Children is a list of Letter-Index pairs, Str is the stored input atom and
% StrLen its length.

eertree_build(none, _, none) :- !.
eertree_build(Str, Len, eertree(Nodes, Size, Last, Str, Len)) :-
    atom(Str), integer(Len), Len >= 0,
    empty_assoc(A0),
    put_assoc(0, A0, node(-1, 0, [], 0, none), A1),
    put_assoc(1, A1, node(0, 0, [], 0, none), A2),
    build(0, Len, Str, st(A2, 2, 1), st(A3, Size, Last)),
    propagate_all(A3, A4),
    assoc_to_values(A4, Nodes).

build(I, N, Str, S0, S) :-
    (   I >= N
    ->  S = S0
    ;   step(I, Str, S0, S1),
        I1 is I + 1,
        build(I1, N, Str, S1, S)
    ).

step(I, Str, st(A0, Size0, Last0), st(A, Size, Last)) :-
    sub_atom(Str, I, 1, _, C),
    find_suffix(A0, Last0, I, Str, C, Cur),
    get_assoc(Cur, A0, node(_, _, Ch, _, _)),
    (   memberchk(C-Child, Ch)
    ->  get_assoc(Child, A0, node(L, Lk, CCh, Cnt, E)),
        Cnt1 is Cnt + 1,
        put_assoc(Child, A0, node(L, Lk, CCh, Cnt1, E), A),
        Size = Size0,
        Last = Child
    ;   get_assoc(Cur, A0, node(CLen, CLink, _, _, _)),
        NewLen is CLen + 2,
        (   NewLen =:= 1
        ->  Link = 1
        ;   find_suffix(A0, CLink, I, Str, C, W),
            get_assoc(W, A0, node(_, _, WCh, _, _)),
            memberchk(C-Link, WCh)
        ),
        New = Size0,
        put_assoc(New, A0, node(NewLen, Link, [], 1, I), A1),
        get_assoc(Cur, A1, node(CL, CK, CCh, CC, CE)),
        put_assoc(Cur, A1, node(CL, CK, [C-New|CCh], CC, CE), A),
        Size is Size0 + 1,
        Last = New
    ).

% find_suffix(+Assoc, +Node, +I, +Str, +C, -Cur):
% walk suffix links from Node until a palindromic suffix extendable by C at I.
find_suffix(A, Node, I, Str, C, Cur) :-
    get_assoc(Node, A, node(L, Lk, _, _, _)),
    J is I - L - 1,
    (   J >= 0,
        sub_atom(Str, J, 1, _, C)
    ->  Cur = Node
    ;   find_suffix(A, Lk, I, Str, C, Cur)
    ).

propagate_all(A0, A) :-
    assoc_to_list(A0, Pairs),
    findall(NL-K,
            ( member(K-node(L, _, _, _, _), Pairs),
              K >= 2,
              NL is -L
            ),
            Keyed),
    keysort(Keyed, Sorted),
    propagate(Sorted, A0, A).

propagate([], A, A).
propagate([_-K|T], A0, A) :-
    get_assoc(K, A0, node(_, Lk, _, Cnt, _)),
    get_assoc(Lk, A0, node(LL, LLk, LC, LCnt, LE)),
    LCnt1 is LCnt + Cnt,
    put_assoc(Lk, A0, node(LL, LLk, LC, LCnt1, LE), A1),
    propagate(T, A1, A).

eertree_count_distinct(none, 0) :- !.
eertree_count_distinct(eertree(_, Size, _, _, _), Count) :-
    Count is Size - 2.

eertree_count_occurrences(eertree(Nodes, _, _, Str, _), Pattern, PLen, Count) :-
    atom(Pattern), Pattern \== none, integer(PLen), !,
    (   nth0(K, Nodes, node(L, _, _, C, E)),
        K >= 2,
        L =:= PLen,
        Start is E - L + 1,
        sub_atom(Str, Start, L, _, Pattern)
    ->  Count = C
    ;   Count = 0
    ).
eertree_count_occurrences(_, _, _, 0).

eertree_longest_length(none, 0) :- !.
eertree_longest_length(eertree(Nodes, _, _, _, _), Length) :-
    drop_roots(Nodes, Real),
    (   Real == []
    ->  Length = 0
    ;   findall(L, member(node(L, _, _, _, _), Real), Ls),
        max_list(Ls, Length)
    ).

drop_roots([_, _ | Rest], Rest) :- !.
drop_roots(_, []).
