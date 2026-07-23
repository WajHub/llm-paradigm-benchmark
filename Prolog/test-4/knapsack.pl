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
