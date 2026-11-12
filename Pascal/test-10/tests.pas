program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, order_stats;

type
  TTestFunc = function: Boolean;

  { Raised by the test probe on an out-of-range read or when the read budget is exceeded. }
  EProbeError = class(Exception);

  PIntArray = ^TIntArray;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

  { Probe state shared by both sources of one MedianTwoSorted call. }
  ProbeReads: Int64 = 0;
  ProbeBudget: Int64 = 0;
  ProbeFailed: Boolean = False;

{ Helpers }

function MakeInts(const Values: array of LongInt): TIntArray;
var
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, Length(Values));
  for I := 0 to High(Values) do
    Result[I] := Values[I];
end;

function IntsEqual(const Actual: TIntArray; const Expected: array of LongInt): Boolean;
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

{ A10 generator: LCG x = (x * 1103515245 + 12345) mod 2^31, seed 42,
  r = x div 65536, value = (r mod 20001) - 10000. }
function StressValues: TIntArray;
var
  X: Int64;
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, 5000);
  X := 42;
  for I := 0 to 4999 do
  begin
    X := (X * 1103515245 + 12345) mod 2147483648;
    Result[I] := LongInt(((X div 65536) mod 20001) - 10000);
  end;
end;

function MomIs(const Xs: TIntArray; Expected: LongInt): Boolean;
var
  V: LongInt;
begin
  try
    V := 0;
    Result := MedianOfMedians(Xs, V) and (V = Expected);
  except
    Result := False;
  end;
end;

function MomAbsent(const Xs: TIntArray): Boolean;
var
  V: LongInt;
begin
  try
    Result := not MedianOfMedians(Xs, V);
  except
    Result := False;
  end;
end;

{ SelectKth(Xs, K) must return (ExpValue, ExpPivots). }
function SelIs(const Xs: TIntArray; K, ExpValue: LongInt;
  const ExpPivots: array of LongInt): Boolean;
var
  R: PSelectResult;
begin
  Result := False;
  R := nil;
  try
    R := SelectKth(Xs, K);
    if R = nil then Exit;
    Result := (R^.Value = ExpValue) and IntsEqual(R^.Pivots, ExpPivots);
  except
    Result := False;
  end;
  FreeSelectResult(R);
end;

function SelAbsent(const Xs: TIntArray; K: LongInt): Boolean;
var
  R: PSelectResult;
begin
  Result := False;
  R := nil;
  try
    R := SelectKth(Xs, K);
    Result := R = nil;
  except
    Result := False;
  end;
  FreeSelectResult(R);
end;

{ ---------- counting probe for Algorithm B ---------- }

function BitLen(X: Int64): LongInt;
begin
  Result := 0;
  while X > 0 do
  begin
    Inc(Result);
    X := X shr 1;
  end;
end;

procedure CountRead(Src: PSortedSource; Index: LongInt);
begin
  Inc(ProbeReads);
  if ProbeReads > ProbeBudget then
  begin
    ProbeFailed := True;
    raise EProbeError.Create('read budget exceeded');
  end;
  if (Src = nil) or (Index < 0) or (Index >= Src^.Len) then
  begin
    ProbeFailed := True;
    raise EProbeError.Create('index out of range');
  end;
end;

