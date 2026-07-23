:- use_module(knapsack).

reference_dp(Weights, Values, Capacity, MaxValue) :-
    (   Weights = [], Capacity =< 0
    ->  MaxValue = 0
    ;   Capacity =< 0
    ->  MaxValue = 0
    ;   length(Weights, N),
        Cap1 is Capacity + 1,
        length(Dp0, Cap1),
        maplist(=(0), Dp0),
        reference_dp_items(0, N, Weights, Values, Capacity, Dp0, Dp),
        nth0(Capacity, Dp, MaxValue)
    ).

reference_dp_items(I, N, _, _, _, Dp, Dp) :-
    I >= N, !.
reference_dp_items(I, N, Weights, Values, Capacity, DpIn, DpOut) :-
    nth0(I, Weights, W),
    nth0(I, Values, V),
    reference_dp_capacity(Capacity, W, V, DpIn, Dp1),
    I1 is I + 1,
    reference_dp_items(I1, N, Weights, Values, Capacity, Dp1, DpOut).

reference_dp_capacity(C, _, _, Dp, Dp) :-
    C < 0, !.
reference_dp_capacity(C, W, V, DpIn, DpOut) :-
    C >= W, !,
    nth0(C, DpIn, Cur),
    PrevIdx is C - W,
    nth0(PrevIdx, DpIn, Prev),
    Cand is Prev + V,
    (   Cand > Cur -> New = Cand ; New = Cur ),
    set_nth0(C, DpIn, New, Dp1),
    C1 is C - 1,
    reference_dp_capacity(C1, W, V, Dp1, DpOut).
reference_dp_capacity(C, W, V, DpIn, DpOut) :-
    C1 is C - 1,
    reference_dp_capacity(C1, W, V, DpIn, DpOut).

