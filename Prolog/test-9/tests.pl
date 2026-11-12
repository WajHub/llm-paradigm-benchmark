% SWI-Prolog's separate garbage-collector thread crashes under valgrind (tcmalloc)
% once enough garbage is produced; run atom/clause GC in the main thread.
:- set_prolog_flag(gc_thread, false).

:- use_module(btree).

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
% Helpers
% ===========================================================================

% gen(+Seed, +Count, +Mod, -Keys): LCG x = (x * 1103515245 + 12345) mod 2^31,
% each step outputs (x div 65536) mod Mod.
gen(Seed, Count, Mod, Keys) :-
    length(Keys, Count),
    foldl(gen_step(Mod), Keys, Seed, _).

gen_step(Mod, K, X0, X) :-
    X is (X0 * 1103515245 + 12345) mod 2147483648,
    K is (X // 65536) mod Mod.

% dump(+Tree, -Atom): "(k1 k2)" for a leaf, "(c0 k0 c1 k1 ... ck)" otherwise.
dump(Tree, Atom) :-
    ground(Tree),
    phrase(dump_node(Tree), Codes),
    atom_codes(Atom, Codes).

dump_node(node(Keys, [])) -->
    { is_list(Keys) },
    "(", dump_keys(Keys), ")".
dump_node(node(Keys, [C|Cs])) -->
    { is_list(Keys), is_list(Cs) },
    "(", dump_node(C), dump_rest(Keys, Cs), ")".

dump_keys([]) --> [].
dump_keys([K|Ks]) --> dump_int(K), dump_more_keys(Ks).

dump_more_keys([]) --> [].
dump_more_keys([K|Ks]) --> " ", dump_int(K), dump_more_keys(Ks).

dump_rest([], []) --> [].
dump_rest([K|Ks], [C|Cs]) --> " ", dump_int(K), " ", dump_node(C), dump_rest(Ks, Cs).

dump_int(K) --> { integer(K), number_codes(K, Cs) }, Cs.

% check_tree(+T, +Tree, -Height, -NodeCount, -InOrder)
%   Validates every B-tree invariant: key counts, strictly ascending keys,
%   separator ranges, child count = keys + 1, all leaves at the same depth.
check_tree(T, Tree, Height, NodeCount, InOrder) :-
    ground(Tree),
    check_node(Tree, T, true, none, none, 1, Height, 0, NodeCount, InOrder, []).

check_node(node(Keys, Children), T, IsRoot, Lo, Hi, Depth, LeafDepth, N0, N, In0, In) :-
    is_list(Keys), is_list(Children),
    maplist(integer, Keys),
    length(Keys, NK),
    NK =< 2 * T - 1,
    ( IsRoot == true -> true ; NK >= T - 1 ),
    strictly_ascending(Keys),
    maplist(in_range(Lo, Hi), Keys),
    N1 is N0 + 1,
    (   Children == []
    ->  LeafDepth = Depth,
        append(Keys, In, In0),
        N = N1
    ;   length(Children, NC),
        NC =:= NK + 1,
        Depth1 is Depth + 1,
        check_children(Children, Keys, T, Lo, Hi, Depth1, LeafDepth, N1, N, In0, In)
    ).

check_children([C], [], T, Lo, Hi, Depth, LeafDepth, N0, N, In0, In) :-
    check_node(C, T, false, Lo, Hi, Depth, LeafDepth, N0, N, In0, In).
check_children([C|Cs], [K|Ks], T, Lo, Hi, Depth, LeafDepth, N0, N, In0, In) :-
    check_node(C, T, false, Lo, K, Depth, LeafDepth, N0, N1, In0, [K|In1]),
    check_children(Cs, Ks, T, K, Hi, Depth, LeafDepth, N1, N, In1, In).

strictly_ascending([]).
strictly_ascending([_]).
strictly_ascending([A, B|Rest]) :-
    A < B,
    strictly_ascending([B|Rest]).

in_range(Lo, Hi, K) :-
    ( Lo == none -> true ; K > Lo ),
    ( Hi == none -> true ; K < Hi ).

insert_dump(T, Keys, Expected) :-
    btree_insert_all(T, Keys, Tree),
    dump(Tree, Atom),
    Atom == Expected.

delete_dump(T, Keys, Deletions, Expected) :-
    btree_delete_all(T, Keys, Deletions, Tree),
    dump(Tree, Atom),
    Atom == Expected.

tens(Keys) :-
    numlist(1, 10, Ns),
    maplist([N, K]>>(K is N * 10), Ns, Keys).

% ===========================================================================
% Algorithm A: Insertion
% ===========================================================================

test_algo_a_01_empty :-
    insert_dump(2, [], '()').

test_algo_a_02_invalid_degree :-
    btree_insert_all(1, [1, 2, 3], Tree),
    Tree == none.

test_algo_a_03_single_leaf :-
    insert_dump(3, [5, 1, 3], '(1 3 5)').

test_algo_a_04_root_split :-
    insert_dump(2, [1, 2, 3, 4], '((1) 2 (3 4))').

test_algo_a_05_duplicate_on_full_root :-
    insert_dump(2, [1, 2, 3, 2], '(1 2 3)').

test_algo_a_06_ascending :-
    tens(Keys),
    insert_dump(2, Keys, '(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))').

test_algo_a_07_proactive_split :-
    insert_dump(2, [10, 9, 8, 7, 6, 5, 4, 3, 2, 1],
                '(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))').

test_algo_a_08_textbook_t3 :-
    insert_dump(3, [8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18],
                '((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))').

test_algo_a_09_invariants :-
    gen(7, 100, 1000, Keys),
    sort(Keys, Distinct),
    length(Distinct, 95),
    btree_insert_all(3, Keys, Tree),
    check_tree(3, Tree, Height, Nodes, InOrder),
    InOrder == Distinct,
    Height =:= 3,
    Nodes =:= 28.

test_algo_a_10_stress :-
    gen(42, 2000, 100000, Keys),
    sort(Keys, Distinct),
    btree_insert_all(4, Keys, Tree),
    check_tree(4, Tree, Height, Nodes, InOrder),
    InOrder == Distinct,
    length(InOrder, 1937),
    sum_list(InOrder, 31779629),
    Height =:= 5,
    Nodes =:= 413,
    Tree = node(RootKeys, _),
    RootKeys == [15269].

% ===========================================================================
% Algorithm B: Deletion
% ===========================================================================

test_algo_b_01_delete_from_leaf :-
    delete_dump(3, [5, 1, 3, 9, 7], [3], '(1 5 7 9)').

test_algo_b_02_absent_key_unchanged :-
    delete_dump(2, [10, 30, 20, 40], [15], '((10) 20 (30 40))').

test_algo_b_03_delete_all :-
    tens(Keys),
    delete_dump(2, Keys, [50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999], '()').

test_algo_b_04_predecessor_preferred :-
    delete_dump(2, [10, 20, 30, 40, 5], [20], '((5) 10 (30 40))').

test_algo_b_05_successor :-
    delete_dump(2, [10, 20, 30, 40, 35], [20], '((10) 30 (35 40))').

test_algo_b_06_merge_children :-
    delete_dump(2, [14, 3, 4, 11, 5, 15], [4], '((3 5) 11 (14 15))').

test_algo_b_07_borrow_left_first :-
    delete_dump(2, [21, 12, 9, 10, 17, 23, 24], [17], '((9) 10 (12) 21 (23 24))').

test_algo_b_08_merge_right_first :-
    delete_dump(2, [3, 4, 19, 12, 7, 15, 22, 28], [7], '((3) 4 (12 15) 19 (22 28))').

test_algo_b_09_root_shrink :-
    tens(Keys),
    delete_dump(2, Keys, [10, 20], '((30) 40 (50) 60 (70) 80 (90 100))').

test_algo_b_10_stress_invariants :-
    gen(9, 300, 500, Keys),
    gen(3, 250, 500, Deletions),
    sort(Keys, DistinctKeys),
    sort(Deletions, DistinctDels),
    ord_subtract(DistinctKeys, DistinctDels, Expected),
    btree_delete_all(3, Keys, Deletions, Tree),
    check_tree(3, Tree, Height, Nodes, InOrder),
    InOrder == Expected,
    length(InOrder, 150),
    sum_list(InOrder, 39704),
    Height =:= 4,
    Nodes =:= 55,
    Tree = node(RootKeys, _),
    RootKeys == [293].

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Insertion ---'),
    AlgoATests = [
        'Test A01 (Empty)'-test_algo_a_01_empty,
        'Test A02 (Invalid Degree)'-test_algo_a_02_invalid_degree,
        'Test A03 (Single Leaf)'-test_algo_a_03_single_leaf,
        'Test A04 (Root Split)'-test_algo_a_04_root_split,
        'Test A05 (Duplicate On Full Root)'-test_algo_a_05_duplicate_on_full_root,
        'Test A06 (Ascending)'-test_algo_a_06_ascending,
        'Test A07 (Proactive Split)'-test_algo_a_07_proactive_split,
        'Test A08 (Textbook t3)'-test_algo_a_08_textbook_t3,
        'Test A09 (Invariants)'-test_algo_a_09_invariants,
        'Test A10 (Stress)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Deletion ---'),
    AlgoBTests = [
        'Test B01 (Delete From Leaf)'-test_algo_b_01_delete_from_leaf,
        'Test B02 (Absent Key Unchanged)'-test_algo_b_02_absent_key_unchanged,
        'Test B03 (Delete All)'-test_algo_b_03_delete_all,
        'Test B04 (Predecessor Preferred)'-test_algo_b_04_predecessor_preferred,
        'Test B05 (Successor)'-test_algo_b_05_successor,
        'Test B06 (Merge Children)'-test_algo_b_06_merge_children,
        'Test B07 (Borrow Left First)'-test_algo_b_07_borrow_left_first,
        'Test B08 (Merge Right First)'-test_algo_b_08_merge_right_first,
        'Test B09 (Root Shrink)'-test_algo_b_09_root_shrink,
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
