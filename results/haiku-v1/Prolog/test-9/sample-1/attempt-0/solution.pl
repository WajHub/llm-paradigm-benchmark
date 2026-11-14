:- module(btree, [
    btree_insert_all/3,
    btree_delete_all/4
]).

% CLRS B-tree with minimum degree T (T >= 2).
%
% Tree representation:
%   node(Keys, Children)
%     Keys     - proper list of integers in strictly ascending order
%     Children - [] for a leaf; otherwise a list of exactly length(Keys) + 1
%                node/2 terms
%   The empty tree is node([], []) (a root leaf without keys).
%   Every node holds at most 2T-1 keys, every non-root node at least T-1.
%
% btree_insert_all(+T, +Keys, -Tree)
%   Tree is obtained by inserting Keys one by one, in order, into the empty
%   tree with CLRS top-down insertion (pre-emptive splitting, median index T-1).
%   Keys already present are ignored (tree unchanged). Tree = none if T < 2.
%
% btree_delete_all(+T, +Keys, +Deletions, -Tree)
%   Builds the tree exactly like btree_insert_all(T, Keys, _), then deletes
%   every key of Deletions in order with CLRS single-pass top-down deletion.
%   Keys that are not in the tree leave it unchanged. Tree = none if T < 2.

btree_insert_all(T, Keys, Tree) :-
    (   T < 2
    ->  Tree = none
    ;   foldl(insert_key(T), Keys, node([], []), Tree)
    ).

btree_delete_all(T, Keys, Deletions, Tree) :-
    (   T < 2
    ->  Tree = none
    ;   foldl(insert_key(T), Keys, node([], []), Tree0),
        foldl(delete_key(T), Deletions, Tree0, Tree)
    ).

% ---------------------------------------------------------------- helpers

replace_nth(I, L, E, L2) :-
    nth0(I, L, _, R),
    nth0(I, L2, E, R).

% count_less(+K, +SortedKeys, -N): number of keys strictly less than K
count_less(_, [], 0).
count_less(K, [X|Xs], N) :-
    (   X < K
    ->  count_less(K, Xs, N0),
        N is N0 + 1
    ;   N = 0
    ).

member_key(K, node(Ks, Cs)) :-
    (   memberchk(K, Ks)
    ->  true
    ;   Cs \== [],
        count_less(K, Ks, I),
        nth0(I, Cs, C),
        member_key(K, C)
    ).

max_key(node(Ks, Cs), K) :-
    (   Cs == []
    ->  last(Ks, K)
    ;   last(Cs, C),
        max_key(C, K)
    ).

min_key(node(Ks, Cs), K) :-
    (   Cs == []
    ->  Ks = [K|_]
    ;   Cs = [C|_],
        min_key(C, K)
    ).

% ---------------------------------------------------------------- insertion

insert_key(T, K, R0, R) :-
    (   member_key(K, R0)
    ->  R = R0
    ;   R0 = node(Ks, _),
        length(Ks, N),
        (   N =:= 2*T - 1
        ->  split_child(T, [], [R0], 0, SKs, SCs, _),
            ins_nonfull(T, node(SKs, SCs), K, R)
        ;   ins_nonfull(T, R0, K, R)
        )
    ).

% split_child(+T, +ParentKeys, +ParentChildren, +I, -NewKeys, -NewChildren, -Median)
split_child(T, Ks, Cs, I, SKs, SCs, M) :-
    nth0(I, Cs, node(YKs, YCs)),
    LN is T - 1,
    length(LKs, LN),
    append(LKs, [M|RKs], YKs),
    (   YCs == []
    ->  LCs = [], RCs = []
    ;   length(LCs, T),
        append(LCs, RCs, YCs)
    ),
    length(PKs, I),
    append(PKs, KSuf, Ks),
    append(PKs, [M|KSuf], SKs),
    length(PCs, I),
    append(PCs, [_|CSuf], Cs),
    append(PCs, [node(LKs, LCs), node(RKs, RCs)|CSuf], SCs).

insert_sorted(K, Ks, NKs) :-
    count_less(K, Ks, I),
    length(P, I),
    append(P, S, Ks),
    append(P, [K|S], NKs).

ins_nonfull(_, node(Ks, []), K, node(NKs, [])) :-
    insert_sorted(K, Ks, NKs).
ins_nonfull(T, node(Ks, Cs), K, node(NKs, NCs)) :-
    Cs \== [],
    count_less(K, Ks, I),
    nth0(I, Cs, node(CKs, _)),
    length(CKs, N),
    (   N =:= 2*T - 1
    ->  split_child(T, Ks, Cs, I, SKs, SCs, M),
        (   K < M
        ->  J = I
        ;   J is I + 1
        )
    ;   SKs = Ks, SCs = Cs, J = I
    ),
    nth0(J, SCs, Child),
    ins_nonfull(T, Child, K, NewChild),
    replace_nth(J, SCs, NewChild, NCs),
    NKs = SKs.

% ---------------------------------------------------------------- deletion

delete_key(T, K, R0, R) :-
    (   member_key(K, R0)
    ->  del(T, K, R0, R1),
        shrink_root(R1, R)
    ;   R = R0
    ).

shrink_root(node([], [C]), C) :- !.
shrink_root(R, R).

% del(+T, +K, +Node, -NewNode): K is known to be in the subtree of Node.
del(_, K, node(Ks, []), node(Ks2, [])) :-
    !,
    select(K, Ks, Ks2).
