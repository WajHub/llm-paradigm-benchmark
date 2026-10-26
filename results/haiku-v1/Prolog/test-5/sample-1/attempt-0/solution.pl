:- module(expression, [
    parse_expression/2,
    evaluate/3
]).

% AST representation:
%   number(Value)
%   variable(Name)
%   binary_op(Op, Left, Right)         % Op: '+' '-' '*' '/' '%' '^'
%   unary_op(Op, Operand)              % Op: '+' '-'
%   function_call(Name, ArgsList)      % Name: sqrt, abs, min, max, pow, sin, cos
%
% Eval result representation:
%   result(ok, Value)
%   result(div_by_zero, 0.0)
%   result(undefined_var, 0.0)
%   result(invalid_op, 0.0)
%   result(domain_error, 0.0)
%
% Parse failure: parse_expression(+ExprString, -Ast) unifies Ast with `none`.

%% ---------------------------------------------------------------
%% Parsing
%% ---------------------------------------------------------------

parse_expression(Expr, Ast) :-
    atom_codes(Expr, Cs),
    (   tokenize(Cs, Ts),
        parse_expr(Ts, A, [])
    ->  Ast = A
    ;   Ast = none
    ).

% Tokenizer ------------------------------------------------------

tokenize([], []).
tokenize([C|Cs], Ts) :-
    code_type(C, space), !,
    tokenize(Cs, Ts).
tokenize([C|Cs], [num(V)|Ts]) :-
    between(0'0, 0'9, C), !,
    take_number([C|Cs], NumCs, Rest),
    number_codes(V0, NumCs),
    V is V0 + 0.0,
    tokenize(Rest, Ts).
tokenize([C|Cs], [id(A)|Ts]) :-
    ident_start(C), !,
    take_ident(Cs, IdCs, Rest),
    atom_codes(A, [C|IdCs]),
    tokenize(Rest, Ts).
