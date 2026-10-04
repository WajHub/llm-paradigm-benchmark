:- use_module(sudoku).

run_test(Name, Goal, PassedCount0, PassedCount1, FailedTests0, FailedTests1) :-
    (   catch(call(Goal), _, fail)
    ->  format('[PASS] ~w~n', [Name]),
        PassedCount1 is PassedCount0 + 1,
        FailedTests1 = FailedTests0
    ;   format('[FAIL] ~w~n', [Name]),
        PassedCount1 = PassedCount0,
        FailedTests1 = [Name | FailedTests0]
    ).

% ===========================================================================
% Grids (row-major, 0 = empty)
% ===========================================================================

digits_grid(Atom, Grid) :-
    atom_codes(Atom, Codes0),
    exclude(==(0'\s), Codes0, Codes),
    maplist([C, D]>>(D is C - 0'0), Codes, Grid).

zeros(N, Grid) :-
    length(Grid, N),
    maplist(=(0), Grid).

empty_grid(G) :- zeros(81, G).

classic(G) :-
    digits_grid('530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079', G).

solved(G) :-
    digits_grid('534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179', G).

inkala(G) :-
    digits_grid('800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402', G).

inkala_sol(G) :-
    digits_grid('812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452', G).

anti_bf(G) :-
    digits_grid('000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009', G).

anti_bf_sol(G) :-
    digits_grid('987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219', G).

% set_cell(+Grid, +Row, +Col, +Value, -NewGrid)  (0-based Row/Col)
set_cell(Grid, Row, Col, Value, NewGrid) :-
    Index is Row * 9 + Col,
    nth0(Index, Grid, _, Rest),
    nth0(Index, NewGrid, Value, Rest).

% BOX_CONFLICT: CLASSIC with (1,1)=8 (clashes only with (2,2)=8 in box 0)
box_conflict(G) :- classic(C), set_cell(C, 1, 1, 8, G).

% BOX_CONFLICT2: EMPTY with (0,0)=1 and (1,1)=1
box_conflict2(G) :- empty_grid(E), set_cell(E, 0, 0, 1, G1), set_cell(G1, 1, 1, 1, G).

% ROW_CONFLICT: CLASSIC with (0,8)=5
row_conflict(G) :- classic(C), set_cell(C, 0, 8, 5, G).

% COL_CONFLICT: CLASSIC with (8,0)=5
col_conflict(G) :- classic(C), set_cell(C, 8, 0, 5, G).

% DEAD_CELL: EMPTY with row 0 = 1 2 3 4 5 6 7 8 0 and (4,8)=9
dead_cell(G) :-
    zeros(72, Rest),
    append([1, 2, 3, 4, 5, 6, 7, 8, 0], Rest, G0),
    set_cell(G0, 4, 8, 9, G).

% HIDDEN: CLASSIC with (0,2)=1 (valid, no solution)
hidden(G) :- classic(C), set_cell(C, 0, 2, 1, G).

% MULTI: CLASSIC with (2,2) cleared (exactly 8 solutions)
multi(G) :- classic(C), set_cell(C, 2, 2, 0, G).

candidates_are(Grid, Row, Col, Expected) :-
    sudoku_candidates(Grid, Row, Col, Digits),
    Digits == Expected.

solves_to(Grid, Expected) :-
    sudoku_solve(Grid, Solution),
    Solution == Expected.

no_solution(Grid) :-
    sudoku_solve(Grid, Solution),
    Solution == none.

count_is(Grid, Limit, Expected) :-
    sudoku_count_solutions(Grid, Limit, Count),
    Count == Expected.

% ===========================================================================
% Algorithm A: Validation and Candidates
% ===========================================================================

test_algo_a_01_empty_grid_valid :-
    empty_grid(E),
    sudoku_is_valid(E).

test_algo_a_02_solved_grid_valid :-
    solved(S), classic(C),
    sudoku_is_valid(S),
    sudoku_is_valid(C).

test_algo_a_03_row_conflict :-
    row_conflict(G), classic(C),
    \+ sudoku_is_valid(G),
    sudoku_is_valid(C).

test_algo_a_04_column_conflict :-
    col_conflict(G), classic(C),
    \+ sudoku_is_valid(G),
    sudoku_is_valid(C).

test_algo_a_05_box_only_conflict :-
    box_conflict(G1), box_conflict2(G2), classic(C),
    \+ sudoku_is_valid(G1),
    \+ sudoku_is_valid(G2),
    sudoku_is_valid(C).

test_algo_a_06_wrong_length :-
    zeros(80, Z80), zeros(82, Z82),
    solved(S), append(S, [0], S82),
    \+ sudoku_is_valid(Z80),
    \+ sudoku_is_valid(Z82),
    \+ sudoku_is_valid(S82),
    sudoku_is_valid(S).

test_algo_a_07_value_out_of_range :-
    classic(C),
    set_cell(C, 0, 2, 10, G1),
    set_cell(C, 0, 2, -1, G2),
    \+ sudoku_is_valid(G1),
    \+ sudoku_is_valid(G2),
    sudoku_is_valid(C).

test_algo_a_08_candidates_basic :-
    classic(C),
    candidates_are(C, 0, 2, [1, 2, 4]),
    candidates_are(C, 4, 4, [5]),
    candidates_are(C, 8, 0, [1, 2, 3]).

test_algo_a_09_candidates_edge_cells :-
    classic(C), empty_grid(E),
    candidates_are(C, 0, 0, []),
    candidates_are(C, 8, 8, []),
    candidates_are(E, 8, 8, [1, 2, 3, 4, 5, 6, 7, 8, 9]).

test_algo_a_10_candidates_sweep :-
    solved(S),
    forall(( between(0, 8, R), between(0, 8, C) ),
           (   Index is R * 9 + C,
               nth0(Index, S, Digit),
               set_cell(S, R, C, 0, G),
               candidates_are(G, R, C, [Digit])
           )),
    classic(Cl),
    aggregate_all(sum(Len),
                  (   between(0, 8, R), between(0, 8, C),
                      sudoku_candidates(Cl, R, C, Ds),
                      length(Ds, Len)
                  ),
                  Sum),
    Sum =:= 153.

% ===========================================================================
% Algorithm B: Solving
% ===========================================================================

test_algo_b_01_already_solved :-
    solved(S),
    solves_to(S, S).

test_algo_b_02_classic_puzzle :-
    classic(C), solved(S),
    solves_to(C, S),
    classic(C0),
    C == C0.

test_algo_b_03_invalid_grid :-
    box_conflict(BC), zeros(80, Z80),
    classic(C), set_cell(C, 0, 2, 10, Big),
    no_solution(BC),
    no_solution(Z80),
    no_solution(Big),
    count_is(BC, 5, 0),
    count_is(Z80, 5, 0).

test_algo_b_04_dead_cell :-
    dead_cell(G),
    no_solution(G),
    count_is(G, 5, 0).

test_algo_b_05_hidden_contradiction :-
    hidden(G),
    no_solution(G),
    count_is(G, 5, 0).

test_algo_b_06_backtracking_required :-
    inkala(G), inkala_sol(S),
    solves_to(G, S).

test_algo_b_07_count_unique :-
    classic(C), solved(S),
    count_is(C, 2, 1),
    count_is(S, 2, 1).

test_algo_b_08_count_multiple :-
    multi(M),
    count_is(M, 100, 8),
    count_is(M, 5, 5),
    count_is(M, 1, 1).

test_algo_b_09_count_empty_grid_limit :-
    empty_grid(E),
    count_is(E, 2, 2),
    count_is(E, 1, 1),
    count_is(E, 0, 0),
    count_is(E, -3, 0).

test_algo_b_10_stress_anti_brute_force :-
    anti_bf(G), anti_bf_sol(S),
    solves_to(G, S).

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Validation and Candidates ---'),
    AlgoATests = [
        'Test A01 (Empty Grid Valid)'-test_algo_a_01_empty_grid_valid,
        'Test A02 (Solved Grid Valid)'-test_algo_a_02_solved_grid_valid,
        'Test A03 (Row Conflict)'-test_algo_a_03_row_conflict,
        'Test A04 (Column Conflict)'-test_algo_a_04_column_conflict,
        'Test A05 (Box Only Conflict)'-test_algo_a_05_box_only_conflict,
        'Test A06 (Wrong Length)'-test_algo_a_06_wrong_length,
        'Test A07 (Value Out Of Range)'-test_algo_a_07_value_out_of_range,
        'Test A08 (Candidates Basic)'-test_algo_a_08_candidates_basic,
        'Test A09 (Candidates Edge Cells)'-test_algo_a_09_candidates_edge_cells,
        'Test A10 (Candidates Sweep)'-test_algo_a_10_candidates_sweep
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Solving ---'),
    AlgoBTests = [
        'Test B01 (Already Solved)'-test_algo_b_01_already_solved,
        'Test B02 (Classic Puzzle)'-test_algo_b_02_classic_puzzle,
        'Test B03 (Invalid Grid)'-test_algo_b_03_invalid_grid,
        'Test B04 (Dead Cell)'-test_algo_b_04_dead_cell,
        'Test B05 (Hidden Contradiction)'-test_algo_b_05_hidden_contradiction,
        'Test B06 (Backtracking Required)'-test_algo_b_06_backtracking_required,
        'Test B07 (Count Unique)'-test_algo_b_07_count_unique,
        'Test B08 (Count Multiple)'-test_algo_b_08_count_multiple,
        'Test B09 (Count Empty Grid Limit)'-test_algo_b_09_count_empty_grid_limit,
        'Test B10 (Stress Anti Brute Force)'-test_algo_b_10_stress_anti_brute_force
    ],
    run_all_tests(AlgoBTests, PassedA, FailedA, FailedARev, FailedTestsRev, PassedCount, FailedCount),
    reverse(FailedTestsRev, FailedTests),
    TotalTests is PassedCount + FailedCount,
    nl,
    writeln('=== BENCHMARK RESULTS ==='),
    format('Completed ~w tests.~n', [TotalTests]),
    format('Passed: ~w~n', [PassedCount]),
    format('Failed: ~w~n', [FailedCount]),
    (   FailedCount =:= 0
    ->  writeln('All tests passed!'),
        halt(0)
    ;   writeln('Tests that failed:'),
        print_failed_tests(FailedTests),
        halt(1)
    ).

run_all_tests([], Passed, Failed, FailedAcc, FailedAcc, Passed, Failed).
run_all_tests([Name-Goal | Rest], Passed0, Failed0, FailedAcc0, FailedAcc, Passed, Failed) :-
    run_test(Name, Goal, Passed0, Passed1, FailedAcc0, FailedAcc1),
    (   Passed1 > Passed0
    ->  Failed1 is Failed0
    ;   Failed1 is Failed0 + 1
    ),
    run_all_tests(Rest, Passed1, Failed1, FailedAcc1, FailedAcc, Passed, Failed).

print_failed_tests([]).
print_failed_tests([Name | Rest]) :-
    format(' - ~w~n', [Name]),
    print_failed_tests(Rest).
