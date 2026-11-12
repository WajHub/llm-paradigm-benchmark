% SWI-Prolog's separate garbage-collector thread crashes under valgrind (tcmalloc)
% once enough garbage is produced; run atom/clause GC in the main thread.
:- set_prolog_flag(gc_thread, false).

:- use_module(tsp_approx).

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
% Point sets (index order matters)
% ===========================================================================

points(empty, []).
points(single, [5-5]).
points(two, [0-0, 3-4]).
points(collinear, [0-0, 4-0, 1-0, 9-0, 6-0]).
points(square, [0-0, 0-2, 2-2, 2-0]).
points(parent_tie, [2-0, 0-3, 2-3, 3-4, 1-4]).
points(grid, [0-0, 1-0, 2-0, 0-1, 1-1, 2-1, 0-2, 1-2, 2-2]).
points(dup, [3-3, 3-3, 0-0, 3-3]).
points(star, [5-5, 5-0, 0-5, 10-5]).
points(clusters, [0-0, 20-0, 1-1, 21-1, 0-20, 20-20, 1-21, 21-21]).
points(spiral, [0-0, 8-0, 8-8, 0-8, 2-2, 6-2, 6-6, 2-6, 4-4]).
points(s12, [81-33, 69-61, 56-93, 77-0, 65-25, 72-14, 14-48, 33-32, 73-63, 71-87,
             5-8, 54-24]).
points(s20, [38-58, 13-15, 51-27, 10-19, 12-86, 49-67, 84-60, 25-43, 89-83, 37-66,
             66-78, 95-11, 67-54, 31-45, 82-36, 24-5, 94-2, 51-67, 54-53, 61-96]).
points(s40, [81-33, 69-61, 56-93, 77-0, 65-25, 72-14, 14-48, 33-32, 73-63, 71-87,
             5-8, 54-24, 22-71, 51-45, 55-89, 29-78, 87-65, 32-67, 53-10, 27-83,
             36-30, 41-96, 2-37, 8-85, 78-74, 59-59, 76-26, 9-63, 63-86, 7-17,
             91-65, 27-22, 7-85, 95-32, 35-71, 7-65, 12-61, 82-60, 5-35, 74-66]).

% ===========================================================================
% Helpers
% ===========================================================================

dist(X1-Y1, X2-Y2, D) :-
    D is abs(X1 - X2) + abs(Y1 - Y2).

% tour_cost(+Points, +Order, -Cost): closed-tour cost recomputed from the points.
tour_cost(_, [], 0).
tour_cost(Pts, [First|Rest], Cost) :-
    nth0(First, Pts, P0),
    tour_cost_(Rest, Pts, P0, P0, 0, Cost).

tour_cost_([], _, P0, Last, Acc, Cost) :-
    dist(Last, P0, D),
    Cost is Acc + D.
tour_cost_([V|Vs], Pts, P0, Last, Acc, Cost) :-
    nth0(V, Pts, P),
    dist(Last, P, D),
    Acc1 is Acc + D,
    tour_cost_(Vs, Pts, P0, P, Acc1, Cost).

% valid_tour(+Points, +Result, -Order, -Cost)
%   Result is tour(Order, Cost); Order is a permutation of 0..N-1 starting
%   with 0 and Cost equals the recomputed closed-tour cost.
valid_tour(Pts, Result, Order, Cost) :-
    nonvar(Result),
    Result = tour(Order, Cost),
    is_list(Order),
    maplist(integer, Order),
    integer(Cost),
    length(Pts, N),
    length(Order, N),
    Order = [0|_],
    msort(Order, Sorted),
    N1 is N - 1,
    numlist(0, N1, Sorted),
    tour_cost(Pts, Order, Recomputed),
    Recomputed =:= Cost.

mst_is(Set, Expected) :-
    points(Set, Pts),
    tsp_mst_weight(Pts, W),
    integer(W),
    W =:= Expected.

matching_is(Set, Expected) :-
    points(Set, Pts),
    tsp_matching_weight(Pts, W),
    integer(W),
    W =:= Expected.

double_tree_is(Set, ExpOrder, ExpCost) :-
    points(Set, Pts),
    tsp_double_tree(Pts, Result),
    valid_tour(Pts, Result, Order, Cost),
    Order == ExpOrder,
    Cost =:= ExpCost.

christofides_valid(Set, Cost) :-
    points(Set, Pts),
    tsp_christofides(Pts, Result),
    valid_tour(Pts, Result, _, Cost).

% ===========================================================================
% Algorithm A: MST Double Tree
% ===========================================================================

test_algo_a_01_empty :-
    mst_is(empty, 0),
    tsp_double_tree([], R),
    R == none.

test_algo_a_02_single_point :-
    double_tree_is(single, [0], 0),
    mst_is(single, 0).

