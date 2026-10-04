program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, expression;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

{ Helpers }

function NoVars: TVariableArray;
begin
  SetLength(Result, 0);
end;

function EvalStr(const Expr: AnsiString; const Vars: TVariableArray): TEvalResult;
var
  Ast: PAstNode;
begin
  Ast := ParseExpression(Expr);
  if Ast = nil then
  begin
    Result.Status := esInvalidOp;
    Result.Value := 0.0;
    Exit;
  end;
  Result := Evaluate(Ast, Vars);
  FreeAst(Ast);
end;

function ValueOk(const R: TEvalResult; Expected: Double): Boolean;
begin
  Result := (R.Status = esOk) and (Abs(R.Value - Expected) < 1e-9);
end;

{ ========================================================================== }
{ Algorithm A: ParseExpression (syntactic validity / AST construction)        }
{ ========================================================================== }

function test_algo_a_01_single_number: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('42');
    Result := A <> nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_02_simple_binary: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('1 + 2 * 3');
    Result := A <> nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_03_parentheses: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('2 * (3 + 4) - 5');
    Result := A <> nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_04_function_call: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('sqrt(16) + max(1, 2)');
    Result := A <> nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_05_nested_and_unary: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('-min(max(1, 2), 3) + -(4)');
    Result := A <> nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_06_dangling_operator: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('1 +');
    Result := A = nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_07_empty_string: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('');
    Result := A = nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_08_unbalanced_parens: Boolean;
var A: PAstNode;
begin
  Result := False;
  try
    A := ParseExpression('(1 + 2');
    Result := A = nil;
    FreeAst(A);
  except Result := False; end;
end;

function test_algo_a_09_trailing_garbage: Boolean;
var A1, A2: PAstNode;
begin
  Result := False;
  try
    A1 := ParseExpression('1 + 2)');
    A2 := ParseExpression('3 4');
    Result := (A1 = nil) and (A2 = nil);
    FreeAst(A1);
    FreeAst(A2);
  except Result := False; end;
end;

function test_algo_a_10_bad_function: Boolean;
var A1, A2, A3: PAstNode;
begin
  Result := False;
  try
    A1 := ParseExpression('foo(1)');
    A2 := ParseExpression('sqrt(1, 2)');
    A3 := ParseExpression('max(1)');
    Result := (A1 = nil) and (A2 = nil) and (A3 = nil);
    FreeAst(A1);
    FreeAst(A2);
    FreeAst(A3);
  except Result := False; end;
end;

{ ========================================================================== }
{ Algorithm B: Evaluate (numeric value + error statuses)                      }
{ ========================================================================== }

function test_algo_b_01_precedence: Boolean;
begin
  Result := False;
  try Result := ValueOk(EvalStr('3 + 4 * 2', NoVars), 11.0); except Result := False; end;
end;

function test_algo_b_02_parens_override: Boolean;
begin
  Result := False;
  try Result := ValueOk(EvalStr('(3 + 4) * 2', NoVars), 14.0); except Result := False; end;
end;

function test_algo_b_03_power_right_assoc: Boolean;
begin
  Result := False;
  try Result := ValueOk(EvalStr('2 ^ 3 ^ 2', NoVars), 512.0); except Result := False; end;
end;

function test_algo_b_04_unary_vs_power: Boolean;
begin
  Result := False;
  try Result := ValueOk(EvalStr('-2 ^ 2', NoVars), -4.0); except Result := False; end;
end;

function test_algo_b_05_variables: Boolean;
var V: TVariableArray;
begin
  Result := False;
  try
    SetLength(V, 2);
    V[0].Name := 'x'; V[0].Value := 3.0;
    V[1].Name := 'y'; V[1].Value := 4.0;
    Result := ValueOk(EvalStr('x * x + y * y', V), 25.0);
  except Result := False; end;
end;

function test_algo_b_06_undefined_var: Boolean;
begin
  Result := False;
  try Result := EvalStr('x + 1', NoVars).Status = esUndefinedVar; except Result := False; end;
end;

