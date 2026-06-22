:- use_module(shortest_path).

approx_eq(A, B) :-
    Diff is abs(A - B),
    Diff < 1e-9.

distance_is(Dist, inf) :-
    (   Dist =:= inf
    ;   Dist >= 1.0e18
    ).
distance_is(Dist, Expected) :-
    Expected \== inf,
    approx_eq(Dist, Expected).

check_distance(Result, Target, Expected) :-
    get_shortest_distance(Result, Target, Dist),
    distance_is(Dist, Expected).

path_equals(Path, Expected) :-
    Path == Expected.

build_graph(NumVertices, Edges, Graph) :-
    create_graph(NumVertices, G0),
    fold_edges(Edges, G0, Graph).

fold_edges([], G, G).
fold_edges([(From, To, Weight) | Rest], GIn, GOut) :-
    add_edge(GIn, From, To, Weight, G1),
    fold_edges(Rest, G1, GOut).

create_linear_chain(NumVertices, Weight, Graph) :-
    create_graph(NumVertices, G0),
    Max is NumVertices - 1,
    numlist(0, Max, Indices),
    foldl(add_chain_edge(Weight), Indices, G0, Graph).

add_chain_edge(Weight, I, GIn, GOut) :-
    J is I + 1,
    add_edge(GIn, I, J, Weight, GOut).

run_test(Name, Goal, PassedCount0, PassedCount1, FailedTests0, FailedTests1) :-
    (   catch(call(Goal), _, fail)
    ->  format('[PASS] ~w~n', [Name]),
        PassedCount1 is PassedCount0 + 1,
        FailedTests1 = FailedTests0
    ;   format('[FAIL] ~w~n', [Name]),
        PassedCount1 = PassedCount0,
        FailedTests1 = [Name | FailedTests0]
    ).

