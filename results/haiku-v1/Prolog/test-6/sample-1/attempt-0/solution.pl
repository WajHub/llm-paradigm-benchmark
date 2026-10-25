:- module(sudoku, [
    sudoku_is_valid/1,
    sudoku_candidates/4,
    sudoku_solve/2,
    sudoku_count_solutions/3
]).

% Grid representation:
%   a flat list of 81 integers in row-major order (Index = Row * 9 + Col),
%   0 = empty cell. Boxes are the nine 3x3 blocks starting at rows/cols 0, 3, 6.
%
% Internally the grid is converted to a compound b/81 so that cells can be
% accessed in O(1) with arg/3 and updated with setarg/3 on a copy.

% sudoku_is_valid(+Grid)
sudoku_is_valid(Grid) :-
    is_list(Grid),
    length(Grid, 81),
    maplist(digit_ok, Grid),
    to_board(Grid, B),
    \+ (
        between(0, 80, I),
        N is I + 1,
        arg(N, B, V),
        V =\= 0,
        I1 is I + 1,
        between(I1, 80, J),
        peer(I, J),
        M is J + 1,
        arg(M, B, V)
    ).

digit_ok(V) :-
    integer(V),
    V >= 0,
    V =< 9.

% sudoku_candidates(+Grid, +Row, +Col, -Digits)
sudoku_candidates(Grid, Row, Col, Digits) :-
    I is Row * 9 + Col,
    to_board(Grid, B),
    N is I + 1,
    arg(N, B, V),
    (   V =\= 0
    ->  Digits = []
    ;   cands(B, I, Digits)
    ).

% sudoku_solve(+Grid, -Solution)
sudoku_solve(Grid, Solution) :-
    (   sudoku_is_valid(Grid),
        to_board(Grid, B),
        solve_one(B, S)
    ->  board_list(S, Solution)
    ;   Solution = none
    ).

% sudoku_count_solutions(+Grid, +Limit, -Count)
sudoku_count_solutions(Grid, Limit, Count) :-
    (   Limit =< 0
    ->  Count = 0
    ;   sudoku_is_valid(Grid)
    ->  to_board(Grid, B),
        count_sol(B, Limit, 0, Count)
    ;   Count = 0
    ).

% --- Board conversion -------------------------------------------------------

to_board(Grid, B) :-
    B =.. [b|Grid].

board_list(B, L) :-
    B =.. [_|L].

% --- Peers and candidates ---------------------------------------------------

% peer(+I, +J): cells I and J (0-based) share a row, column or box.
% Does not hold for I == J in the sense that it is true for it too; callers
% exclude J =:= I explicitly where needed.
peer(I, J) :-
    R1 is I // 9, C1 is I mod 9,
    R2 is J // 9, C2 is J mod 9,
    (   R1 =:= R2
    ;   C1 =:= C2
    ;   R1 // 3 =:= R2 // 3,
        C1 // 3 =:= C2 // 3
    ).

% cands(+Board, +I, -Digits): digits 1..9 not used by peers of cell I.
cands(B, I, Ds) :-
    findall(V,
            ( between(0, 80, J),
              J =\= I,
              peer(I, J),
              N is J + 1,
              arg(N, B, V)
            ),
            Vs),
    findall(D,
            ( between(1, 9, D),
              \+ memberchk(D, Vs)
            ),
            Ds).

% --- Minimum remaining values -----------------------------------------------

% mrv(+Board, -Result)
%   Result = solved if no empty cell remains,
%   Result = cell(I, Ds) for the empty cell with fewest candidates,
%   fails if some empty cell has no candidates (dead end).
mrv(B, R) :-
    mrv_(0, B, solved, R).

mrv_(81, _, R, R) :- !.
mrv_(I, B, R0, R) :-
    N is I + 1,
    arg(N, B, V),
    (   V =\= 0
    ->  R1 = R0
    ;   cands(B, I, Ds),
        Ds \== [],
        (   R0 == solved
        ->  R1 = cell(I, Ds)
        ;   R0 = cell(_, D0),
            length(D0, L0),
            length(Ds, L),
            (   L < L0
            ->  R1 = cell(I, Ds)
            ;   R1 = R0
            )
        )
    ),
    I1 is I + 1,
    mrv_(I1, B, R1, R).

% --- Search -----------------------------------------------------------------

% solve_one(+Board, -Solution): first completion found, deterministic overall.
solve_one(B, Out) :-
    mrv(B, R),
    (   R == solved
    ->  Out = B
    ;   R = cell(I, Ds),
        member(D, Ds),
        duplicate_term(B, B2),
        N is I + 1,
        setarg(N, B2, D),
        solve_one(B2, Out)
    ).

% count_sol(+Board, +Limit, +Acc0, -Acc): count solutions up to Limit.
count_sol(B, Limit, A0, A) :-
    (   mrv(B, R)
    ->  (   R == solved
        ->  A is A0 + 1
        ;   R = cell(I, Ds),
            branch(Ds, I, B, Limit, A0, A)
        )
    ;   A = A0
    ).

branch([], _, _, _, A, A).
branch([D|Ds], I, B, Limit, A0, A) :-
    (   A0 >= Limit
    ->  A = A0
    ;   duplicate_term(B, B2),
        N is I + 1,
        setarg(N, B2, D),
        count_sol(B2, Limit, A0, A1),
        branch(Ds, I, B, Limit, A1, A)
    ).
