You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

- Implement `knapsack_max_value(+Weights, +Values, +Capacity, -MaxValue)`: 0/1 knapsack via DP. Return 0 for empty list or Capacity <= 0.
- Implement `knapsack_solve(+Weights, +Values, +Capacity, -Result)`: Result = result(MaxValue, Selected, TotalWeight) where Selected is a list of 0/1 of length n.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum of selected weights <= capacity; sum of selected values = MaxValue.
- Idiomatic SWI-Prolog (memoization or pure recursion with accumulators).

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

:- module(knapsack, [
    knapsack_max_value/4,
    knapsack_solve/4
]).

% knapsack_max_value(+Weights, +Values, +Capacity, -MaxValue)
%   Returns the max value attainable.
%
% knapsack_solve(+Weights, +Values, +Capacity, -Result)
%   Result = result(MaxValue, Selected, TotalWeight)
%   where Selected is a list of 0/1 of the same length as Weights.

knapsack_max_value(_, _, _, _) :-
    throw(error(existence_error(procedure, knapsack_max_value/4), _)).

knapsack_solve(_, _, _, _) :-
    throw(error(existence_error(procedure, knapsack_solve/4), _)).