set_nth0(0, [_|T], X, [X|T]) :- !.
set_nth0(I, [H|T], X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    set_nth0(I1, T, X, R).

selected_equals(Actual, Expected) :-
    Actual == Expected.

run_test(Name, Goal, PassedCount0, PassedCount1, FailedTests0, FailedTests1) :-
    (   catch(call(Goal), _, fail)
    ->  format('[PASS] ~w~n', [Name]),
        PassedCount1 is PassedCount0 + 1,
        FailedTests1 = FailedTests0
    ;   format('[FAIL] ~w~n', [Name]),
        PassedCount1 = PassedCount0,
        FailedTests1 = [Name | FailedTests0]
    ).

test_algo_a_01_empty :-
    knapsack_max_value([], [], 10, 0).

test_algo_a_02_single_fit :-
    knapsack_max_value([5], [10], 10, 10).

test_algo_a_03_too_heavy :-
    knapsack_max_value([15], [10], 10, 0).

test_algo_a_04_cap_zero :-
    knapsack_max_value([1, 2, 3], [10, 20, 30], 0, 0).

test_algo_a_05_choose_better :-
    knapsack_max_value([5, 6], [10, 11], 10, 11).

test_algo_a_06_textbook :-
    knapsack_max_value([2, 3, 4, 5], [3, 4, 5, 6], 5, 7).

test_algo_a_07_greedy_trap :-
    knapsack_max_value([10, 20, 30], [60, 100, 120], 50, 220).

test_algo_a_08_same_items :-
    knapsack_max_value([3, 3, 3, 3], [5, 5, 5, 5], 10, 15).

test_algo_a_09_tight_fit :-
    knapsack_max_value([3, 4, 5, 6], [2, 3, 4, 5], 10, 8).

test_algo_a_10_stress :-
    numlist(1, 50, Weights),
    maplist(times2, Weights, Values),
    reference_dp(Weights, Values, 100, Expected),
    knapsack_max_value(Weights, Values, 100, Expected).

times2(X, Y) :- Y is X * 2.

test_algo_b_01_single_selection :-
    knapsack_solve([5], [10], 10, result(10, Selected, 5)),
    selected_equals(Selected, [1]).

test_algo_b_02_choose_better_selection :-
    knapsack_solve([5, 6], [10, 11], 10, result(11, Selected, 6)),
    selected_equals(Selected, [0, 1]).

test_algo_b_03_textbook_selection :-
    knapsack_solve([2, 3, 4, 5], [3, 4, 5, 6], 5, result(7, Selected, 5)),
    selected_equals(Selected, [1, 1, 0, 0]).

test_algo_b_04_greedy_trap_selection :-
    knapsack_solve([10, 20, 30], [60, 100, 120], 50, result(220, Selected, 50)),
    selected_equals(Selected, [0, 1, 1]).

test_algo_b_05_cap_zero_selection :-
    knapsack_solve([1, 2, 3], [10, 20, 30], 0, result(0, Selected, 0)),
    selected_equals(Selected, [0, 0, 0]).

test_algo_b_06_too_heavy_selection :-
    knapsack_solve([15], [10], 10, result(0, Selected, 0)),
    selected_equals(Selected, [0]).

test_algo_b_07_all_fit :-
    knapsack_solve([1, 2, 3], [10, 20, 30], 10, result(60, Selected, 6)),
    selected_equals(Selected, [1, 1, 1]).

test_algo_b_08_weight_invariant :-
    Weights = [10, 20, 30],
    Values = [60, 100, 120],
    Capacity = 50,
    knapsack_solve(Weights, Values, Capacity, result(_, Selected, TotalWeight)),
    maplist(prod, Selected, Weights, Parts),
    sum_list(Parts, SumW),
    SumW =< Capacity,
    SumW =:= TotalWeight.

prod(A, B, C) :- C is A * B.

test_algo_b_09_value_invariant :-
    Weights = [10, 20, 30],
    Values = [60, 100, 120],
    knapsack_solve(Weights, Values, 50, result(MaxValue, Selected, _)),
    maplist(prod, Selected, Values, Parts),
    sum_list(Parts, SumV),
    SumV =:= MaxValue.

test_algo_b_10_stress_invariants :-
    numlist(1, 50, Weights),
    maplist(times2, Weights, Values),
    Capacity = 100,
    reference_dp(Weights, Values, Capacity, Expected),
    knapsack_solve(Weights, Values, Capacity, result(MaxValue, Selected, TotalWeight)),
    length(Selected, 50),
    maplist(is_bit, Selected),
    maplist(prod, Selected, Weights, WParts),
    maplist(prod, Selected, Values, VParts),
    sum_list(WParts, SumW),
    sum_list(VParts, SumV),
    MaxValue =:= Expected,
    SumW =< Capacity,
    SumW =:= TotalWeight,
    SumV =:= MaxValue.

is_bit(0).
is_bit(1).

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Maximum Value ---'),
    AlgoATests = [
        'Test A01 (Empty)'-test_algo_a_01_empty,
        'Test A02 (Single Fit)'-test_algo_a_02_single_fit,
        'Test A03 (Too Heavy)'-test_algo_a_03_too_heavy,
        'Test A04 (Capacity Zero)'-test_algo_a_04_cap_zero,
        'Test A05 (Choose Better)'-test_algo_a_05_choose_better,
        'Test A06 (Textbook)'-test_algo_a_06_textbook,
        'Test A07 (Greedy Trap)'-test_algo_a_07_greedy_trap,
        'Test A08 (Same Items)'-test_algo_a_08_same_items,
        'Test A09 (Tight Fit)'-test_algo_a_09_tight_fit,
        'Test A10 (Stress 50 Items)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Item Selection ---'),
    AlgoBTests = [
        'Test B01 (Single Selection)'-test_algo_b_01_single_selection,
        'Test B02 (Choose Better Selection)'-test_algo_b_02_choose_better_selection,
        'Test B03 (Textbook Selection)'-test_algo_b_03_textbook_selection,
        'Test B04 (Greedy Trap Selection)'-test_algo_b_04_greedy_trap_selection,
        'Test B05 (Capacity Zero Selection)'-test_algo_b_05_cap_zero_selection,
        'Test B06 (Too Heavy Selection)'-test_algo_b_06_too_heavy_selection,
        'Test B07 (All Fit)'-test_algo_b_07_all_fit,
        'Test B08 (Weight Invariant)'-test_algo_b_08_weight_invariant,
        'Test B09 (Value Invariant)'-test_algo_b_09_value_invariant,
        'Test B10 (Stress Invariants)'-test_algo_b_10_stress_invariants
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
