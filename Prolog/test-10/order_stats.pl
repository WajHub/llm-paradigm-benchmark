:- module(order_stats, [
    median_of_medians/2,
    select_kth/3,
    median_two_sorted/3
]).

% Algorithm A - deterministic selection (BFPRT) with a pivot trace.
%
% median_of_medians(+Xs, -M)
%   Xs is a list of integers. Split Xs in its current order into consecutive
%   groups of 5 (the last group may have 1-4 elements), take the lower median of
%   every group, M = lower median of the list of group medians.
%   Lower median of a group G = element at 0-based index (length(G) - 1) // 2 of
%   G sorted ascending (duplicates kept). M = none if Xs = [].
%
% select_kth(+Xs, +K, -Result)
%   K is 0-based. Result = select(Value, Pivots) where Value is the K-th
%   smallest element of Xs and Pivots is the list of pivots chosen by the
%   procedure described in the task, top level first.
%   Result = none if K < 0 or K >= length(Xs).
%
% Algorithm B - median of two sorted sources under a read budget.
%
% A source is source(Length, Getter): a non-decreasing sequence of integers of
% length Length >= 0 whose element with 0-based index I (0 =< I < Length) is read
% with call(Getter, I, Value). Every call counts as one read.
%
% median_two_sorted(+A, +B, -Median)
%   Median of the merged multiset of both sources: the middle element for an
%   odd total, the arithmetic mean of the two middle elements for an even total.
%   Median is a number (integer or float). Median = none if both are empty.

median_of_medians(_, _) :-
    throw(error(existence_error(procedure, median_of_medians/2), _)).

select_kth(_, _, _) :-
    throw(error(existence_error(procedure, select_kth/3), _)).

median_two_sorted(_, _, _) :-
    throw(error(existence_error(procedure, median_two_sorted/3), _)).
