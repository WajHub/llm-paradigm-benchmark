:- use_module(palindrome_tree).

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
% Algorithm A: eertree_build, eertree_count_distinct, eertree_longest_length
% ===========================================================================

test_algo_a_01_basic_aabaa :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 5,
    eertree_longest_length(T, L), L =:= 5.

test_algo_a_02_single_char :-
    eertree_build(a, 1, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 1,
    eertree_longest_length(T, L), L =:= 1.

test_algo_a_03_all_same_chars :-
    eertree_build(aaaa, 4, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 4,
    eertree_longest_length(T, L), L =:= 4.

test_algo_a_04_no_internal_palindromes :-
    eertree_build(abcde, 5, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 5,
    eertree_longest_length(T, L), L =:= 1.

test_algo_a_05_empty_string :-
    eertree_build('', 0, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 0,
    eertree_longest_length(T, L), L =:= 0.

test_algo_a_06_null_input :-
    eertree_build(none, 5, T),
    T == none.

test_algo_a_07_two_char_palindrome :-
    eertree_build(aa, 2, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 2,
    eertree_longest_length(T, L), L =:= 2.

test_algo_a_08_abacaba :-
    eertree_build(abacaba, 7, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 7,
    eertree_longest_length(T, L), L =:= 7.

test_algo_a_09_abba :-
    eertree_build(abba, 4, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= 4,
    eertree_longest_length(T, L), L =:= 4.

test_algo_a_10_node_count_invariant :-
    Cases = [racecar-7, aabbaa-6, abcbaabcba-10, zzzzzzzzz-9],
    forall(member(S-Len, Cases),
           ( eertree_build(S, Len, T),
             T \== none,
             eertree_count_distinct(T, D),
             D =< Len,
             D > 0 )),
    eertree_build(racecar, 7, T2),
    T2 \== none,
    eertree_count_distinct(T2, D2), D2 =:= 7.

% ===========================================================================
% Algorithm B: eertree_count_occurrences
% ===========================================================================

test_algo_b_01_single_char_occurrences :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(T, a, 1, C), C =:= 4.

test_algo_b_02_even_palindrome_occurrences :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(T, aa, 2, C), C =:= 2.

test_algo_b_03_full_string_palindrome :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(T, aabaa, 5, C), C =:= 1.

test_algo_b_04_pattern_not_in_string :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(T, xyz, 3, C), C =:= 0.

test_algo_b_05_pattern_not_a_palindrome :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(T, ab, 2, C), C =:= 0.

test_algo_b_06_overlapping_even_palindromes :-
    % "aaaa": "aa" appears 3 times (overlapping: [0..1],[1..2],[2..3])
    eertree_build(aaaa, 4, T),
    T \== none,
    eertree_count_occurrences(T, aa, 2, C), C =:= 3.

test_algo_b_07_all_same_single_char :-
    eertree_build(aaaa, 4, T),
    T \== none,
    eertree_count_occurrences(T, a, 1, C), C =:= 4.

test_algo_b_08_repeated_palindrome :-
    % "abacaba": "aba" appears at [0..2] and [4..6] = 2 times
    eertree_build(abacaba, 7, T),
    T \== none,
    eertree_count_occurrences(T, aba, 3, C), C =:= 2.

test_algo_b_09_null_arguments :-
    eertree_build(aabaa, 5, T),
    T \== none,
    eertree_count_occurrences(none, a, 1, C1), C1 =:= 0,
    eertree_count_occurrences(T, none, 1, C2), C2 =:= 0,
    eertree_count_occurrences(T, a, 0, C3), C3 =:= 0,
    eertree_count_occurrences(none, none, 0, C4), C4 =:= 0.

test_algo_b_10_stress_test :-
    N = 50000,
    length(Cs, N), maplist(=(a), Cs), atom_chars(S, Cs),
    eertree_build(S, N, T),
    T \== none,
    eertree_count_distinct(T, D), D =:= N,
    eertree_longest_length(T, L), L =:= N,
    eertree_count_occurrences(T, a, 1, C1), C1 =:= N,
    eertree_count_occurrences(T, aa, 2, C2), NMinus1 is N - 1, C2 =:= NMinus1.

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Palindrome Tree Construction & Structural Queries ---'),
    AlgoATests = [
        'Test A01 (Basic - aabaa)'-test_algo_a_01_basic_aabaa,
        'Test A02 (Single Char)'-test_algo_a_02_single_char,
        'Test A03 (All Same Chars - aaaa)'-test_algo_a_03_all_same_chars,
        'Test A04 (No Internal Palindromes)'-test_algo_a_04_no_internal_palindromes,
        'Test A05 (Empty String)'-test_algo_a_05_empty_string,
        'Test A06 (NULL Input)'-test_algo_a_06_null_input,
        'Test A07 (Two-Char Palindrome - aa)'-test_algo_a_07_two_char_palindrome,
        'Test A08 (Classic - abacaba)'-test_algo_a_08_abacaba,
        'Test A09 (Even Palindrome - abba)'-test_algo_a_09_abba,
        'Test A10 (Node Count Invariant)'-test_algo_a_10_node_count_invariant
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Occurrence Counting ---'),
    AlgoBTests = [
        'Test B01 (Single Char Count)'-test_algo_b_01_single_char_occurrences,
        'Test B02 (Even Palindrome Count)'-test_algo_b_02_even_palindrome_occurrences,
        'Test B03 (Full String Palindrome)'-test_algo_b_03_full_string_palindrome,
        'Test B04 (Pattern Not In String)'-test_algo_b_04_pattern_not_in_string,
        'Test B05 (Pattern Not A Palindrome)'-test_algo_b_05_pattern_not_a_palindrome,
        'Test B06 (Overlapping Even Palindromes)'-test_algo_b_06_overlapping_even_palindromes,
        'Test B07 (All Same - Single Char)'-test_algo_b_07_all_same_single_char,
        'Test B08 (Repeated Palindrome - aba)'-test_algo_b_08_repeated_palindrome,
        'Test B09 (NULL Arguments)'-test_algo_b_09_null_arguments,
        'Test B10 (Stress Test 50k chars)'-test_algo_b_10_stress_test
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
