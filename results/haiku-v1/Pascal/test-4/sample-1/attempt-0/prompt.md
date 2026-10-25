You are a Pascal programming expert. Your task is to implement the required functions in accordance with the provided unit interface.

- Implement `KnapsackMaxValue`: Return the maximum value attainable within capacity using DP. Return 0 if Length(Weights)=0 or Capacity<=0.
- Implement `KnapsackSolve`: Return a PKnapsackResult with MaxValue, Selected (0/1 array of length n), TotalWeight.
  * If n=0 return a result with MaxValue=0, empty Selected, TotalWeight=0 (or nil — tests for n=0 use MaxValue only via KnapsackMaxValue).
  * If Capacity<=0 return Selected all zeros, MaxValue=0, TotalWeight=0.
- Implement `FreeKnapsackResult(var AResult)`: Free the result. Must handle nil. Do NOT name the parameter `Result`.
- DO NOT use greedy heuristics — they fail on w=[10,20,30], v=[60,100,120], cap=50 (optimum=220).
- Selection invariants: sum of selected weights <= capacity; sum of selected values = MaxValue.

General Requirements:
- Use idiomatic procedural Pascal.
- Manage dynamically allocated structures safely.
- Return ONLY raw Pascal code (no Markdown tags, no side text).
- Do not provide test runner code.

unit knapsack;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TIntArray = array of LongInt;

  PKnapsackResult = ^TKnapsackResult;
  TKnapsackResult = record
    MaxValue: LongInt;
    Selected: TIntArray;
    N: LongInt;
    TotalWeight: LongInt;
  end;

function KnapsackMaxValue(const Weights, Values: TIntArray; Capacity: LongInt): LongInt;
function KnapsackSolve(const Weights, Values: TIntArray; Capacity: LongInt): PKnapsackResult;
procedure FreeKnapsackResult(var AResult: PKnapsackResult);

implementation

function KnapsackMaxValue(const Weights, Values: TIntArray; Capacity: LongInt): LongInt;
begin
  raise Exception.Create('KnapsackMaxValue not implemented');
  Result := -1;
end;

function KnapsackSolve(const Weights, Values: TIntArray; Capacity: LongInt): PKnapsackResult;
begin
  raise Exception.Create('KnapsackSolve not implemented');
  Result := nil;
end;

procedure FreeKnapsackResult(var AResult: PKnapsackResult);
begin
  if AResult <> nil then begin
    AResult^.Selected := nil;
    Dispose(AResult);
    AResult := nil;
  end;
end;

end.