{ Literal source: Ctx points to a TIntArray. }
function GetArray(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := PIntArray(Src^.Ctx)^[Index];
end;

{ B08 a: f(i) = 2i - 1000000000 }
function GetB08A(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := LongInt(2 * Int64(Index) - 1000000000);
end;

{ B08 b: f(j) = 2j - 999999999 }
function GetB08B(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := LongInt(2 * Int64(Index) - 999999999);
end;

{ B09 b: f(j) = (j div 2) - 500000000 }
function GetB09B(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := LongInt(Int64(Index) div 2 - 500000000);
end;

{ B10 a: f(i) = i div 1000000 }
function GetB10A(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := LongInt(Int64(Index) div 1000000);
end;

{ B10 b: f(j) = 700 + (j div 3000000) }
function GetB10B(Src: PSortedSource; Index: LongInt): LongInt;
begin
  CountRead(Src, Index);
  Result := LongInt(700 + Int64(Index) div 3000000);
end;

procedure InitSource(out Src: TSortedSource; Len: LongInt; Getter: TGetFunc; Ctx: Pointer);
begin
  Src.Len := Len;
  Src.Get := Getter;
  Src.Ctx := Ctx;
end;

{ Runs MedianTwoSorted under the probe with budget 16 * (bitlen(m + n) + 1).
  Returns True iff the call completed without a probe error (no out-of-range read,
  budget respected, no error swallowed); Found / Value are the call's results. }
function ProbeMedian(var SA, SB: TSortedSource; out Found: Boolean; out Value: Double): Boolean;
begin
  ProbeReads := 0;
  ProbeFailed := False;
  ProbeBudget := 16 * (BitLen(Int64(SA.Len) + Int64(SB.Len)) + 1);
  Found := False;
  Value := 0.0;
  try
    Found := MedianTwoSorted(@SA, @SB, Value);
    Result := (not ProbeFailed) and (ProbeReads <= ProbeBudget);
  except
    Result := False;
  end;
end;

{ Median of two literal sorted arrays must be Expected. }
function MedianLiteralIs(const AData, BData: array of LongInt; Expected: Double): Boolean;
var
  DA, DB: TIntArray;
  SA, SB: TSortedSource;
  Found: Boolean;
  V: Double;
begin
  DA := MakeInts(AData);
  DB := MakeInts(BData);
  InitSource(SA, Length(DA), @GetArray, @DA);
  InitSource(SB, Length(DB), @GetArray, @DB);
  Result := ProbeMedian(SA, SB, Found, V) and Found and (Abs(V - Expected) < 1e-9);
end;

{ ========================================================================== }
{ Algorithm A: Median of Medians                                              }
{ ========================================================================== }

function test_algo_a_01_empty: Boolean;
var
  Xs: TIntArray;
begin
  Xs := nil;
  Result := MomAbsent(Xs) and SelAbsent(Xs, 0);
end;

function test_algo_a_02_single: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([7]);
  Result := MomIs(Xs, 7) and SelIs(Xs, 0, 7, []) and SelAbsent(Xs, 1);
end;

function test_algo_a_03_out_of_range: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([3, 1, 2]);
  Result := SelAbsent(Xs, 3) and SelAbsent(Xs, -1) and SelIs(Xs, 2, 3, [])
    and MomIs(Xs, 2);
end;

function test_algo_a_04_one_group: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([9, 1, 8, 2, 7]);
  Result := MomIs(Xs, 7) and SelIs(Xs, 0, 1, []) and SelIs(Xs, 2, 7, [])
    and SelIs(Xs, 4, 9, []);
end;

function test_algo_a_05_pivot_is_not_median: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  Result := MomIs(Xs, 3) and SelIs(Xs, 4, 5, [3, 6]) and SelIs(Xs, 5, 6, [3, 6]);
end;

function test_algo_a_06_partial_last_group: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([5, 3, 9, 1, 8, 2, 6]);
  Result := MomIs(Xs, 2) and SelIs(Xs, 3, 5, [2]) and SelIs(Xs, 6, 9, [2]);
end;

function test_algo_a_07_many_duplicates: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([5, 5, 5, 1, 5, 5, 9, 5, 5, 5, 5]);
  Result := MomIs(Xs, 5) and SelIs(Xs, 0, 1, [5]) and SelIs(Xs, 5, 5, [5])
    and SelIs(Xs, 10, 9, [5]);
end;

function test_algo_a_08_stable_partition_order: Boolean;
var
  Xs: TIntArray;
begin
  Xs := MakeInts([40, 54, 53, 18, 19, 56, 52, 33, 58, 51, 41, 27]);
  Result := MomIs(Xs, 40) and SelIs(Xs, 6, 51, [40, 41, 51]);
end;

function test_algo_a_09_all_ranks: Boolean;
const
  A09_XS: array[0..22] of LongInt =
    (12, -7, 3, 3, 25, 0, -7, 18, 3, 9, 41, -2, 3, 16, -30, 7, 7, 22, -11, 5, 3, 0, 14);
  A09_SORTED: array[0..22] of LongInt =
    (-30, -11, -7, -7, -2, 0, 0, 3, 3, 3, 3, 3, 5, 7, 7, 9, 12, 14, 16, 18, 22, 25, 41);
var
  Xs: TIntArray;
  K: LongInt;
begin
  Result := False;
  Xs := MakeInts(A09_XS);
  if not MomIs(Xs, 3) then Exit;
  for K := 0 to 22 do
  begin
    if K <= 6 then
    begin
      if not SelIs(Xs, K, A09_SORTED[K], [3, -11]) then Exit;
    end
    else if K <= 11 then
    begin
      if not SelIs(Xs, K, A09_SORTED[K], [3]) then Exit;
    end
    else
    begin
      if not SelIs(Xs, K, A09_SORTED[K], [3, 14]) then Exit;
    end;
  end;
  Result := IntsEqual(Xs, A09_XS);
end;

function test_algo_a_10_stress: Boolean;
var
  Xs: TIntArray;
begin
  Xs := StressValues;
  Result := MomIs(Xs, -1678)
    and SelIs(Xs, 0, -9996,
      [-1678, -5890, -7989, -9070, -9559, -9795, -9899, -9942, -9982, -9995])
    and SelIs(Xs, 2499, -1694,
      [-1678, -5890, -3836, -2653, -2238, -1989, -1834, -1771, -1720, -1694])
    and SelIs(Xs, 4999, 9984,
      [-1678, 2387, 6069, 7942, 9014, 9543, 9788, 9878, 9930, 9951, 9974]);
end;

{ ========================================================================== }
{ Algorithm B: Median of Two Sorted Arrays                                    }
{ ========================================================================== }

function test_algo_b_01_both_empty: Boolean;
var
  DA, DB: TIntArray;
  SA, SB: TSortedSource;
  Found: Boolean;
  V: Double;
begin
  DA := nil;
  DB := nil;
  InitSource(SA, 0, @GetArray, @DA);
  InitSource(SB, 0, @GetArray, @DB);
  Result := ProbeMedian(SA, SB, Found, V) and (not Found);
end;

function test_algo_b_02_one_empty: Boolean;
begin
  Result := MedianLiteralIs([], [1, 2, 3, 4], 2.5);
end;

function test_algo_b_03_single_each: Boolean;
begin
  Result := MedianLiteralIs([1], [2], 1.5);
end;

function test_algo_b_04_odd_total_interleaved: Boolean;
begin
  Result := MedianLiteralIs([1, 3, 5], [2, 4], 3.0);
end;

function test_algo_b_05_disjoint_ranges: Boolean;
begin
  Result := MedianLiteralIs([10, 11, 12, 13], [1, 2, 3], 10.0);
end;

function test_algo_b_06_duplicates: Boolean;
begin
  Result := MedianLiteralIs([1, 1, 1, 1], [1, 1, 2], 1.0);
end;

function test_algo_b_07_no_overflow: Boolean;
begin
  Result := MedianLiteralIs([2147483647], [2147483647], 2147483647.0)
    and MedianLiteralIs([-2147483647 - 1, 2147483647], [], -0.5);
end;

function test_algo_b_08_huge_interleaved: Boolean;
var
  SA, SB: TSortedSource;
  Found: Boolean;
  V: Double;
begin
  InitSource(SA, 1000000000, @GetB08A, nil);
  InitSource(SB, 999999999, @GetB08B, nil);
  Result := ProbeMedian(SA, SB, Found, V) and Found and (Abs(V - (-1.0)) < 1e-9);
end;

function test_algo_b_09_huge_unbalanced: Boolean;
var
  DA: TIntArray;
  SA, SB: TSortedSource;
  Found: Boolean;
  V: Double;
begin
  DA := MakeInts([-5, 0, 7]);
  InitSource(SA, Length(DA), @GetArray, @DA);
  InitSource(SB, 2000000000, @GetB09B, nil);
  Result := ProbeMedian(SA, SB, Found, V) and Found and (Abs(V - 0.0) < 1e-9);
end;

function test_algo_b_10_huge_duplicates: Boolean;
var
  SA, SB: TSortedSource;
  Found: Boolean;
  V: Double;
begin
  InitSource(SA, 1500000000, @GetB10A, nil);
  InitSource(SB, 600000000, @GetB10B, nil);
  Result := ProbeMedian(SA, SB, Found, V) and Found and (Abs(V - 787.0) < 1e-9);
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
  WriteLn('--- Algorithm A: Median of Medians ---');
  run_test(@test_algo_a_01_empty, 'Test A01 (Empty)');
  run_test(@test_algo_a_02_single, 'Test A02 (Single)');
  run_test(@test_algo_a_03_out_of_range, 'Test A03 (Out Of Range)');
  run_test(@test_algo_a_04_one_group, 'Test A04 (One Group)');
  run_test(@test_algo_a_05_pivot_is_not_median, 'Test A05 (Pivot Is Not Median)');
  run_test(@test_algo_a_06_partial_last_group, 'Test A06 (Partial Last Group)');
  run_test(@test_algo_a_07_many_duplicates, 'Test A07 (Many Duplicates)');
  run_test(@test_algo_a_08_stable_partition_order, 'Test A08 (Stable Partition Order)');
  run_test(@test_algo_a_09_all_ranks, 'Test A09 (All Ranks)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress)');

  WriteLn;
  WriteLn('--- Algorithm B: Median of Two Sorted Arrays ---');
  run_test(@test_algo_b_01_both_empty, 'Test B01 (Both Empty)');
  run_test(@test_algo_b_02_one_empty, 'Test B02 (One Empty)');
  run_test(@test_algo_b_03_single_each, 'Test B03 (Single Each)');
  run_test(@test_algo_b_04_odd_total_interleaved, 'Test B04 (Odd Total Interleaved)');
  run_test(@test_algo_b_05_disjoint_ranges, 'Test B05 (Disjoint Ranges)');
  run_test(@test_algo_b_06_duplicates, 'Test B06 (Duplicates)');
  run_test(@test_algo_b_07_no_overflow, 'Test B07 (No Overflow)');
  run_test(@test_algo_b_08_huge_interleaved, 'Test B08 (Huge Interleaved)');
  run_test(@test_algo_b_09_huge_unbalanced, 'Test B09 (Huge Unbalanced)');
  run_test(@test_algo_b_10_huge_duplicates, 'Test B10 (Huge Duplicates)');

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
