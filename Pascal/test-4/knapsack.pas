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
