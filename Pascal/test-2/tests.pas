program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, shortest_path;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

function ApproxEqual(A, B: Double): Boolean;
begin
  Result := Abs(A - B) < 1e-9;
end;

function DistanceIs(Actual, Expected: Double): Boolean;
begin
  if IsInfinite(Expected) then
    Result := IsInfinite(Actual) and (Actual > 0)
  else
    Result := ApproxEqual(Actual, Expected);
end;

function CheckDistance(DijkstraResult: PDijkstraResult; Target: Integer; Expected: Double): Boolean;
begin
  Result := DistanceIs(GetShortestDistance(DijkstraResult, Target), Expected);
end;

function PathEquals(const Path: TIntArray; PathLength: Integer; const Expected: array of Integer): Boolean;
var
  I: LongInt;
begin
  if PathLength <> Length(Expected) then
    Exit(False);

  if PathLength = 0 then
    Exit(Length(Path) = 0);

  if Length(Path) <> PathLength then
    Exit(False);

  for I := 0 to PathLength - 1 do
  begin
    if Path[I] <> Expected[I] then
      Exit(False);
  end;

  Result := True;
end;

procedure FreePath(var Path: TIntArray);
begin
  SetLength(Path, 0);
end;

function CreateLinearChain(NumVertices: Integer; Weight: Double): PGraph;
var
  I: Integer;
begin
  Result := CreateGraph(NumVertices);
  if Result = nil then
    Exit;

  for I := 0 to NumVertices - 2 do
    GraphAddEdge(Result, I, I + 1, Weight);
end;

function test_algo_a_01_linear_chain: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 1, 2, 2.0);
    GraphAddEdge(Graph, 2, 3, 3.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := True;
    if not CheckDistance(DijkstraResult, 0, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 1, 1.0) then Result := False;
    if not CheckDistance(DijkstraResult, 2, 3.0) then Result := False;
    if not CheckDistance(DijkstraResult, 3, 6.0) then Result := False;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_02_diamond: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 0, 2, 4.0);
    GraphAddEdge(Graph, 1, 3, 6.0);
    GraphAddEdge(Graph, 2, 3, 1.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := True;
    if not CheckDistance(DijkstraResult, 0, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 1, 1.0) then Result := False;
    if not CheckDistance(DijkstraResult, 2, 4.0) then Result := False;
    if not CheckDistance(DijkstraResult, 3, 5.0) then Result := False;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_03_disconnected: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(5);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 2.0);
    GraphAddEdge(Graph, 1, 2, 3.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := True;
    if not CheckDistance(DijkstraResult, 0, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 1, 2.0) then Result := False;
    if not CheckDistance(DijkstraResult, 2, 5.0) then Result := False;
    if not CheckDistance(DijkstraResult, 3, Infinity) then Result := False;
    if not CheckDistance(DijkstraResult, 4, Infinity) then Result := False;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_04_single_vertex: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(1);
    if Graph = nil then
      Exit;

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := CheckDistance(DijkstraResult, 0, 0.0);
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_05_parallel_edges: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(2);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 5.0);
    GraphAddEdge(Graph, 0, 1, 2.0);
    GraphAddEdge(Graph, 0, 1, 8.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := CheckDistance(DijkstraResult, 1, 2.0);
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_06_zero_weight_edges: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 0.0);
    GraphAddEdge(Graph, 1, 2, 0.0);
    GraphAddEdge(Graph, 2, 3, 1.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := True;
    if not CheckDistance(DijkstraResult, 1, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 2, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 3, 1.0) then Result := False;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_07_null_graph: Boolean;
var
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  DijkstraResult := nil;
  try
    DijkstraResult := Dijkstra(nil, 0);
    Result := DijkstraResult = nil;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
end;

function test_algo_a_08_invalid_source: Boolean;
var
  Graph: PGraph;
  ResultHigh, ResultLow: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  ResultHigh := nil;
  ResultLow := nil;
  try
    Graph := CreateGraph(3);
    if Graph = nil then
      Exit;

    ResultHigh := Dijkstra(Graph, 5);
    ResultLow := Dijkstra(Graph, -1);

    Result := (ResultHigh = nil) and (ResultLow = nil);
  except
    Result := False;
  end;

  FreeResult(ResultHigh);
  FreeResult(ResultLow);
  FreeGraph(Graph);
end;

function test_algo_a_09_complex_graph: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateGraph(6);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 7.0);
    GraphAddEdge(Graph, 0, 2, 9.0);
    GraphAddEdge(Graph, 0, 5, 14.0);
    GraphAddEdge(Graph, 1, 2, 10.0);
    GraphAddEdge(Graph, 1, 3, 15.0);
    GraphAddEdge(Graph, 2, 3, 11.0);
    GraphAddEdge(Graph, 2, 5, 2.0);
    GraphAddEdge(Graph, 3, 4, 6.0);
    GraphAddEdge(Graph, 4, 5, 9.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := True;
    if not CheckDistance(DijkstraResult, 0, 0.0) then Result := False;
    if not CheckDistance(DijkstraResult, 1, 7.0) then Result := False;
    if not CheckDistance(DijkstraResult, 2, 9.0) then Result := False;
    if not CheckDistance(DijkstraResult, 3, 20.0) then Result := False;
    if not CheckDistance(DijkstraResult, 4, 26.0) then Result := False;
    if not CheckDistance(DijkstraResult, 5, 11.0) then Result := False;
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_a_10_stress: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  try
    Graph := CreateLinearChain(1000, 1.0);
    if Graph = nil then
      Exit;

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Result := CheckDistance(DijkstraResult, 999, 999.0);
  except
    Result := False;
  end;

  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_01_simple_path: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..3] of Integer = (0, 1, 2, 3);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 1, 2, 2.0);
    GraphAddEdge(Graph, 2, 3, 3.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 3, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_02_diamond_path: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..2] of Integer = (0, 2, 3);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 0, 2, 4.0);
    GraphAddEdge(Graph, 1, 3, 6.0);
    GraphAddEdge(Graph, 2, 3, 1.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 3, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_03_self_path: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..0] of Integer = (0);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(3);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 1, 2, 1.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 0, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_04_unreachable: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(5);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 2.0);
    GraphAddEdge(Graph, 1, 2, 3.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    PathLength := -1;
    Path := ReconstructPath(DijkstraResult, 4, PathLength);
    Result := Length(Path) = 0;
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_05_long_chain: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array of Integer;
  I: Integer;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  SetLength(Expected, 0);
  try
    Graph := CreateLinearChain(10, 1.0);
    if Graph = nil then
      Exit;

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    SetLength(Expected, 10);
    for I := 0 to 9 do
      Expected[I] := I;

    Path := ReconstructPath(DijkstraResult, 9, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  SetLength(Expected, 0);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_06_cycle: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..2] of Integer = (0, 1, 3);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(4);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 1, 2, 1.0);
    GraphAddEdge(Graph, 2, 0, 1.0);
    GraphAddEdge(Graph, 1, 3, 2.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 3, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_07_star: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..1] of Integer = (0, 3);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(5);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 2.0);
    GraphAddEdge(Graph, 0, 2, 3.0);
    GraphAddEdge(Graph, 0, 3, 1.0);
    GraphAddEdge(Graph, 0, 4, 5.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 3, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_08_null_result: Boolean;
var
  Path: TIntArray;
  PathLength: Integer;
begin
  Result := False;
  SetLength(Path, 0);
  try
    PathLength := -1;
    Path := ReconstructPath(nil, 0, PathLength);
    Result := Length(Path) = 0;
  except
    Result := False;
  end;

  FreePath(Path);
end;

function test_algo_b_09_bidirectional: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  Expected: array[0..2] of Integer = (0, 1, 2);
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  try
    Graph := CreateGraph(3);
    if Graph = nil then
      Exit;

    GraphAddEdge(Graph, 0, 1, 1.0);
    GraphAddEdge(Graph, 1, 0, 10.0);
    GraphAddEdge(Graph, 1, 2, 1.0);
    GraphAddEdge(Graph, 0, 2, 5.0);

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 2, PathLength);
    Result := PathEquals(Path, PathLength, Expected);
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
end;

