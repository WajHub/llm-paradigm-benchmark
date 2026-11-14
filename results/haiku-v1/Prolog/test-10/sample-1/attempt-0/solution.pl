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
% median_two_sorted(+A, +B, -Median)
%   Median of the merged multiset of both sources: the middle element for an
%   odd total, the arithmetic mean of the two middle elements for an even total.
%   Median = none if both are empty.

median_of_medians([], none) :- !.
median_of_medians(Xs, M) :-
    chunks5(Xs, Groups),
    maplist(lower_median, Groups, Meds),
    lower_median(Meds, M).

chunks5([], []) :- !.
chunks5(L, [G|Gs]) :-
    take(5, L, G, Rest),
    chunks5(Rest, Gs).

take(0, L, [], L) :- !.
take(_, [], [], []) :- !.
take(N, [X|Xs], [X|Ys], R) :-
    N1 is N - 1,
    take(N1, Xs, Ys, R).

lower_median(L, M) :-
    msort(L, S),
    length(S, N),
    I is (N - 1) // 2,
    nth0(I, S, M).

select_kth(Xs, K, Result) :-
    length(Xs, Len),
    (   K < 0 ; K >= Len )
    ->  Result = none
    ;   select_loop(Xs, K, [], Value, Pivots),
        Result = select(Value, Pivots).

select_loop(Cur, K, Acc, Value, Pivots) :-
    length(Cur, N),
    (   N =< 5
    ->  msort(Cur, S),
        nth0(K, S, Value),
        reverse(Acc, Pivots)
    ;   median_of_medians(Cur, P),
        include(lt_pivot(P), Cur, L),
        include(gt_pivot(P), Cur, G),
        include(eq_pivot(P), Cur, Eq),
        length(L, NL),
        length(Eq, E),
        (   K < NL
        ->  select_loop(L, K, [P|Acc], Value, Pivots)
        ;   K < NL + E
        ->  Value = P,
            reverse([P|Acc], Pivots)
        ;   K2 is K - NL - E,
            select_loop(G, K2, [P|Acc], Value, Pivots)
        )
    ).

lt_pivot(P, X) :- X < P.
gt_pivot(P, X) :- X > P.
eq_pivot(P, X) :- X =:= P.

% Algorithm B

median_two_sorted(source(LA, GA), source(LB, GB), Median) :-
    N is LA + LB,
    (   N =:= 0
    ->  Median = none
    ;   N mod 2 =:= 1
    ->  M is (N - 1) // 2,
        kth(GA, 0, LA, GB, 0, LB, M, Median)
    ;   M1 is N // 2 - 1,
        M2 is N // 2,
        kth(GA, 0, LA, GB, 0, LB, M1, X),
        kth(GA, 0, LA, GB, 0, LB, M2, Y),
        Median is (X + Y) / 2
    ).

% kth(+GA, +Ia, +La, +GB, +Ib, +Lb, +K, -V)
%   V is the element of rank K (0-based) in the merge of the remaining
%   parts A[Ia..Ia+La-1] and B[Ib..Ib+Lb-1]. Each round discards about K/2
%   elements from one of the sequences, reading two elements per round.
kth(GA, Ia, La, GB, Ib, Lb, K, V) :-
    (   La =:= 0
    ->  I is Ib + K,
        call(GB, I, V)
    ;   Lb =:= 0
    ->  I is Ia + K,
        call(GA, I, V)
    ;   K =:= 0
    ->  call(GA, Ia, X),
        call(GB, Ib, Y),
        V is min(X, Y)
    ;   H is (K + 1) // 2,
        I is min(La, H),
        J is min(Lb, H),
        IA1 is Ia + I - 1,
        JB1 is Ib + J - 1,
        call(GA, IA1, X),
        call(GB, JB1, Y),
        (   X =< Y
        ->  Ia2 is Ia + I,
            La2 is La - I,
            K2 is K - I,
            kth(GA, Ia2, La2, GB, Ib, Lb, K2, V)
        ;   Ib2 is Ib + J,
            Lb2 is Lb - J,
            K2 is K - J,
            kth(GA, Ia, La, GB, Ib2, Lb2, K2, V)
        )
    ).