test_algo_a_01_linear_chain :-
    build_graph(4, [(0, 1, 1.0), (1, 2, 2.0), (2, 3, 3.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 0, 0.0),
    check_distance(Result, 1, 1.0),
    check_distance(Result, 2, 3.0),
    check_distance(Result, 3, 6.0).

test_algo_a_02_diamond :-
    build_graph(4, [(0, 1, 1.0), (0, 2, 4.0), (1, 3, 6.0), (2, 3, 1.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 0, 0.0),
    check_distance(Result, 1, 1.0),
    check_distance(Result, 2, 4.0),
    check_distance(Result, 3, 5.0).

test_algo_a_03_disconnected :-
    build_graph(5, [(0, 1, 2.0), (1, 2, 3.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 0, 0.0),
    check_distance(Result, 1, 2.0),
    check_distance(Result, 2, 5.0),
    check_distance(Result, 3, inf),
    check_distance(Result, 4, inf).

test_algo_a_04_single_vertex :-
    create_graph(1, Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 0, 0.0).

test_algo_a_05_parallel_edges :-
    build_graph(2, [(0, 1, 5.0), (0, 1, 2.0), (0, 1, 8.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 1, 2.0).

test_algo_a_06_zero_weight_edges :-
    build_graph(4, [(0, 1, 0.0), (1, 2, 0.0), (2, 3, 1.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 1, 0.0),
    check_distance(Result, 2, 0.0),
    check_distance(Result, 3, 1.0).

test_algo_a_07_null_graph :-
    dijkstra(none, 0, Result),
    Result == none.

test_algo_a_08_invalid_source :-
    create_graph(3, Graph),
    dijkstra(Graph, 5, Result),
    Result == none.

test_algo_a_09_complex_graph :-
    build_graph(6, [
        (0, 1, 7.0), (0, 2, 9.0), (0, 5, 14.0),
        (1, 2, 10.0), (1, 3, 15.0),
        (2, 3, 11.0), (2, 5, 2.0),
        (3, 4, 6.0), (4, 5, 9.0)
    ], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 0, 0.0),
    check_distance(Result, 1, 7.0),
    check_distance(Result, 2, 9.0),
    check_distance(Result, 3, 20.0),
    check_distance(Result, 4, 26.0),
    check_distance(Result, 5, 11.0).

test_algo_a_10_stress :-
    create_linear_chain(1000, 1.0, Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    check_distance(Result, 999, 999.0).

test_algo_b_01_simple_path :-
    build_graph(4, [(0, 1, 1.0), (1, 2, 2.0), (2, 3, 3.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 3, Path),
    path_equals(Path, [0, 1, 2, 3]).

test_algo_b_02_diamond_path :-
    build_graph(4, [(0, 1, 1.0), (0, 2, 4.0), (1, 3, 6.0), (2, 3, 1.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 3, Path),
    path_equals(Path, [0, 2, 3]).

test_algo_b_03_self_path :-
    build_graph(3, [(0, 1, 1.0), (1, 2, 1.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 0, Path),
    path_equals(Path, [0]).

test_algo_b_04_unreachable :-
    build_graph(5, [(0, 1, 2.0), (1, 2, 3.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 4, Path),
    Path == none.

test_algo_b_05_long_chain :-
    create_linear_chain(10, 1.0, Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 9, Path),
    numlist(0, 9, Expected),
    path_equals(Path, Expected).

test_algo_b_06_cycle :-
    build_graph(4, [(0, 1, 1.0), (1, 2, 1.0), (2, 0, 1.0), (1, 3, 2.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 3, Path),
    path_equals(Path, [0, 1, 3]).

test_algo_b_07_star :-
    build_graph(5, [(0, 1, 2.0), (0, 2, 3.0), (0, 3, 1.0), (0, 4, 5.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 3, Path),
    path_equals(Path, [0, 3]).

test_algo_b_08_null_result :-
    reconstruct_path(none, 0, Path),
    Path == none.

test_algo_b_09_bidirectional :-
    build_graph(3, [(0, 1, 1.0), (1, 0, 10.0), (1, 2, 1.0), (0, 2, 5.0)], Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 2, Path),
    path_equals(Path, [0, 1, 2]).

test_algo_b_10_stress_path :-
    create_linear_chain(1000, 1.0, Graph),
    dijkstra(Graph, 0, Result),
    Result \== none,
    reconstruct_path(Result, 999, Path),
    Path \== none,
    length(Path, 1000),
    nth0(0, Path, 0),
    nth0(999, Path, 999).

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Shortest Distances ---'),
    AlgoATests = [
        'Test A01 (Linear Chain)'-test_algo_a_01_linear_chain,
        'Test A02 (Diamond)'-test_algo_a_02_diamond,
        'Test A03 (Disconnected)'-test_algo_a_03_disconnected,
        'Test A04 (Single Vertex)'-test_algo_a_04_single_vertex,
        'Test A05 (Parallel Edges)'-test_algo_a_05_parallel_edges,
        'Test A06 (Zero-Weight Edges)'-test_algo_a_06_zero_weight_edges,
        'Test A07 (Null Graph)'-test_algo_a_07_null_graph,
        'Test A08 (Invalid Source)'-test_algo_a_08_invalid_source,
        'Test A09 (Complex Graph)'-test_algo_a_09_complex_graph,
        'Test A10 (Stress 1000-Chain)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Path Reconstruction ---'),
    AlgoBTests = [
        'Test B01 (Simple Path)'-test_algo_b_01_simple_path,
        'Test B02 (Diamond Path)'-test_algo_b_02_diamond_path,
        'Test B03 (Self Path)'-test_algo_b_03_self_path,
        'Test B04 (Unreachable)'-test_algo_b_04_unreachable,
        'Test B05 (Long Chain)'-test_algo_b_05_long_chain,
        'Test B06 (Cycle)'-test_algo_b_06_cycle,
        'Test B07 (Star)'-test_algo_b_07_star,
        'Test B08 (Null Result)'-test_algo_b_08_null_result,
        'Test B09 (Bidirectional)'-test_algo_b_09_bidirectional,
        'Test B10 (Stress Path 1000-Chain)'-test_algo_b_10_stress_path
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
