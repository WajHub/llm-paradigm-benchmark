program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, tsp_approx;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

{ Helpers }

{ Builds a point array from flat coordinates x0, y0, x1, y1, ... }
function MakePts(const Coords: array of LongInt): TTspPointArray;
var
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, Length(Coords) div 2);
  for I := 0 to High(Result) do
  begin
    Result[I].X := Coords[2 * I];
    Result[I].Y := Coords[2 * I + 1];
  end;
end;

function EmptyPts: TTspPointArray;
begin
  Result := nil;
end;

function SinglePts: TTspPointArray;
begin
  Result := MakePts([5, 5]);
end;

function TwoPts: TTspPointArray;
begin
  Result := MakePts([0, 0, 3, 4]);
end;

function CollinearPts: TTspPointArray;
begin
  Result := MakePts([0, 0, 4, 0, 1, 0, 9, 0, 6, 0]);
end;

function SquarePts: TTspPointArray;
begin
  Result := MakePts([0, 0, 0, 2, 2, 2, 2, 0]);
end;

function ParentTiePts: TTspPointArray;
begin
  Result := MakePts([2, 0, 0, 3, 2, 3, 3, 4, 1, 4]);
end;

function GridPts: TTspPointArray;
begin
  Result := MakePts([0, 0, 1, 0, 2, 0, 0, 1, 1, 1, 2, 1, 0, 2, 1, 2, 2, 2]);
end;

function DupPts: TTspPointArray;
begin
  Result := MakePts([3, 3, 3, 3, 0, 0, 3, 3]);
end;

function StarPts: TTspPointArray;
begin
  Result := MakePts([5, 5, 5, 0, 0, 5, 10, 5]);
end;

function ClustersPts: TTspPointArray;
begin
  Result := MakePts([0, 0, 20, 0, 1, 1, 21, 1, 0, 20, 20, 20, 1, 21, 21, 21]);
end;

function SpiralPts: TTspPointArray;
begin
  Result := MakePts([0, 0, 8, 0, 8, 8, 0, 8, 2, 2, 6, 2, 6, 6, 2, 6, 4, 4]);
end;

function S12Pts: TTspPointArray;
begin
  Result := MakePts([81, 33, 69, 61, 56, 93, 77, 0, 65, 25, 72, 14, 14, 48, 33, 32,
    73, 63, 71, 87, 5, 8, 54, 24]);
end;

function S20Pts: TTspPointArray;
begin
  Result := MakePts([38, 58, 13, 15, 51, 27, 10, 19, 12, 86, 49, 67, 84, 60, 25, 43,
    89, 83, 37, 66, 66, 78, 95, 11, 67, 54, 31, 45, 82, 36, 24, 5, 94, 2, 51, 67,
    54, 53, 61, 96]);
end;

function S40Pts: TTspPointArray;
begin
  Result := MakePts([81, 33, 69, 61, 56, 93, 77, 0, 65, 25, 72, 14, 14, 48, 33, 32,
    73, 63, 71, 87, 5, 8, 54, 24, 22, 71, 51, 45, 55, 89, 29, 78, 87, 65, 32, 67,
    53, 10, 27, 83, 36, 30, 41, 96, 2, 37, 8, 85, 78, 74, 59, 59, 76, 26, 9, 63,
    63, 86, 7, 17, 91, 65, 27, 22, 7, 85, 95, 32, 35, 71, 7, 65, 12, 61, 82, 60,
    5, 35, 74, 66]);
end;

function Dist(const Pts: TTspPointArray; U, V: LongInt): LongInt;
begin
  Result := Abs(Pts[U].X - Pts[V].X) + Abs(Pts[U].Y - Pts[V].Y);
end;

{ True iff R is a valid tour of Pts: length n, permutation of 0..n-1, starts with 0,
  and R^.Cost equals the closed-tour cost recomputed from the points. }
function ValidTour(R: PTourResult; const Pts: TTspPointArray): Boolean;
var
  N, I, Cost: LongInt;
  Seen: array of Boolean;
