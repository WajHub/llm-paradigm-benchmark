program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, knapsack;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

function MakeInts(const Values: array of LongInt): TIntArray;
var
  I: LongInt;
begin
  SetLength(Result, Length(Values));
  for I := 0 to High(Values) do
    Result[I] := Values[I];
end;

function ReferenceDp(const Weights, Values: TIntArray; Capacity: LongInt): LongInt;
var
  Dp: array of LongInt;
  I, C, Cand: LongInt;
begin
  if (Length(Weights) = 0) or (Capacity <= 0) then
    Exit(0);
  SetLength(Dp, Capacity + 1);
  for C := 0 to Capacity do
    Dp[C] := 0;
  for I := 0 to High(Weights) do
    for C := Capacity downto Weights[I] do
    begin
      Cand := Dp[C - Weights[I]] + Values[I];
      if Cand > Dp[C] then
        Dp[C] := Cand;
    end;
  Result := Dp[Capacity];
end;

function SelectedEquals(const Actual: TIntArray; const Expected: array of LongInt): Boolean;
var
  I: LongInt;
begin
  if Length(Actual) <> Length(Expected) then
    Exit(False);
  for I := 0 to High(Expected) do
    if Actual[I] <> Expected[I] then
      Exit(False);
  Result := True;
end;

function test_algo_a_01_empty: Boolean;
var
  W, V: TIntArray;
begin
  try
    SetLength(W, 0);
    SetLength(V, 0);
    Result := KnapsackMaxValue(W, V, 10) = 0;
  except
    Result := False;
  end;
end;

function test_algo_a_02_single_fit: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([5]), MakeInts([10]), 10) = 10;
  except
    Result := False;
  end;
end;

function test_algo_a_03_too_heavy: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([15]), MakeInts([10]), 10) = 0;
  except
    Result := False;
  end;
end;

function test_algo_a_04_cap_zero: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([1, 2, 3]), MakeInts([10, 20, 30]), 0) = 0;
  except
    Result := False;
  end;
end;

function test_algo_a_05_choose_better: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([5, 6]), MakeInts([10, 11]), 10) = 11;
  except
    Result := False;
  end;
end;

function test_algo_a_06_textbook: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([2, 3, 4, 5]), MakeInts([3, 4, 5, 6]), 5) = 7;
  except
    Result := False;
  end;
end;

function test_algo_a_07_greedy_trap: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([10, 20, 30]), MakeInts([60, 100, 120]), 50) = 220;
  except
    Result := False;
  end;
end;

function test_algo_a_08_same_items: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([3, 3, 3, 3]), MakeInts([5, 5, 5, 5]), 10) = 15;
  except
    Result := False;
  end;
end;

function test_algo_a_09_tight_fit: Boolean;
begin
  try
    Result := KnapsackMaxValue(MakeInts([3, 4, 5, 6]), MakeInts([2, 3, 4, 5]), 10) = 8;
  except
    Result := False;
  end;
end;

function test_algo_a_10_stress: Boolean;
var
  W, V: TIntArray;
  I, Expected: LongInt;
begin
  try
    SetLength(W, 50);
    SetLength(V, 50);
    for I := 0 to 49 do
    begin
      W[I] := I + 1;
      V[I] := (I + 1) * 2;
    end;
    Expected := ReferenceDp(W, V, 100);
    Result := KnapsackMaxValue(W, V, 100) = Expected;
  except
    Result := False;
  end;
end;