del(T, K, node(Ks, Cs), New) :-
    nth0(I, Ks, K),
    !,
    del_internal(T, K, I, Ks, Cs, NKs, NCs),
    New = node(NKs, NCs).
del(T, K, node(Ks, Cs), node(NKs, NCs)) :-
    count_less(K, Ks, I),
    nth0(I, Cs, node(CKs, _)),
    length(CKs, N),
    (   N =:= T - 1
    ->  fix_child(T, Ks, Cs, I, Ks1, Cs1, I1)
    ;   Ks1 = Ks, Cs1 = Cs, I1 = I
    ),
    nth0(I1, Cs1, C1),
    del(T, K, C1, C2),
    replace_nth(I1, Cs1, C2, NCs),
    NKs = Ks1.

% K = Ks[I] in internal node.
del_internal(T, K, I, Ks, Cs, NKs, NCs) :-
    nth0(I, Cs, Y),
    I1 is I + 1,
    nth0(I1, Cs, Z),
    Y = node(YKs, _),
    Z = node(ZKs, _),
    length(YKs, NY),
    length(ZKs, NZ),
    (   NY >= T
    ->  max_key(Y, KP),
        del(T, KP, Y, Y2),
        replace_nth(I, Ks, KP, NKs),
        replace_nth(I, Cs, Y2, NCs)
    ;   NZ >= T
    ->  min_key(Z, KS),
        del(T, KS, Z, Z2),
        replace_nth(I, Ks, KS, NKs),
        replace_nth(I1, Cs, Z2, NCs)
    ;   Y = node(_, YCs),
        Z = node(_, ZCs),
        nth0(I, Ks, K, NKs),
        nth0(I1, Cs, _, Cs1),
        append(YKs, [K|ZKs], MKs),
        append(YCs, ZCs, MCs),
        replace_nth(I, Cs1, node(MKs, MCs), Cs2),
        del(T, K, node(MKs, MCs), M2),
        replace_nth(I, Cs2, M2, NCs)
    ).

% fix_child(+T, +Ks, +Cs, +I, -NKs, -NCs, -NI)
% Ensures child I has at least T keys (rotations or merge); NI is the index
% of the (possibly merged) child that contains the range of the deleted key.
fix_child(T, Ks, Cs, I, NKs, NCs, NI) :-
    (   I > 0,
        I1 is I - 1,
        nth0(I1, Cs, node(LKs, _)),
        length(LKs, NL),
        NL >= T
    ->  rot_right(I, Ks, Cs, NKs, NCs),
        NI = I
    ;   I2 is I + 1,
        I2 =< length(Ks),
        nth0(I2, Cs, node(RKs, _)),
        length(RKs, NR),
        NR >= T
    ->  rot_left(I, Ks, Cs, NKs, NCs),
        NI = I
    ;   I < length(Ks)
    ->  merge_right(I, Ks, Cs, NKs, NCs),
        NI = I
    ;   I1 is I - 1,
        merge_left(I, Ks, Cs, NKs, NCs),
        NI = I1
    ).

rot_right(I, Ks, Cs, NKs, NCs) :-
    I1 is I - 1,
    nth0(I1, Cs, node(LKs, LCs)),
    append(LKs0, [LKm], LKs),
    (   LCs == []
    ->  LCs0 = [], Move = []
    ;   append(LCs0, [LCm], LCs),
        Move = [LCm]
    ),
    nth0(I, Cs, node(CKs, CCs)),
    nth0(I1, Ks, S),
    replace_nth(I1, Ks, LKm, NKs),
    replace_nth(I1, Cs, node(LKs0, LCs0), Cs1),
    append(Move, CCs, NCCs),
    replace_nth(I, Cs1, node([S|CKs], NCCs), NCs).

rot_left(I, Ks, Cs, NKs, NCs) :-
    I2 is I + 1,
    nth0(I, Ks, S),
    nth0(I, Cs, node(CKs, CCs)),
    nth0(I2, Cs, node(RKs, RCs)),
    RKs = [RK1|RKs0],
    (   RCs == []
    ->  RCs0 = [], Move = []
    ;   RCs = [RC1|RCs0],
        Move = [RC1]
    ),
    replace_nth(I, Ks, RK1, NKs),
    append(CKs, [S], CKs2),
    append(CCs, Move, CCs2),
    replace_nth(I, Cs, node(CKs2, CCs2), Cs1),
    replace_nth(I2, Cs1, node(RKs0, RCs0), NCs).

merge_right(I, Ks, Cs, NKs, NCs) :-
    nth0(I, Ks, S, NKs),
    I2 is I + 1,
    nth0(I, Cs, node(CKs, CCs)),
    nth0(I2, Cs, node(RKs, RCs), Cs1),
    append(CKs, [S|RKs], MKs),
    append(CCs, RCs, MCs),
    replace_nth(I, Cs1, node(MKs, MCs), NCs).

merge_left(I, Ks, Cs, NKs, NCs) :-
    I1 is I - 1,
    nth0(I1, Ks, S, NKs),
    nth0(I1, Cs, node(LKs, LCs)),
    nth0(I, Cs, node(CKs, CCs), Cs1),
    append(LKs, [S|CKs], MKs),
    append(LCs, CCs, MCs),
    replace_nth(I1, Cs1, node(MKs, MCs), NCs).
