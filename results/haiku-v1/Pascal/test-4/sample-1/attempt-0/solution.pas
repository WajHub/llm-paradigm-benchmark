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
var
  dp: array of LongInt;
  i, j, n, w, v: LongInt;
begin
  Result := 0;
  n := Min(Length(Weights), Length(Values));
  if (n = 0) or (Capacity <= 0) then
    Exit;

  SetLength(dp, Capacity + 1);
  for j := 0 to Capacity do
    dp[j] := 0;

  for i := 0 to n - 1 do
  begin
    w := Weights[i];
    v := Values[i];
    if (w < 0) or (v <= 0) then
      Continue;
    for j := Capacity downto w do
      if dp[j - w] + v > dp[j] then
        dp[j] := dp[j - w] + v;
  end;

  Result := dp[Capacity];
end;

function KnapsackSolve(const Weights, Values: TIntArray; Capacity: LongInt): PKnapsackResult;
var
  res: PKnapsackResult;
  dp: array of array of LongInt;
  i, j, n, w, v: LongInt;
  total: LongInt;
begin
  New(res);
  res^.MaxValue := 0;
  res^.N := 0;
  res^.TotalWeight := 0;
  SetLength(res^.Selected, 0);

  n := Min(Length(Weights), Length(Values));
  res^.N := n;
  SetLength(res^.Selected, n);
  for i := 0 to n - 1 do
    res^.Selected[i] := 0;

  if (n = 0) or (Capacity <= 0) then
  begin
    Result := res;
    Exit;
  end;

  SetLength(dp, n + 1, Capacity + 1);
  for j := 0 to Capacity do
    dp[0][j] := 0;

  for i := 1 to n do
  begin
    w := Weights[i - 1];
    v := Values[i - 1];
    for j := 0 to Capacity do
    begin
      dp[i][j] := dp[i - 1][j];
      if (w >= 0) and (v > 0) and (w <= j) and (dp[i - 1][j - w] + v > dp[i][j]) then
        dp[i][j] := dp[i - 1][j - w] + v;
    end;
  end;

  res^.MaxValue := dp[n][Capacity];

  total := 0;
  j := Capacity;
  for i := n downto 1 do
  begin
    if dp[i][j] <> dp[i - 1][j] then
    begin
      res^.Selected[i - 1] := 1;
      total := total + Weights[i - 1];
      j := j - Weights[i - 1];
    end;
  end;
  res^.TotalWeight := total;

  Result := res;
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