function test_algo_b_07_div_and_mod: Boolean;
begin
  Result := False;
  try
    Result := ValueOk(EvalStr('10 % 3', NoVars), 1.0)
      and (EvalStr('5 / 0', NoVars).Status = esDivByZero);
  except Result := False; end;
end;

function test_algo_b_08_functions: Boolean;
begin
  Result := False;
  try
    Result := ValueOk(EvalStr('max(3, 7) + min(2, 5)', NoVars), 9.0)
      and ValueOk(EvalStr('abs(-5) + sqrt(9)', NoVars), 8.0)
      and ValueOk(EvalStr('pow(2, 10)', NoVars), 1024.0);
  except Result := False; end;
end;

function test_algo_b_09_domain_error: Boolean;
begin
  Result := False;
  try Result := EvalStr('sqrt(-1)', NoVars).Status = esDomainError; except Result := False; end;
end;

function test_algo_b_10_error_propagation: Boolean;
var V: TVariableArray;
begin
  Result := False;
  try
    SetLength(V, 1);
    V[0].Name := 'x'; V[0].Value := 2.0;
    Result := EvalStr('x + 1 / (x - 2)', V).Status = esDivByZero;
  except Result := False; end;
end;

procedure run_test(TestFunc: TTestFunc; const Name: AnsiString);
begin
  Inc(TotalTests);
  if TestFunc() then
  begin
    WriteLn('[PASS] ', Name);
  end
  else
  begin
    WriteLn('[FAIL] ', Name);
    SetLength(FailedTests, FailedCount + 1);
    FailedTests[FailedCount] := Name;
    Inc(FailedCount);
  end;
end;

var
  I: LongInt;
begin
  WriteLn('=== START ===');
  WriteLn;
  WriteLn('--- Algorithm A: Parsing & AST Construction ---');
  run_test(@test_algo_a_01_single_number, 'Test A01 (Single Number)');
  run_test(@test_algo_a_02_simple_binary, 'Test A02 (Binary + Precedence)');
  run_test(@test_algo_a_03_parentheses, 'Test A03 (Parentheses)');
  run_test(@test_algo_a_04_function_call, 'Test A04 (Function Calls)');
  run_test(@test_algo_a_05_nested_and_unary, 'Test A05 (Nested + Unary)');
  run_test(@test_algo_a_06_dangling_operator, 'Test A06 (Dangling Operator)');
  run_test(@test_algo_a_07_empty_string, 'Test A07 (Empty String)');
  run_test(@test_algo_a_08_unbalanced_parens, 'Test A08 (Unbalanced Parens)');
  run_test(@test_algo_a_09_trailing_garbage, 'Test A09 (Trailing Garbage)');
  run_test(@test_algo_a_10_bad_function, 'Test A10 (Bad Function Call)');

  WriteLn;
  WriteLn('--- Algorithm B: Evaluation & Error Semantics ---');
  run_test(@test_algo_b_01_precedence, 'Test B01 (Operator Precedence)');
  run_test(@test_algo_b_02_parens_override, 'Test B02 (Parentheses Override)');
  run_test(@test_algo_b_03_power_right_assoc, 'Test B03 (Power Right-Assoc)');
  run_test(@test_algo_b_04_unary_vs_power, 'Test B04 (Unary vs Power)');
  run_test(@test_algo_b_05_variables, 'Test B05 (Variables)');
  run_test(@test_algo_b_06_undefined_var, 'Test B06 (Undefined Variable)');
  run_test(@test_algo_b_07_div_and_mod, 'Test B07 (Division & Modulo)');
  run_test(@test_algo_b_08_functions, 'Test B08 (Built-in Functions)');
  run_test(@test_algo_b_09_domain_error, 'Test B09 (Domain Error)');
  run_test(@test_algo_b_10_error_propagation, 'Test B10 (Error Propagation)');

  WriteLn;
  WriteLn('=== BENCHMARK RESULTS ===');
  WriteLn('Completed ', TotalTests, ' tests.');

  if FailedCount = 0 then
  begin
    WriteLn('All tests passed!');
    Halt(0);
  end;

  WriteLn('Tests that failed (', FailedCount, '):');
  for I := 0 to FailedCount - 1 do
    WriteLn(' - ', FailedTests[I]);

  Halt(1);
end.
