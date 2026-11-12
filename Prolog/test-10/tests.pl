% SWI-Prolog's separate garbage-collector thread crashes under valgrind (tcmalloc)
% once enough garbage is produced; run atom/clause GC in the main thread.
:- set_prolog_flag(gc_thread, false).

:- use_module(order_stats).

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
% Helpers - Algorithm A
% ===========================================================================

mom_is(Xs, Expected) :-
    median_of_medians(Xs, M),
    M == Expected.

sel_is(Xs, K, Value, Pivots) :-
    select_kth(Xs, K, R),
    R == select(Value, Pivots).

sel_none(Xs, K) :-
    select_kth(Xs, K, R),
    R == none.

% stress_values(-Xs): LCG seed 42, r = x // 65536, value = r mod 20001 - 10000.
stress_values(Xs) :-
    length(Xs, 5000),
    foldl(stress_step, Xs, 42, _).

stress_step(V, X0, X) :-
    X is (X0 * 1103515245 + 12345) mod 2147483648,
    V is (X // 65536) mod 20001 - 10000.

a09_input([12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14]).
a09_sorted([-30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41]).

a09_pivots(K, [3, -11]) :- K =< 6, !.
a09_pivots(K, [3]) :- K =< 11, !.
a09_pivots(_, [3, 14]).

% ===========================================================================
% Helpers - Algorithm B (counting probe)
% ===========================================================================

% Element formulas of the test sources (never materialised for huge ones).
src_value(vals(T), I, V) :-
    I1 is I + 1,
    arg(I1, T, V).
src_value(lin(Mul, Off), I, V) :-
    V is Mul * I + Off.
src_value(divoff(Div, Off), I, V) :-
    V is Off + I // Div.

% probe(+Len, +Spec, +Index, -Value): the Getter closure. Counts every read and
% throws when the budget is exceeded or the index is out of range.
probe(Len, Spec, I, V) :-
    nb_getval(os_reads, R0),
    R is R0 + 1,
    nb_setval(os_reads, R),
    nb_getval(os_budget, Budget),
    (   R > Budget
    ->  throw(read_budget_exceeded(R, Budget))
    ;   true
    ),
    (   integer(I), I >= 0, I < Len
    ->  true
    ;   throw(index_out_of_range(I, Len))
    ),
    src_value(Spec, I, V).

list_source(List, source(Len, user:probe(Len, vals(T)))) :-
    length(List, Len),
    T =.. [vals|List].

formula_source(Len, Spec, source(Len, user:probe(Len, Spec))).

run_median(A, B, Budget, Median) :-
    nb_setval(os_reads, 0),
    nb_setval(os_budget, Budget),
    median_two_sorted(A, B, Median),
    nb_getval(os_reads, Reads),
    Reads =< Budget.

approx(V, Expected) :-
    number(V),
    abs(V - Expected) < 1.0e-9.

median_is(A, B, Budget, Expected) :-
    run_median(A, B, Budget, Median),
    approx(Median, Expected).

lists_median_is(ListA, ListB, Budget, Expected) :-
    list_source(ListA, A),
    list_source(ListB, B),
    median_is(A, B, Budget, Expected).

% ===========================================================================
% Algorithm A: Median of Medians
% ===========================================================================

test_algo_a_01_empty :-
    mom_is([], none),
    sel_none([], 0).

test_algo_a_02_single :-
    mom_is([7], 7),
    sel_is([7], 0, 7, []),
    sel_none([7], 1).

test_algo_a_03_out_of_range :-
    sel_none([3, 1, 2], 3),
    sel_none([3, 1, 2], -1),
    sel_is([3, 1, 2], 2, 3, []),
    mom_is([3, 1, 2], 2).

test_algo_a_04_one_group :-
    Xs = [9, 1, 8, 2, 7],
    mom_is(Xs, 7),
    sel_is(Xs, 0, 1, []),
    sel_is(Xs, 2, 7, []),
    sel_is(Xs, 4, 9, []).

test_algo_a_05_pivot_is_not_median :-
    numlist(1, 10, Xs),
    mom_is(Xs, 3),
    sel_is(Xs, 4, 5, [3, 6]),
    sel_is(Xs, 5, 6, [3, 6]).

test_algo_a_06_partial_last_group :-
    Xs = [5, 3, 9, 1, 8, 2, 6],
    mom_is(Xs, 2),
    sel_is(Xs, 3, 5, [2]),
    sel_is(Xs, 6, 9, [2]).

test_algo_a_07_many_duplicates :-
    Xs = [5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5],
    mom_is(Xs, 5),
    sel_is(Xs, 0, 1, [5]),
    sel_is(Xs, 5, 5, [5]),
    sel_is(Xs, 10, 9, [5]).

test_algo_a_08_stable_partition_order :-
    Xs = [40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27],
    mom_is(Xs, 40),
    sel_is(Xs, 6, 51, [40, 41, 51]).

test_algo_a_09_all_ranks :-
    a09_input(Xs),
    a09_sorted(Sorted),
    mom_is(Xs, 3),
    forall(between(0, 22, K),
           (   nth0(K, Sorted, Value),
               a09_pivots(K, Pivots),
               sel_is(Xs, K, Value, Pivots)
           )).

test_algo_a_10_stress :-
    stress_values(Xs),
    mom_is(Xs, -1678),
    sel_is(Xs, 0, -9996,
           [-1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995]),
    sel_is(Xs, 2499, -1694,
           [-1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694]),
    sel_is(Xs, 4999, 9984,
           [-1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974]).

% ===========================================================================
% Algorithm B: Median of Two Sorted Arrays
% ===========================================================================

test_algo_b_01_both_empty :-
    list_source([], A),
    list_source([], B),
    run_median(A, B, 16, Median),
    Median == none.

test_algo_b_02_one_empty :-
    lists_median_is([], [1, 2, 3, 4], 64, 2.5).

test_algo_b_03_single_each :-
    lists_median_is([1], [2], 48, 1.5).

test_algo_b_04_odd_total_interleaved :-
    lists_median_is([1, 3, 5], [2, 4], 64, 3.0).

test_algo_b_05_disjoint_ranges :-
    lists_median_is([10, 11, 12, 13], [1, 2, 3], 64, 10.0).

test_algo_b_06_duplicates :-
    lists_median_is([1, 1, 1, 1], [1, 1, 2], 64, 1.0).

test_algo_b_07_no_overflow :-
    lists_median_is([2147483647], [2147483647], 48, 2147483647.0),
    lists_median_is([-2147483648, 2147483647], [], 48, -0.5).

test_algo_b_08_huge_interleaved :-
    formula_source(1000000000, lin(2, -1000000000), A),
    formula_source(999999999, lin(2, -999999999), B),
    median_is(A, B, 512, -1.0).

test_algo_b_09_huge_unbalanced :-
    list_source([-5, 0, 7], A),
    formula_source(2000000000, divoff(2, -500000000), B),
    median_is(A, B, 512, 0.0).

test_algo_b_10_huge_duplicates :-
    formula_source(1500000000, divoff(1000000, 0), A),
    formula_source(600000000, divoff(3000000, 700), B),
    median_is(A, B, 512, 787.0).

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Median of Medians ---'),
    AlgoATests = [
        'Test A01 (Empty)'-test_algo_a_01_empty,
        'Test A02 (Single)'-test_algo_a_02_single,
        'Test A03 (Out Of Range)'-test_algo_a_03_out_of_range,
        'Test A04 (One Group)'-test_algo_a_04_one_group,
        'Test A05 (Pivot Is Not Median)'-test_algo_a_05_pivot_is_not_median,
        'Test A06 (Partial Last Group)'-test_algo_a_06_partial_last_group,
        'Test A07 (Many Duplicates)'-test_algo_a_07_many_duplicates,
        'Test A08 (Stable Partition Order)'-test_algo_a_08_stable_partition_order,
        'Test A09 (All Ranks)'-test_algo_a_09_all_ranks,
        'Test A10 (Stress)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Median of Two Sorted Arrays ---'),
    AlgoBTests = [
        'Test B01 (Both Empty)'-test_algo_b_01_both_empty,
        'Test B02 (One Empty)'-test_algo_b_02_one_empty,
        'Test B03 (Single Each)'-test_algo_b_03_single_each,
        'Test B04 (Odd Total Interleaved)'-test_algo_b_04_odd_total_interleaved,
        'Test B05 (Disjoint Ranges)'-test_algo_b_05_disjoint_ranges,
        'Test B06 (Duplicates)'-test_algo_b_06_duplicates,
        'Test B07 (No Overflow)'-test_algo_b_07_no_overflow,
        'Test B08 (Huge Interleaved)'-test_algo_b_08_huge_interleaved,
        'Test B09 (Huge Unbalanced)'-test_algo_b_09_huge_unbalanced,
        'Test B10 (Huge Duplicates)'-test_algo_b_10_huge_duplicates
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
