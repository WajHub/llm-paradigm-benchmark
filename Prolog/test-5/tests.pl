:- use_module(expression).

run_test(Name, Goal, PassedCount0, PassedCount1, FailedTests0, FailedTests1) :-
    (   catch(call(Goal), _, fail)
    ->  format('[PASS] ~w~n', [Name]),
        PassedCount1 is PassedCount0 + 1,
        FailedTests1 = FailedTests0
    ;   format('[FAIL] ~w~n', [Name]),
        PassedCount1 = PassedCount0,
        FailedTests1 = [Name | FailedTests0]
    ).

% Helpers

eval_str(Expr, Vars, Status, Value) :-
    parse_expression(Expr, Ast),
    (   Ast == none
    ->  Status = invalid_op, Value = 0.0
    ;   evaluate(Ast, Vars, result(Status, Value))
    ).

approx(V, Expected) :-
    D is abs(V - Expected),
    D < 1.0e-9.

value_ok(Expr, Vars, Expected) :-
    eval_str(Expr, Vars, ok, V),
    approx(V, Expected).

% ===========================================================================
% Algorithm A: parse_expression (syntactic validity / AST construction)
% ===========================================================================

test_algo_a_01_single_number :-
    parse_expression('42', Ast), Ast \== none.

test_algo_a_02_simple_binary :-
    parse_expression('1 + 2 * 3', Ast), Ast \== none.

test_algo_a_03_parentheses :-
    parse_expression('2 * (3 + 4) - 5', Ast), Ast \== none.

test_algo_a_04_function_call :-
    parse_expression('sqrt(16) + max(1, 2)', Ast), Ast \== none.

test_algo_a_05_nested_and_unary :-
    parse_expression('-min(max(1, 2), 3) + -(4)', Ast), Ast \== none.

test_algo_a_06_dangling_operator :-
    parse_expression('1 +', Ast), Ast == none.

test_algo_a_07_empty_string :-
    parse_expression('', Ast), Ast == none.

test_algo_a_08_unbalanced_parens :-
    parse_expression('(1 + 2', Ast), Ast == none.

test_algo_a_09_trailing_garbage :-
    parse_expression('1 + 2)', A1), A1 == none,
    parse_expression('3 4', A2), A2 == none.

test_algo_a_10_bad_function :-
    parse_expression('foo(1)', A1), A1 == none,
    parse_expression('sqrt(1, 2)', A2), A2 == none,
    parse_expression('max(1)', A3), A3 == none.

% ===========================================================================
% Algorithm B: evaluate (numeric value + error statuses)
% ===========================================================================

test_algo_b_01_precedence :-
    value_ok('3 + 4 * 2', [], 11.0).

test_algo_b_02_parens_override :-
    value_ok('(3 + 4) * 2', [], 14.0).

test_algo_b_03_power_right_assoc :-
    value_ok('2 ^ 3 ^ 2', [], 512.0).

test_algo_b_04_unary_vs_power :-
    value_ok('-2 ^ 2', [], -4.0).

test_algo_b_05_variables :-
    value_ok('x * x + y * y', [x-3.0, y-4.0], 25.0).

test_algo_b_06_undefined_var :-
    eval_str('x + 1', [], Status, _), Status == undefined_var.

test_algo_b_07_div_and_mod :-
    value_ok('10 % 3', [], 1.0),
    eval_str('5 / 0', [], Status, _), Status == div_by_zero.

test_algo_b_08_functions :-
    value_ok('max(3, 7) + min(2, 5)', [], 9.0),
    value_ok('abs(-5) + sqrt(9)', [], 8.0),
    value_ok('pow(2, 10)', [], 1024.0).

test_algo_b_09_domain_error :-
    eval_str('sqrt(-1)', [], Status, _), Status == domain_error.

test_algo_b_10_error_propagation :-
    eval_str('x + 1 / (x - 2)', [x-2.0], Status, _), Status == div_by_zero.

main :-
    writeln('=== START ==='),
    nl,
    writeln('--- Algorithm A: Parsing & AST Construction ---'),
    AlgoATests = [
        'Test A01 (Single Number)'-test_algo_a_01_single_number,
        'Test A02 (Binary + Precedence)'-test_algo_a_02_simple_binary,
        'Test A03 (Parentheses)'-test_algo_a_03_parentheses,
        'Test A04 (Function Calls)'-test_algo_a_04_function_call,
        'Test A05 (Nested + Unary)'-test_algo_a_05_nested_and_unary,
        'Test A06 (Dangling Operator)'-test_algo_a_06_dangling_operator,
        'Test A07 (Empty String)'-test_algo_a_07_empty_string,
        'Test A08 (Unbalanced Parens)'-test_algo_a_08_unbalanced_parens,
        'Test A09 (Trailing Garbage)'-test_algo_a_09_trailing_garbage,
        'Test A10 (Bad Function Call)'-test_algo_a_10_bad_function
    ],
    run_all_tests(AlgoATests, 0, 0, [], FailedARev, PassedA, FailedA),
    nl,
    writeln('--- Algorithm B: Evaluation & Error Semantics ---'),
    AlgoBTests = [
        'Test B01 (Operator Precedence)'-test_algo_b_01_precedence,
        'Test B02 (Parentheses Override)'-test_algo_b_02_parens_override,
        'Test B03 (Power Right-Assoc)'-test_algo_b_03_power_right_assoc,
        'Test B04 (Unary vs Power)'-test_algo_b_04_unary_vs_power,
        'Test B05 (Variables)'-test_algo_b_05_variables,
        'Test B06 (Undefined Variable)'-test_algo_b_06_undefined_var,
        'Test B07 (Division & Modulo)'-test_algo_b_07_div_and_mod,
        'Test B08 (Built-in Functions)'-test_algo_b_08_functions,
        'Test B09 (Domain Error)'-test_algo_b_09_domain_error,
        'Test B10 (Error Propagation)'-test_algo_b_10_error_propagation
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