begin
  Result := False;
  if R = nil then Exit;
  N := Length(Pts);
  if Length(R^.Tour) <> N then Exit;
  if (N = 0) or (R^.Tour[0] <> 0) then Exit;
  Seen := nil;
  SetLength(Seen, N);
  for I := 0 to N - 1 do
    Seen[I] := False;
  for I := 0 to N - 1 do
  begin
    if (R^.Tour[I] < 0) or (R^.Tour[I] >= N) then Exit;
    if Seen[R^.Tour[I]] then Exit;
    Seen[R^.Tour[I]] := True;
  end;
  Cost := 0;
  if N > 1 then
    for I := 0 to N - 1 do
      Cost := Cost + Dist(Pts, R^.Tour[I], R^.Tour[(I + 1) mod N]);
  Result := Cost = R^.Cost;
end;

function TourEquals(R: PTourResult; const Expected: array of LongInt): Boolean;
var
  I: LongInt;
begin
  Result := False;
  if R = nil then Exit;
  if Length(R^.Tour) <> Length(Expected) then Exit;
  for I := 0 to High(Expected) do
    if R^.Tour[I] <> Expected[I] then Exit;
  Result := True;
end;

{ Algorithm A check: MST weight, exact double-tree tour and cost; MaxCost >= 0 adds
  the bound Cost <= MaxCost. }
function CheckDoubleTree(const Pts: TTspPointArray; ExpMst: LongInt;
  const ExpTour: array of LongInt; ExpCost, MaxCost: LongInt): Boolean;
var
  R: PTourResult;
begin
  Result := False;
  R := nil;
  try
    if TspMstWeight(Pts) <> ExpMst then Exit;
    R := TspDoubleTree(Pts);
    if R = nil then Exit;
    Result := ValidTour(R, Pts) and TourEquals(R, ExpTour) and (R^.Cost = ExpCost)
      and ((MaxCost < 0) or (R^.Cost <= MaxCost));
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

{ Algorithm B check: matching weight, valid Christofides tour.
  ExactCost >= 0: Cost must equal it; MaxCost >= 0: Cost <= MaxCost;
  Opt > 0: 2 * Cost <= 3 * Opt. }
function CheckChristofides(const Pts: TTspPointArray; ExpMatching, ExactCost,
  MaxCost, Opt: LongInt): Boolean;
var
  R: PTourResult;
begin
  Result := False;
  R := nil;
  try
    if TspMatchingWeight(Pts) <> ExpMatching then Exit;
    R := TspChristofides(Pts);
    if R = nil then Exit;
    Result := ValidTour(R, Pts)
      and ((ExactCost < 0) or (R^.Cost = ExactCost))
      and ((MaxCost < 0) or (R^.Cost <= MaxCost))
      and ((Opt <= 0) or (2 * R^.Cost <= 3 * Opt));
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

{ ========================================================================== }
{ Algorithm A: MST Double Tree                                                }
{ ========================================================================== }

function test_algo_a_01_empty: Boolean;
var
  R: PTourResult;
begin
  Result := False;
  R := nil;
  try
    if TspMstWeight(EmptyPts) <> 0 then Exit;
    R := TspDoubleTree(EmptyPts);
    Result := R = nil;
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

function test_algo_a_02_single_point: Boolean;
begin
  Result := CheckDoubleTree(SinglePts, 0, [0], 0, -1);
end;

function test_algo_a_03_two_points: Boolean;
begin
  Result := CheckDoubleTree(TwoPts, 7, [0, 1], 14, -1);
end;

function test_algo_a_04_collinear_unsorted: Boolean;
begin
  Result := CheckDoubleTree(CollinearPts, 9, [0, 2, 1, 4, 3], 18, -1);
end;

function test_algo_a_05_square: Boolean;
begin
  Result := CheckDoubleTree(SquarePts, 6, [0, 1, 2, 3], 8, -1);
end;

function test_algo_a_06_parent_tie_breaking: Boolean;
begin
  Result := CheckDoubleTree(ParentTiePts, 9, [0, 2, 1, 4, 3], 14, -1);
end;

function test_algo_a_07_grid_ties: Boolean;
begin
  Result := CheckDoubleTree(GridPts, 8, [0, 1, 2, 5, 8, 4, 7, 3, 6], 12, -1);
end;

function test_algo_a_08_duplicate_points: Boolean;
begin
  Result := CheckDoubleTree(DupPts, 6, [0, 1, 2, 3], 12, -1);
end;

function test_algo_a_09_clusters_two_approx: Boolean;
begin
  Result := CheckDoubleTree(ClustersPts, 68, [0, 1, 3, 5, 7, 2, 4, 6], 128, 2 * 88);
end;

function test_algo_a_10_stress: Boolean;
var
  Pts: TTspPointArray;
  R: PTourResult;
