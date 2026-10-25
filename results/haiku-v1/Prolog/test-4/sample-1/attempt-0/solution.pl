:- module(knapsack, [
    knapsack_max_value/4,
    knapsack_solve/4
]).

% knapsack_max_value(+Weights, +Values, +Capacity, -MaxValue)
%   Returns the max value attainable.
knapsack_max_value(Ws, Vs, Cap, Max) :-
    knapsack_solve(Ws, Vs, Cap, result(Max, _, _)).

% knapsack_solve(+Weights, +Values, +Capacity, -Result)
%   Result = result(MaxValue, Selected, TotalWeight)
%   where Selected is a list of 0/1 of the same length as Weights.
knapsack_solve(Ws, Vs, Cap, result(Max, Sel, TW)) :-
    length(Ws, N),
    length(Vs, N),
    (   (N =:= 0 ; Cap =< 0)
    ->  length(Sel, N),
        maplist(=(0), Sel),
        Max = 0,
        TW = 0
    ;   Size is Cap + 1,
        length(T0, Size),
        maplist(=(best(0, [])), T0),
        fold_items(Ws, Vs, T0, T),
        last(T, best(Max, RevSel)),
        reverse(RevSel, Sel),
        sum_weights(Ws, Sel, TW)
    ).

% ---- DP over items -------------------------------------------------------

fold_items([], [], T, T).
fold_items([W|Ws], [V|Vs], T0, T) :-
    step(W, V, T0, T1),
    fold_items(Ws, Vs, T1, T).

% step(+W, +V, +Old, -New): one 0/1 item processed over all capacities.
% Old and New are lists indexed by capacity 0..Cap, holding best(Value, RevSelection).
step(W, V, Old, New) :-
    length(Old, L),
    length(Pad, W),
    maplist(=(none), Pad),
    append(Pad, Old, Ext),
    length(Shifted, L),
    append(Shifted, _, Ext),
    combine(Old, Shifted, V, New).

combine([], [], _, []).
combine([O|Os], [S|Ss], V, [N|Ns]) :-
    O = best(OV, OSel),
    (   S == none
    ->  N = best(OV, [0|OSel])
    ;   S = best(SV, SSel),
        SV2 is SV + V,
        (   SV2 > OV
        ->  N = best(SV2, [1|SSel])
        ;   N = best(OV, [0|OSel])
        )
    ),
    combine(Os, Ss, V, Ns).

% ---- Selection weight ----------------------------------------------------

sum_weights([], [], 0).
sum_weights([W|Ws], [S|Ss], Total) :-
    sum_weights(Ws, Ss, Rest),
    Total is Rest + S * W.