function test_algo_b_10_stress_path: Boolean;
var
  Graph: PGraph;
  DijkstraResult: PDijkstraResult;
  Path: TIntArray;
  PathLength: Integer;
  NumVertices: Integer;
begin
  Result := False;
  Graph := nil;
  DijkstraResult := nil;
  SetLength(Path, 0);
  NumVertices := 1000;
  try
    Graph := CreateLinearChain(NumVertices, 1.0);
    if Graph = nil then
      Exit;

    DijkstraResult := Dijkstra(Graph, 0);
    if DijkstraResult = nil then
      Exit;

    Path := ReconstructPath(DijkstraResult, 999, PathLength);

    Result := True;
    if Length(Path) = 0 then
      Result := False
    else
    begin
      if PathLength <> NumVertices then Result := False;
      if Path[0] <> 0 then Result := False;
      if Path[NumVertices - 1] <> 999 then Result := False;
    end;
  except
    Result := False;
  end;

  FreePath(Path);
  FreeResult(DijkstraResult);
  FreeGraph(Graph);
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
  WriteLn('--- Algorithm A: Shortest Distances ---');
  run_test(@test_algo_a_01_linear_chain, 'Test A01 (Linear Chain)');
  run_test(@test_algo_a_02_diamond, 'Test A02 (Diamond)');
  run_test(@test_algo_a_03_disconnected, 'Test A03 (Disconnected)');
  run_test(@test_algo_a_04_single_vertex, 'Test A04 (Single Vertex)');
  run_test(@test_algo_a_05_parallel_edges, 'Test A05 (Parallel Edges)');
  run_test(@test_algo_a_06_zero_weight_edges, 'Test A06 (Zero-Weight Edges)');
  run_test(@test_algo_a_07_null_graph, 'Test A07 (Null Graph)');
  run_test(@test_algo_a_08_invalid_source, 'Test A08 (Invalid Source)');
  run_test(@test_algo_a_09_complex_graph, 'Test A09 (Complex Graph)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress 1000-Chain)');

  WriteLn;
  WriteLn('--- Algorithm B: Path Reconstruction ---');
  run_test(@test_algo_b_01_simple_path, 'Test B01 (Simple Path)');
  run_test(@test_algo_b_02_diamond_path, 'Test B02 (Diamond Path)');
  run_test(@test_algo_b_03_self_path, 'Test B03 (Self Path)');
  run_test(@test_algo_b_04_unreachable, 'Test B04 (Unreachable)');
  run_test(@test_algo_b_05_long_chain, 'Test B05 (Long Chain)');
  run_test(@test_algo_b_06_cycle, 'Test B06 (Cycle)');
  run_test(@test_algo_b_07_star, 'Test B07 (Star)');
  run_test(@test_algo_b_08_null_result, 'Test B08 (Null Result)');
  run_test(@test_algo_b_09_bidirectional, 'Test B09 (Bidirectional)');
  run_test(@test_algo_b_10_stress_path, 'Test B10 (Stress Path 1000-Chain)');

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
