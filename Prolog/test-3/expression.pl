:- module(expression, [
    parse_expression/2,
    evaluate/3
]).

% AST representation (suggestion; implementation may use its own):
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

parse_expression(_, _) :-
    throw(error(existence_error(procedure, parse_expression/2), _)).

evaluate(_, _, _) :-
    throw(error(existence_error(procedure, evaluate/3), _)).
