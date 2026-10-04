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
% sudoku_is_valid(+Grid)
%   Succeeds iff Grid has exactly 81 elements, each an integer in 0..9, and no
%   digit 1..9 appears twice in any row, column or 3x3 box (zeros ignored).
%   Fails otherwise. Validity does not imply solvability.
%
% sudoku_candidates(+Grid, +Row, +Col, -Digits)
%   Row, Col are 0-based (0..8). Digits is the ascending list of digits 1..9
%   not present in that cell's row, column or 3x3 box; [] if the cell is filled.
%   Deterministic.
%
% sudoku_solve(+Grid, -Solution)
%   Solution is a complete valid 81-element list extending Grid, or the atom
%   `none` if Grid is invalid or has no solution. Deterministic.
%
% sudoku_count_solutions(+Grid, +Limit, -Count)
%   Count = min(number of solutions, Limit); 0 if Grid is invalid or Limit =< 0.

sudoku_is_valid(_) :-
    throw(error(existence_error(procedure, sudoku_is_valid/1), _)).

sudoku_candidates(_, _, _, _) :-
    throw(error(existence_error(procedure, sudoku_candidates/4), _)).

sudoku_solve(_, _) :-
    throw(error(existence_error(procedure, sudoku_solve/2), _)).

sudoku_count_solutions(_, _, _) :-
    throw(error(existence_error(procedure, sudoku_count_solutions/3), _)).
