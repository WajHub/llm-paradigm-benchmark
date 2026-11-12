% SWI-Prolog's separate garbage-collector thread crashes under valgrind (tcmalloc)
% once enough garbage is produced; run atom/clause GC in the main thread.
:- set_prolog_flag(gc_thread, false).

:- use_module(sequence_alignment).

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

stress_a('CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA').
stress_b('GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC').

score_is(A, B, M, X, O, E, Expected) :-
    alignment_score(A, B, M, X, O, E, Score),
    integer(Score),
    Score =:= Expected.

% recompute_score(+CodesA, +CodesB, +M, +X, +O, +E, -Score)
%   Score of an alignment by definition: per-column match/mismatch, and
%   GapOpen + L * GapExtend for every maximal run of '-' in one row.
%   Fails on unequal lengths or a '-'/'-' column.
recompute_score(CA, CB, M, X, O, E, Score) :-
    columns(CA, CB, M, X, 0, ColScore),
    gap_stats(CA, false, 0, RunsA, 0, DashA),
    gap_stats(CB, false, 0, RunsB, 0, DashB),
    Score is ColScore - (RunsA + RunsB) * O - (DashA + DashB) * E.

columns([], [], _, _, S, S).
columns([Ca|As], [Cb|Bs], M, X, S0, S) :-
    \+ (Ca == 0'-, Cb == 0'-),
    (   ( Ca == 0'- ; Cb == 0'- )
    ->  S1 = S0
    ;   Ca == Cb
    ->  S1 is S0 + M
    ;   S1 is S0 - X
    ),
    columns(As, Bs, M, X, S1, S).

gap_stats([], _, R, R, D, D).
gap_stats([C|Cs], InGap, R0, R, D0, D) :-
    (   C == 0'-
    ->  D1 is D0 + 1,
        ( InGap == true -> R1 = R0 ; R1 is R0 + 1 ),
        gap_stats(Cs, true, R1, R, D1, D)
    ;   gap_stats(Cs, false, R0, R, D0, D)
    ).