tokenize([C|Cs], [op(O)|Ts]) :-
    memberchk(C, [0'+, 0'-, 0'*, 0'/, 0'%, 0'^, 0'(, 0'), 0',]), !,
    atom_codes(O, [C]),
    tokenize(Cs, Ts).

ident_start(C) :- C =:= 0'_ ; between(0'A, 0'Z, C) ; between(0'a, 0'z, C).
ident_char(C)  :- ident_start(C) ; between(0'0, 0'9, C).

take_ident([C|Cs], [C|Ids], Rest) :-
    ident_char(C), !,
    take_ident(Cs, Ids, Rest).
take_ident(Cs, [], Cs).

take_digits([C|Cs], [C|Ds], Rest) :-
    between(0'0, 0'9, C), !,
    take_digits(Cs, Ds, Rest).
take_digits(Cs, [], Cs).

take_number(Cs, NumCs, Rest) :-
    take_digits(Cs, I, R1),
    (   R1 = [0'.|R2],
        take_digits(R2, F, R3),
        F \== []
    ->  append(I, [0'.|F], NumCs),
        Rest = R3
    ;   NumCs = I,
        Rest = R1
    ).

% Recursive descent parser ---------------------------------------

parse_expr(Ts0, Ast, Ts) :-
    parse_term(Ts0, L, Ts1),
    expr_rest(Ts1, L, Ast, Ts).

expr_rest([op(O)|Ts0], Acc, Ast, Ts) :-
    memberchk(O, ['+', '-']), !,
    parse_term(Ts0, R, Ts1),
    expr_rest(Ts1, binary_op(O, Acc, R), Ast, Ts).
expr_rest(Ts, Acc, Acc, Ts).

parse_term(Ts0, Ast, Ts) :-
    parse_unary(Ts0, L, Ts1),
    term_rest(Ts1, L, Ast, Ts).

term_rest([op(O)|Ts0], Acc, Ast, Ts) :-
    memberchk(O, ['*', '/', '%']), !,
    parse_unary(Ts0, R, Ts1),
    term_rest(Ts1, binary_op(O, Acc, R), Ast, Ts).
term_rest(Ts, Acc, Acc, Ts).

parse_unary([op(O)|Ts0], unary_op(O, X), Ts) :-
    memberchk(O, ['+', '-']), !,
    parse_unary(Ts0, X, Ts).
parse_unary(Ts0, Ast, Ts) :-
    parse_power(Ts0, Ast, Ts).

parse_power(Ts0, Ast, Ts) :-
    parse_primary(Ts0, P, Ts1),
    (   Ts1 = [op('^')|Ts2]
    ->  parse_unary(Ts2, R, Ts),
        Ast = binary_op('^', P, R)
    ;   Ast = P,
        Ts = Ts1
    ).

parse_primary([num(V)|Ts], number(V), Ts).
parse_primary([id(N)|Ts0], Ast, Ts) :-
    (   Ts0 = [op('(')|Ts1]
    ->  parse_args(Ts1, Args, Ts2),
        valid_call(N, Args),
        Ast = function_call(N, Args),
        Ts = Ts2
    ;   Ast = variable(N),
        Ts = Ts0
    ).
parse_primary([op('(')|Ts0], E, Ts) :-
    parse_expr(Ts0, E, [op(')')|Ts]).

parse_args(Ts0, [A|As], Ts) :-
    parse_expr(Ts0, A, Ts1),
    args_rest(Ts1, As, Ts).

args_rest([op(',')|Ts0], [A|As], Ts) :- !,
    parse_expr(Ts0, A, Ts1),
    args_rest(Ts1, As, Ts).
args_rest([op(')')|Ts], [], Ts).

valid_call(sqrt, [_]).
valid_call(abs,  [_]).
valid_call(sin,  [_]).
valid_call(cos,  [_]).
valid_call(min,  [_, _]).
valid_call(max,  [_, _]).
valid_call(pow,  [_, _]).

%% ---------------------------------------------------------------
%% Evaluation
%% ---------------------------------------------------------------

evaluate(number(V), _, result(ok, V)).
evaluate(variable(N), Vars, R) :-
    (   memberchk(N-V, Vars)
    ->  R = result(ok, V)
    ;   R = result(undefined_var, 0.0)
    ).
evaluate(unary_op(Op, X), Vars, R) :-
    evaluate(X, Vars, RX),
    (   RX = result(ok, V)
    ->  unary_apply(Op, V, R)
    ;   R = RX
    ).
evaluate(binary_op(Op, L, Rt), Vars, R) :-
    evaluate(L, Vars, RL),
    evaluate(Rt, Vars, RR),
    combine(Op, RL, RR, R).
evaluate(function_call(F, Args), Vars, R) :-
    eval_all(Args, Vars, Rs),
    (   member(result(S, _), Rs), S \== ok
    ->  R = result(S, 0.0)
    ;   maplist(result_value, Rs, Vs),
        call_func(F, Vs, R)
    ).

eval_all([], _, []).
eval_all([A|As], Vars, [R|Rs]) :-
    evaluate(A, Vars, R),
    eval_all(As, Vars, Rs).

result_value(result(ok, V), V).

unary_apply('-', V, result(ok, W)) :- W is -V.
unary_apply('+', V, result(ok, V)).

combine(_, result(S, _), _, result(S, 0.0)) :- S \== ok, !.
combine(_, result(ok, _), result(S, _), result(S, 0.0)) :- S \== ok, !.
combine(Op, result(ok, A), result(ok, B), R) :-
    binop(Op, A, B, R).

binop('+', A, B, result(ok, C)) :- C is A + B.
binop('-', A, B, result(ok, C)) :- C is A - B.
binop('*', A, B, result(ok, C)) :- C is A * B.
binop('/', A, B, R) :-
    (   B =:= 0
    ->  R = result(div_by_zero, 0.0)
    ;   C is A / B,
        R = result(ok, C)
    ).
binop('%', A, B, R) :-
    (   B =:= 0
    ->  R = result(div_by_zero, 0.0)
    ;   C is A - B * truncate(A / B),
        R = result(ok, C)
    ).
binop('^', A, B, R) :-
    power(A, B, R).
binop(_, _, _, result(invalid_op, 0.0)).

power(A, B, R) :-
    (   catch(Z is float(A) ** float(B), _, fail),
        float_class(Z, C),
        memberchk(C, [normal, subnormal, zero])
    ->  R = result(ok, Z)
    ;   R = result(domain_error, 0.0)
    ).

call_func(sqrt, [X], R) :-
    (   X < 0
    ->  R = result(domain_error, 0.0)
    ;   Y is sqrt(X),
        R = result(ok, Y)
    ).
call_func(abs, [X], result(ok, Y)) :- Y is abs(X).
call_func(sin, [X], result(ok, Y)) :- Y is sin(X).
call_func(cos, [X], result(ok, Y)) :- Y is cos(X).
call_func(min, [X, Y], result(ok, Z)) :- Z is min(X, Y).
call_func(max, [X, Y], result(ok, Z)) :- Z is max(X, Y).
call_func(pow, [X, Y], R) :- power(X, Y, R).
