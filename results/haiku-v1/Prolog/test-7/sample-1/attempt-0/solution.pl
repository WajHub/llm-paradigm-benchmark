:- module(sequence_alignment, [
    alignment_score/7,
    alignment_align/7
]).

:- use_module(library(assoc)).

% Global alignment of two sequences with an affine gap penalty (Gotoh).
%
% Three DP tables per cell (i,j), stored as c(M,X,Y):
%   M : best score of prefixes A[1..i], B[1..j] whose last column pairs A_i with B_j
%   X : last column is A_i over a gap ('-' in B)
%   Y : last column is a gap ('-' in A) over B_j
% Transitions allow X->Y and Y->X directly (a gap followed by a gap in the
% other row), each paying its own opening cost.

alignment_score(A, B, MS, MI, GO, GE, Score) :-
    atom_chars(A, As),
    atom_chars(B, Bs),
    P = p(MS, MI, GO, GE),
    fill(As, Bs, P, Rows),
    last(Rows, Last),
    last(Last, c(M, X, Y)),
    Score is max(M, max(X, Y)).

alignment_align(A, B, MS, MI, GO, GE, alignment(Score, AO, BO)) :-
    atom_chars(A, As),
    atom_chars(B, Bs),
    P = p(MS, MI, GO, GE),
    fill(As, Bs, P, Rows),
    rows_pairs(Rows, 0, Pairs, []),
    list_to_assoc(Pairs, Tab),
    length(As, N),
    length(Bs, Mlen),
    get_assoc(N-Mlen, Tab, c(M, X, Y)),
    Score is max(M, max(X, Y)),
    start_state(M, X, Y, Score, St),
    reverse(As, RA),
    reverse(Bs, RB),
    trace(St, N, Mlen, RA, RB, Tab, P, [], [], AL, BL),
    atom_chars(AO, AL),
    atom_chars(BO, BL).

% ---------------------------------------------------------------- DP fill

neg_inf(-1000000000000000).

score(A, B, p(MS, MI, _, _), Sc) :-
    (   A == B
    ->  Sc = MS
    ;   Sc is -MI
    ).

fill(As, Bs, P, Rows) :-
    row0(Bs, P, Row0),
    fill_rows(As, Bs, P, Row0, [Row0], Rev),
    reverse(Rev, Rows).

fill_rows([], _, _, _, Acc, Acc).
fill_rows([A|As], Bs, P, Prev, Acc, Rows) :-
    fill_row(Bs, A, Prev, P, Row),
    fill_rows(As, Bs, P, Row, [Row|Acc], Rows).

% Row 0: only gaps in A (Y states) are possible.
row0(Bs, P, [c(0, N, N)|Rest]) :-
    neg_inf(N),
    row0_(Bs, c(0, N, N), P, Rest).

row0_([], _, _, []).
row0_([_|Bs], c(Mp, Xp, Yp), p(_, _, GO, GE), [c(N, N, Y)|Rest]) :-
    neg_inf(N),
    C is GO + GE,
    Y is max(Mp - C, max(Yp - GE, Xp - C)),
    row0_(Bs, c(N, N, Y), p(_, _, GO, GE), Rest).

% Row i >= 1 given the previous row.
fill_row(Bs, A, [P0|Prev], P, [Cell0|Rest]) :-
    P = p(_, _, GO, GE),
    C is GO + GE,
    P0 = c(Mp, Xp, Yp),
    neg_inf(N),
    X0 is max(Mp - C, max(Xp - GE, Yp - C)),
    Cell0 = c(N, X0, N),
    row_step(Bs, A, [P0|Prev], Cell0, P, Rest).

% PrevList = [prev(j-1), prev(j), ...]; Left = cell(i, j-1).
row_step([], _, _, _, _, []).
row_step([B|Bs], A, [PD, PU|PRest], c(Ml, Xl, Yl), P, [c(Mc, Xc, Yc)|Cells]) :-
    P = p(_, _, GO, GE),
    C is GO + GE,
    PD = c(Md, Xd, Yd),
    PU = c(Mu, Xu, Yu),
    score(A, B, P, Sc),
    Mc is Sc + max(Md, max(Xd, Yd)),
    Xc is max(Mu - C, max(Xu - GE, Yu - C)),
    Yc is max(Ml - C, max(Yl - GE, Xl - C)),
    row_step(Bs, A, [PU|PRest], c(Mc, Xc, Yc), P, Cells).

% ---------------------------------------------------------- table access

rows_pairs([], _, Ps, Ps).
rows_pairs([R|Rs], I, Ps, Tail) :-
    row_pairs(R, I, 0, Ps, Ps1),
    I1 is I + 1,
    rows_pairs(Rs, I1, Ps1, Tail).

row_pairs([], _, _, Ps, Ps).
row_pairs([C|Cs], I, J, [(I-J)-C|Ps], Tail) :-
    J1 is J + 1,
    row_pairs(Cs, I, J1, Ps, Tail).

% ------------------------------------------------------------- traceback

start_state(M, _, _, S, m) :- M =:= S, !.
start_state(_, X, _, S, x) :- X =:= S, !.
start_state(_, _, _, _, y).

% trace(+State, +I, +J, +RevA, +RevB, +Tab, +P, +AccA, +AccB, -OutA, -OutB)
% RevA is A[1..I] reversed (head = A_I); RevB likewise. Columns are emitted
% from the end backwards and prepended, so the accumulators end up in order.

trace(m, 0, 0, _, _, _, _, AA, BA, AA, BA) :- !.
trace(m, I, J, [A|RA], [B|RB], Tab, P, AA, BA, AO, BO) :-
    get_assoc(I-J, Tab, c(M, _, _)),
    score(A, B, P, Sc),
    Prev is M - Sc,
    I1 is I - 1,
    J1 is J - 1,
    get_assoc(I1-J1, Tab, c(Md, Xd, _Yd)),
    (   Md =:= Prev
    ->  Next = m
    ;   Xd =:= Prev
    ->  Next = x
    ;   Next = y
    ),
    trace(Next, I1, J1, RA, RB, Tab, P, [A|AA], [B|BA], AO, BO).
trace(x, I, J, [A|RA], RB, Tab, P, AA, BA, AO, BO) :-
    P = p(_, _, GO, GE),
    C is GO + GE,
    get_assoc(I-J, Tab, c(_, X, _)),
    I1 is I - 1,
    get_assoc(I1-J, Tab, c(Mu, Xu, _Yu)),
    (   X =:= Xu - GE
    ->  Next = x
    ;   X =:= Mu - C
    ->  Next = m
    ;   Next = y
    ),
    trace(Next, I1, J, RA, RB, Tab, P, [A|AA], ['-'|BA], AO, BO).
trace(y, I, J, RA, [B|RB], Tab, P, AA, BA, AO, BO) :-
    P = p(_, _, GO, GE),
    C is GO + GE,
    get_assoc(I-J, Tab, c(_, _, Y)),
    J1 is J - 1,
    get_assoc(I-J1, Tab, c(Ml, Xl, Yl)),
    (   Y =:= Yl - GE
    ->  Next = y
    ;   Y =:= Ml - C
    ->  Next = m
    ;   Next = x
    ),
    trace(Next, I, J1, RA, RB, Tab, P, ['-'|AA], [B|BA], AO, BO).
</br>