without_gaps(Codes, Stripped) :-
    exclude(==(0'-), Codes, Stripped).

% valid_alignment(+A, +B, +M, +X, +O, +E, +Expected, -AA, -AB)
%   Calls alignment_align/7 and checks every invariant of a B test.
valid_alignment(A, B, M, X, O, E, Expected, AA, AB) :-
    alignment_align(A, B, M, X, O, E, Result),
    nonvar(Result),
    Result = alignment(Score, AA, AB),
    integer(Score),
    Score =:= Expected,
    atom(AA), atom(AB),
    atom_codes(AA, CA), atom_codes(AB, CB),
    length(CA, Len), length(CB, Len),
    atom_codes(A, CodesA), atom_codes(B, CodesB),
    without_gaps(CA, CodesA),
    without_gaps(CB, CodesB),
    recompute_score(CA, CB, M, X, O, E, Recomputed),
    Recomputed =:= Expected.

exact_alignment(A, B, M, X, O, E, Expected, ExpA, ExpB) :-
    valid_alignment(A, B, M, X, O, E, Expected, AA, AB),
    AA == ExpA,
    AB == ExpB.

% ===========================================================================
% Algorithm A: Alignment Score
% ===========================================================================

test_algo_a_01_both_empty :-
    score_is('', '', 1, 1, 2, 1, 0).

test_algo_a_02_one_empty :-
    score_is('', 'ACG', 1, 1, 2, 1, -5).

test_algo_a_03_identical :-
    score_is('GATTACA', 'GATTACA', 2, 1, 3, 1, 14).

test_algo_a_04_mismatch_beats_gaps :-
    score_is('A', 'C', 1, 1, 2, 1, -1).

test_algo_a_05_textbook :-
    score_is('GATTACA', 'GCATGCU', 1, 1, 1, 1, -1).

test_algo_a_06_one_long_gap :-
    score_is('AAAGGGTTT', 'AAATTT', 2, 2, 5, 1, 4).

test_algo_a_07_zero_extend :-
    score_is('TTACGGA', 'ACG', 2, 2, 2, 0, 2).

test_algo_a_08_adjacent_gaps_beat_mismatch :-
    score_is('XAY', 'XCY', 1, 10, 1, 1, -2).

test_algo_a_09_terminal_gaps_penalized :-
    score_is('AAAACCCC', 'CCCC', 2, 1, 3, 1, 1).

test_algo_a_10_stress :-
    stress_a(A), stress_b(B),
    score_is(A, B, 2, 1, 3, 1, 16).

% ===========================================================================
% Algorithm B: Alignment Reconstruction
% ===========================================================================

test_algo_b_01_both_empty :-
    exact_alignment('', '', 1, 1, 2, 1, 0, '', '').

test_algo_b_02_second_empty :-
    exact_alignment('ACG', '', 1, 1, 2, 1, -5, 'ACG', '---').

test_algo_b_03_identical :-
    exact_alignment('GATTACA', 'GATTACA', 2, 1, 3, 1, 14, 'GATTACA', 'GATTACA').

test_algo_b_04_unique_long_gap :-
    exact_alignment('AAAGGGTTT', 'AAATTT', 2, 2, 5, 1, 4, 'AAAGGGTTT', 'AAA---TTT').

test_algo_b_05_adjacent_gaps :-
    valid_alignment('XAY', 'XCY', 1, 10, 1, 1, -2, _, _).

test_algo_b_06_textbook_unique :-
    exact_alignment('GATTACA', 'GCATGCU', 1, 1, 1, 1, -1, 'GATTACA', 'GCATGCU').

test_algo_b_07_gap_merging :-
    exact_alignment('ACCCGT', 'AGT', 2, 3, 6, 1, -3, 'ACCCGT', 'A---GT').

test_algo_b_08_gaps_in_both_rows :-
    exact_alignment('CACGCA', 'AGGCGC', 3, 2, 3, 1, -1, 'CA--CGCA', '-AGGCGC-').

test_algo_b_09_tied_gap_positions :-
    valid_alignment('AAAA', 'AA', 1, 1, 1, 1, -1, _, _).

test_algo_b_10_stress_invariants :-
    stress_a(A), stress_b(B),
    valid_alignment(A, B, 3, 2, 5, 1, 10, _, _).

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Alignment Score ---'),
    AlgoATests = [
        'Test A01 (Both Empty)'-test_algo_a_01_both_empty,
        'Test A02 (One Empty)'-test_algo_a_02_one_empty,
        'Test A03 (Identical)'-test_algo_a_03_identical,
        'Test A04 (Mismatch Beats Gaps)'-test_algo_a_04_mismatch_beats_gaps,
        'Test A05 (Textbook)'-test_algo_a_05_textbook,
        'Test A06 (One Long Gap)'-test_algo_a_06_one_long_gap,
        'Test A07 (Zero Extend)'-test_algo_a_07_zero_extend,
        'Test A08 (Adjacent Gaps Beat Mismatch)'-test_algo_a_08_adjacent_gaps_beat_mismatch,
        'Test A09 (Terminal Gaps Penalized)'-test_algo_a_09_terminal_gaps_penalized,
        'Test A10 (Stress)'-test_algo_a_10_stress
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Alignment Reconstruction ---'),
    AlgoBTests = [
        'Test B01 (Both Empty)'-test_algo_b_01_both_empty,
        'Test B02 (Second Empty)'-test_algo_b_02_second_empty,
        'Test B03 (Identical)'-test_algo_b_03_identical,
        'Test B04 (Unique Long Gap)'-test_algo_b_04_unique_long_gap,
        'Test B05 (Adjacent Gaps)'-test_algo_b_05_adjacent_gaps,
        'Test B06 (Textbook Unique)'-test_algo_b_06_textbook_unique,
        'Test B07 (Gap Merging)'-test_algo_b_07_gap_merging,
        'Test B08 (Gaps In Both Rows)'-test_algo_b_08_gaps_in_both_rows,
        'Test B09 (Tied Gap Positions)'-test_algo_b_09_tied_gap_positions,
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