begin
  Result := False;
  R := nil;
  Pts := S40Pts;
  try
    if TspMstWeight(Pts) <> 503 then Exit;
    R := TspDoubleTree(Pts);
    if R = nil then Exit;
    Result := ValidTour(R, Pts) and (R^.Cost = 832);
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

{ ========================================================================== }
{ Algorithm B: Christofides                                                   }
{ ========================================================================== }

function test_algo_b_01_empty: Boolean;
var
  R: PTourResult;
begin
  Result := False;
  R := nil;
  try
    if TspMatchingWeight(EmptyPts) <> 0 then Exit;
    R := TspChristofides(EmptyPts);
    Result := R = nil;
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

function test_algo_b_02_two_points_double_edge: Boolean;
var
  Pts: TTspPointArray;
  R: PTourResult;
begin
  Result := False;
  R := nil;
  Pts := TwoPts;
  try
    if TspMatchingWeight(Pts) <> 7 then Exit;
    R := TspChristofides(Pts);
    if R = nil then Exit;
    Result := ValidTour(R, Pts) and TourEquals(R, [0, 1]) and (R^.Cost = 14);
  except
    Result := False;
  end;
  FreeTourResult(R);
end;

function test_algo_b_03_star_parallel_edges: Boolean;
begin
  Result := CheckChristofides(StarPts, 15, 30, -1, 0);
end;

function test_algo_b_04_collinear: Boolean;
begin
  Result := CheckChristofides(CollinearPts, 9, 18, -1, 0);
end;

function test_algo_b_05_grid: Boolean;
begin
  Result := CheckChristofides(GridPts, 4, -1, 12, 0);
end;

function test_algo_b_06_beats_double_tree: Boolean;
begin
  Result := CheckChristofides(ClustersPts, 24, -1, 92, 0);
end;

function test_algo_b_07_spiral_bound: Boolean;
begin
  Result := CheckChristofides(SpiralPts, 20, -1, 52, 44);
end;

function test_algo_b_08_greedy_matching_trap: Boolean;
begin
  Result := CheckChristofides(S12Pts, 163, -1, 440, 396);
end;

function test_algo_b_09_duplicate_points: Boolean;
begin
  Result := CheckChristofides(DupPts, 6, 12, -1, 0);
end;

function test_algo_b_10_stress: Boolean;
begin
  Result := CheckChristofides(S20Pts, 211, -1, 608, 540);
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
  WriteLn('--- Algorithm A: MST Double Tree ---');
  run_test(@test_algo_a_01_empty, 'Test A01 (Empty)');
  run_test(@test_algo_a_02_single_point, 'Test A02 (Single Point)');
  run_test(@test_algo_a_03_two_points, 'Test A03 (Two Points)');
  run_test(@test_algo_a_04_collinear_unsorted, 'Test A04 (Collinear Unsorted)');
  run_test(@test_algo_a_05_square, 'Test A05 (Square)');
  run_test(@test_algo_a_06_parent_tie_breaking, 'Test A06 (Parent Tie Breaking)');
  run_test(@test_algo_a_07_grid_ties, 'Test A07 (Grid Ties)');
  run_test(@test_algo_a_08_duplicate_points, 'Test A08 (Duplicate Points)');
  run_test(@test_algo_a_09_clusters_two_approx, 'Test A09 (Clusters Two Approx)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress)');

  WriteLn;
  WriteLn('--- Algorithm B: Christofides ---');
  run_test(@test_algo_b_01_empty, 'Test B01 (Empty)');
  run_test(@test_algo_b_02_two_points_double_edge, 'Test B02 (Two Points Double Edge)');
  run_test(@test_algo_b_03_star_parallel_edges, 'Test B03 (Star Parallel Edges)');
  run_test(@test_algo_b_04_collinear, 'Test B04 (Collinear)');
  run_test(@test_algo_b_05_grid, 'Test B05 (Grid)');
  run_test(@test_algo_b_06_beats_double_tree, 'Test B06 (Beats Double Tree)');
  run_test(@test_algo_b_07_spiral_bound, 'Test B07 (Spiral Bound)');
  run_test(@test_algo_b_08_greedy_matching_trap, 'Test B08 (Greedy Matching Trap)');
  run_test(@test_algo_b_09_duplicate_points, 'Test B09 (Duplicate Points)');
  run_test(@test_algo_b_10_stress, 'Test B10 (Stress)');

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