test_algo_a_03_two_points :-
    double_tree_is(two, [0, 1], 14),
    mst_is(two, 7).

test_algo_a_04_collinear_unsorted :-
    double_tree_is(collinear, [0, 2, 1, 4, 3], 18),
    mst_is(collinear, 9).

test_algo_a_05_square :-
    double_tree_is(square, [0, 1, 2, 3], 8),
    mst_is(square, 6).

test_algo_a_06_parent_tie_breaking :-
    double_tree_is(parent_tie, [0, 2, 1, 4, 3], 14),
    mst_is(parent_tie, 9).

test_algo_a_07_grid_ties :-
    double_tree_is(grid, [0, 1, 2, 5, 8, 4, 7, 3, 6], 12),
    mst_is(grid, 8).

test_algo_a_08_duplicate_points :-
    double_tree_is(dup, [0, 1, 2, 3], 12),
    mst_is(dup, 6).

test_algo_a_09_clusters_two_approx :-
    double_tree_is(clusters, [0, 1, 3, 5, 7, 2, 4, 6], 128),
    mst_is(clusters, 68),
    128 =< 2 * 88.

test_algo_a_10_stress :-
    mst_is(s40, 503),
    points(s40, Pts),
    tsp_double_tree(Pts, Result),
    valid_tour(Pts, Result, _, Cost),
    Cost =:= 832.

% ===========================================================================
% Algorithm B: Christofides
% ===========================================================================

test_algo_b_01_empty :-
    matching_is(empty, 0),
    tsp_christofides([], R),
    R == none.

test_algo_b_02_two_points_double_edge :-
    matching_is(two, 7),
    points(two, Pts),
    tsp_christofides(Pts, Result),
    valid_tour(Pts, Result, Order, Cost),
    Order == [0, 1],
    Cost =:= 14.

test_algo_b_03_star_parallel_edges :-
    matching_is(star, 15),
    christofides_valid(star, Cost),
    Cost =:= 30.

test_algo_b_04_collinear :-
    matching_is(collinear, 9),
    christofides_valid(collinear, Cost),
    Cost =:= 18.

test_algo_b_05_grid :-
    matching_is(grid, 4),
    christofides_valid(grid, Cost),
    Cost =< 12.

test_algo_b_06_beats_double_tree :-
    matching_is(clusters, 24),
    christofides_valid(clusters, Cost),
    Cost =< 92.

test_algo_b_07_spiral_bound :-
    matching_is(spiral, 20),
    christofides_valid(spiral, Cost),
    Cost =< 52,
    2 * Cost =< 3 * 44.

test_algo_b_08_greedy_matching_trap :-
    matching_is(s12, 163),
    christofides_valid(s12, Cost),
    Cost =< 440,
    2 * Cost =< 3 * 396.

test_algo_b_09_duplicate_points :-
    matching_is(dup, 6),
    christofides_valid(dup, Cost),
    Cost =:= 12.

test_algo_b_10_stress :-
    matching_is(s20, 211),
    christofides_valid(s20, Cost),
    Cost =< 608,
    2 * Cost =< 3 * 540.

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: MST Double Tree ---'),
    AlgoATests = [
        'Test A01 (Empty)'-test_algo_a_01_empty,
        'Test A02 (Single Point)'-test_algo_a_02_single_point,
        'Test A03 (Two Points)'-test_algo_a_03_two_points,
        'Test A04 (Collinear Unsorted)'-test_algo_a_04_collinear_unsorted,
        'Test A05 (Square)'-test_algo_a_05_square,
        'Test A06 (Parent Tie Breaking)'-test_algo_a_06_parent_tie_breaking,
        'Test A07 (Grid Ties)'-test_algo_a_07_grid_ties,
        'Test A08 (Duplicate Points)'-test_algo_a_08_duplicate_points,
        'Test A09 (Clusters Two Approx)'-test_algo_a_09_clusters_two_approx,
        'Test A10 (Stress)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Christofides ---'),
    AlgoBTests = [
        'Test B01 (Empty)'-test_algo_b_01_empty,
        'Test B02 (Two Points Double Edge)'-test_algo_b_02_two_points_double_edge,
        'Test B03 (Star Parallel Edges)'-test_algo_b_03_star_parallel_edges,
        'Test B04 (Collinear)'-test_algo_b_04_collinear,
        'Test B05 (Grid)'-test_algo_b_05_grid,
        'Test B06 (Beats Double Tree)'-test_algo_b_06_beats_double_tree,
        'Test B07 (Spiral Bound)'-test_algo_b_07_spiral_bound,
        'Test B08 (Greedy Matching Trap)'-test_algo_b_08_greedy_matching_trap,
        'Test B09 (Duplicate Points)'-test_algo_b_09_duplicate_points,
        'Test B10 (Stress)'-test_algo_b_10_stress
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