function test_algo_b_01_single_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([5]), MakeInts([10]), 10);
    if R = nil then Exit;
    Result := (R^.MaxValue = 10) and (R^.TotalWeight = 5)
      and SelectedEquals(R^.Selected, [1]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_02_choose_better_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([5, 6]), MakeInts([10, 11]), 10);
    if R = nil then Exit;
    Result := (R^.MaxValue = 11) and (R^.TotalWeight = 6)
      and SelectedEquals(R^.Selected, [0, 1]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_03_textbook_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([2, 3, 4, 5]), MakeInts([3, 4, 5, 6]), 5);
    if R = nil then Exit;
    Result := (R^.MaxValue = 7) and (R^.TotalWeight = 5)
      and SelectedEquals(R^.Selected, [1, 1, 0, 0]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_04_greedy_trap_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([10, 20, 30]), MakeInts([60, 100, 120]), 50);
    if R = nil then Exit;
    Result := (R^.MaxValue = 220) and (R^.TotalWeight = 50)
      and SelectedEquals(R^.Selected, [0, 1, 1]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_05_cap_zero_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([1, 2, 3]), MakeInts([10, 20, 30]), 0);
    if R = nil then Exit;
    Result := (R^.MaxValue = 0) and (R^.TotalWeight = 0)
      and SelectedEquals(R^.Selected, [0, 0, 0]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_06_too_heavy_selection: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([15]), MakeInts([10]), 10);
    if R = nil then Exit;
    Result := (R^.MaxValue = 0) and (R^.TotalWeight = 0)
      and SelectedEquals(R^.Selected, [0]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_07_all_fit: Boolean;
var
  R: PKnapsackResult;
begin
  Result := False;
  R := nil;
  try
    R := KnapsackSolve(MakeInts([1, 2, 3]), MakeInts([10, 20, 30]), 10);
    if R = nil then Exit;
    Result := (R^.MaxValue = 60) and (R^.TotalWeight = 6)
      and SelectedEquals(R^.Selected, [1, 1, 1]);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_08_weight_invariant: Boolean;
var
  R: PKnapsackResult;
  W, V: TIntArray;
  I, SumW, Capacity: LongInt;
begin
  Result := False;
  R := nil;
  Capacity := 50;
  W := MakeInts([10, 20, 30]);
  V := MakeInts([60, 100, 120]);
  try
    R := KnapsackSolve(W, V, Capacity);
    if (R = nil) or (Length(R^.Selected) <> 3) then Exit;
    SumW := 0;
    for I := 0 to 2 do
      SumW := SumW + R^.Selected[I] * W[I];
    Result := (SumW <= Capacity) and (SumW = R^.TotalWeight);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_09_value_invariant: Boolean;
var
  R: PKnapsackResult;
  W, V: TIntArray;
  I, SumV: LongInt;
begin
  Result := False;
  R := nil;
  W := MakeInts([10, 20, 30]);
  V := MakeInts([60, 100, 120]);
  try
    R := KnapsackSolve(W, V, 50);
    if (R = nil) or (Length(R^.Selected) <> 3) then Exit;
    SumV := 0;
    for I := 0 to 2 do
      SumV := SumV + R^.Selected[I] * V[I];
    Result := SumV = R^.MaxValue;
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

function test_algo_b_10_stress_invariants: Boolean;
var
  R: PKnapsackResult;
  W, V: TIntArray;
  I, SumW, SumV, Expected, Capacity: LongInt;
begin
  Result := False;
  R := nil;
  Capacity := 100;
  SetLength(W, 50);
  SetLength(V, 50);
  for I := 0 to 49 do
  begin
    W[I] := I + 1;
    V[I] := (I + 1) * 2;
  end;
  Expected := ReferenceDp(W, V, Capacity);
  try
    R := KnapsackSolve(W, V, Capacity);
    if (R = nil) or (Length(R^.Selected) <> 50) then Exit;
    SumW := 0;
    SumV := 0;
    for I := 0 to 49 do
    begin
      if (R^.Selected[I] <> 0) and (R^.Selected[I] <> 1) then Exit;
      SumW := SumW + R^.Selected[I] * W[I];
      SumV := SumV + R^.Selected[I] * V[I];
    end;
    Result := (R^.MaxValue = Expected)
      and (SumW <= Capacity)
      and (SumW = R^.TotalWeight)
      and (SumV = R^.MaxValue);
  except
    Result := False;
  end;
  FreeKnapsackResult(R);
end;

procedure run_test(TestFunc: TTestFunc; const Name: AnsiString);
begin
  Inc(TotalTests);
  if TestFunc() then
    WriteLn('[PASS] ', Name)
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
  WriteLn('--- Algorithm A: Maximum Value ---');
  run_test(@test_algo_a_01_empty, 'Test A01 (Empty)');
  run_test(@test_algo_a_02_single_fit, 'Test A02 (Single Fit)');
  run_test(@test_algo_a_03_too_heavy, 'Test A03 (Too Heavy)');
  run_test(@test_algo_a_04_cap_zero, 'Test A04 (Capacity Zero)');
  run_test(@test_algo_a_05_choose_better, 'Test A05 (Choose Better)');
  run_test(@test_algo_a_06_textbook, 'Test A06 (Textbook)');
  run_test(@test_algo_a_07_greedy_trap, 'Test A07 (Greedy Trap)');
  run_test(@test_algo_a_08_same_items, 'Test A08 (Same Items)');
  run_test(@test_algo_a_09_tight_fit, 'Test A09 (Tight Fit)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress 50 Items)');

  WriteLn;
  WriteLn('--- Algorithm B: Item Selection ---');
  run_test(@test_algo_b_01_single_selection, 'Test B01 (Single Selection)');
  run_test(@test_algo_b_02_choose_better_selection, 'Test B02 (Choose Better Selection)');
  run_test(@test_algo_b_03_textbook_selection, 'Test B03 (Textbook Selection)');
  run_test(@test_algo_b_04_greedy_trap_selection, 'Test B04 (Greedy Trap Selection)');
  run_test(@test_algo_b_05_cap_zero_selection, 'Test B05 (Capacity Zero Selection)');
  run_test(@test_algo_b_06_too_heavy_selection, 'Test B06 (Too Heavy Selection)');
  run_test(@test_algo_b_07_all_fit, 'Test B07 (All Fit)');
  run_test(@test_algo_b_08_weight_invariant, 'Test B08 (Weight Invariant)');
  run_test(@test_algo_b_09_value_invariant, 'Test B09 (Value Invariant)');
  run_test(@test_algo_b_10_stress_invariants, 'Test B10 (Stress Invariants)');

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
