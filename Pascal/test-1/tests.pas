program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, spatial_logic;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

function contains_point(const Poly: PPolygon; X, Y: Double): Boolean;
var
  I: LongInt;
begin
  if (Poly = nil) or (Length(Poly^.Vertices) = 0) then
    Exit(False);

  for I := 0 to Poly^.NumVertices - 1 do
  begin
    if (Abs(Poly^.Vertices[I].X - X) < 0.001) and (Abs(Poly^.Vertices[I].Y - Y) < 0.001) then
      Exit(True);
  end;

  Result := False;
end;

function polygon_area(const Poly: PPolygon): Double;
var
  I, N: LongInt;
  A: Double;
begin
  if (Poly = nil) or (Poly^.NumVertices < 1) then
    Exit(0.0);

  A := 0.0;
  N := Poly^.NumVertices;
  for I := 0 to N - 1 do
    A := A + (Poly^.Vertices[I].X * Poly^.Vertices[(I + 1) mod N].Y - Poly^.Vertices[(I + 1) mod N].X * Poly^.Vertices[I].Y);

  Result := A * 0.5;
end;

function polygon_is_ccw(const Poly: PPolygon): Boolean;
begin
  Result := polygon_area(Poly) > 1e-9;
end;

function polygon_has_no_collinear(const Poly: PPolygon): Boolean;
var
  I, N: LongInt;
  Ax, Ay, Bx, By, Cx, Cy: Double;
  CrossVal: Double;
begin
  if (Poly = nil) or (Poly^.NumVertices < 3) then
    Exit(True);

  N := Poly^.NumVertices;
  for I := 0 to N - 1 do
  begin
    Ax := Poly^.Vertices[I].X;
    Ay := Poly^.Vertices[I].Y;
    Bx := Poly^.Vertices[(I + 1) mod N].X;
    By := Poly^.Vertices[(I + 1) mod N].Y;
    Cx := Poly^.Vertices[(I + 2) mod N].X;
    Cy := Poly^.Vertices[(I + 2) mod N].Y;
    CrossVal := (Bx - Ax) * (Cy - Ay) - (By - Ay) * (Cx - Ax);
    if Abs(CrossVal) <= 1e-6 then
      Exit(False);
  end;

  Result := True;
end;

function polygon_matches_expected(const Poly: PPolygon; const Expected: array of TPoint): Boolean;
var
  I, J, Nexp, Npoly: LongInt;
  Found: Boolean;
begin
  if Poly = nil then
    Exit(False);

  Nexp := Length(Expected);
  Npoly := Poly^.NumVertices;
  if Nexp <> Npoly then
    Exit(False);

  for I := 0 to Nexp - 1 do
  begin
    Found := False;
    for J := 0 to Npoly - 1 do
    begin
      if (Abs(Expected[I].X - Poly^.Vertices[J].X) < 0.001) and (Abs(Expected[I].Y - Poly^.Vertices[J].Y) < 0.001) then
      begin
        Found := True;
        Break;
      end;
    end;
    if not Found then
      Exit(False);
  end;

  Result := True;
end;

function make_polygon(const Points: array of TPoint; const Name: AnsiString): TPolygon;
var
  I: LongInt;
begin
  SetLength(Result.Vertices, Length(Points));
  for I := 0 to High(Points) do
    Result.Vertices[I] := Points[I];

  Result.NumVertices := Length(Points);
  Result.IsConvex := True;
  Result.ZoneName := Name;
end;

function test_algo_a_01_basic_squares: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..3] of TPoint = ((X:0;Y:0), (X:2;Y:0), (X:2;Y:2), (X:0;Y:2));
  Pts2: array[0..3] of TPoint = ((X:0;Y:0), (X:2;Y:0), (X:2;Y:2), (X:0;Y:2));
  Expected: array[0..3] of TPoint = ((X:0;Y:0), (X:4;Y:0), (X:4;Y:4), (X:0;Y:4));
begin
  Poly1 := make_polygon(Pts1, 'Z1');
  Poly2 := make_polygon(Pts2, 'Z2');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);
  Result := True;
  if not polygon_matches_expected(ResultPoly, Expected) then Result := False;
  if not polygon_is_ccw(ResultPoly) then Result := False;
  if not polygon_has_no_collinear(ResultPoly) then Result := False;
  if not ResultPoly^.IsConvex then Result := False;

  free_polygon(ResultPoly);
end;

function test_algo_a_02_point_and_polygon: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..0] of TPoint = ((X:5;Y:5));
  Pts2: array[0..2] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:0;Y:1));
  Expected: array[0..2] of TPoint = ((X:5;Y:5), (X:6;Y:5), (X:5;Y:6));
begin
  Poly1 := make_polygon(Pts1, 'Point');
  Poly2 := make_polygon(Pts2, 'Triangle');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := True;
  if not polygon_matches_expected(ResultPoly, Expected) then Result := False;
  if not polygon_is_ccw(ResultPoly) then Result := False;
  if not polygon_has_no_collinear(ResultPoly) then Result := False;
  free_polygon(ResultPoly);
end;

function test_algo_a_03_collinear_simplification: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..2] of TPoint = ((X:0;Y:0), (X:2;Y:0), (X:0;Y:2));
  Pts2: array[0..2] of TPoint = ((X:0;Y:0), (X:2;Y:0), (X:0;Y:2));
  Expected: array[0..2] of TPoint = ((X:0;Y:0), (X:4;Y:0), (X:0;Y:4));
begin
  Poly1 := make_polygon(Pts1, 'Tri1');
  Poly2 := make_polygon(Pts2, 'Tri2');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := True;
  if not polygon_matches_expected(ResultPoly, Expected) then Result := False;
  if not polygon_is_ccw(ResultPoly) then Result := False;
  if not polygon_has_no_collinear(ResultPoly) then Result := False;
  free_polygon(ResultPoly);
end;

function test_algo_a_04_negative_coordinates: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..3] of TPoint = ((X:-5;Y:-5), (X:-3;Y:-5), (X:-3;Y:-3), (X:-5;Y:-3));
  Pts2: array[0..3] of TPoint = ((X:1;Y:1), (X:2;Y:1), (X:2;Y:2), (X:1;Y:2));
begin
  Poly1 := make_polygon(Pts1, 'NegSq');
  Poly2 := make_polygon(Pts2, 'PosSq');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := True;
  if ResultPoly^.NumVertices <> 4 then Result := False;
  if not contains_point(ResultPoly, -4, -4) then Result := False;
  if not contains_point(ResultPoly, -1, -1) then Result := False;
  if not polygon_is_ccw(ResultPoly) then Result := False;
  if not polygon_has_no_collinear(ResultPoly) then Result := False;
  free_polygon(ResultPoly);
end;

function test_algo_a_05_single_points: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..0] of TPoint = ((X:-2.5;Y:3.5));
  Pts2: array[0..0] of TPoint = ((X:2.5;Y:-3.5));
begin
  Poly1 := make_polygon(Pts1, 'Pt1');
  Poly2 := make_polygon(Pts2, 'Pt2');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := True;
  if ResultPoly^.NumVertices <> 1 then Result := False;
  if not contains_point(ResultPoly, 0.0, 0.0) then Result := False;
  free_polygon(ResultPoly);
end;

function test_algo_a_06_empty_first_polygon: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts2: array[0..1] of TPoint = ((X:0;Y:0), (X:1;Y:1));
begin
  SetLength(Poly1.Vertices, 0);
  Poly1.NumVertices := 0;
  Poly1.IsConvex := True;
  Poly1.ZoneName := 'Empty';

  Poly2 := make_polygon(Pts2, 'Line');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := ResultPoly^.NumVertices = 0;
  free_polygon(ResultPoly);
end;

function test_algo_a_07_empty_second_polygon: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..1] of TPoint = ((X:0;Y:0), (X:1;Y:1));
begin
  Poly1 := make_polygon(Pts1, 'Line');

  SetLength(Poly2.Vertices, 0);
  Poly2.NumVertices := 0;
  Poly2.IsConvex := True;
  Poly2.ZoneName := 'Empty';

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := ResultPoly^.NumVertices = 0;
  free_polygon(ResultPoly);
end;

function test_algo_a_08_null_arguments: Boolean;
var
  Poly1: TPolygon;
  Result1, Result2, Result3: PPolygon;
  Pts1: array[0..0] of TPoint = ((X:0;Y:0));
begin
  Poly1 := make_polygon(Pts1, 'Pt');

  Result1 := calculate_clean_minkowski_sum(nil, @Poly1);
  Result2 := calculate_clean_minkowski_sum(@Poly1, nil);
  Result3 := calculate_clean_minkowski_sum(nil, nil);

  Result := True;
  if Result1 <> nil then begin free_polygon(Result1); Result := False; end;
  if Result2 <> nil then begin free_polygon(Result2); Result := False; end;
  if Result3 <> nil then begin free_polygon(Result3); Result := False; end;
end;

function test_algo_a_09_flat_polygon: Boolean;
var
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
  Pts1: array[0..1] of TPoint = ((X:0;Y:0), (X:2;Y:0));
  Pts2: array[0..1] of TPoint = ((X:0;Y:0), (X:3;Y:0));
begin
  Poly1 := make_polygon(Pts1, 'Line1');
  Poly2 := make_polygon(Pts2, 'Line2');

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);
  if ResultPoly = nil then
    Exit(False);

  Result := True;
  if ResultPoly^.NumVertices <> 2 then Result := False;
  if not contains_point(ResultPoly, 0, 0) then Result := False;
  if not contains_point(ResultPoly, 5, 0) then Result := False;
  free_polygon(ResultPoly);
end;

function test_algo_a_10_stress_test: Boolean;
var
  Size, I: LongInt;
  LargeArr: array of TPoint;
  Poly1, Poly2: TPolygon;
  ResultPoly: PPolygon;
begin
  Size := 500;
  SetLength(LargeArr, Size);

  for I := 0 to Size - 1 do
  begin
    LargeArr[I].X := Cos(2.0 * Pi * I / Size);
    LargeArr[I].Y := Sin(2.0 * Pi * I / Size);
  end;

  SetLength(Poly1.Vertices, Size);
  SetLength(Poly2.Vertices, Size);
  for I := 0 to Size - 1 do
  begin
    Poly1.Vertices[I] := LargeArr[I];
    Poly2.Vertices[I] := LargeArr[I];
  end;

  Poly1.NumVertices := Size;
  Poly1.IsConvex := True;
  Poly1.ZoneName := 'Circle1';

  Poly2.NumVertices := Size;
  Poly2.IsConvex := True;
  Poly2.ZoneName := 'Circle2';

  ResultPoly := calculate_clean_minkowski_sum(@Poly1, @Poly2);

  Result := True;
  if ResultPoly = nil then
  begin
    Result := False;
  end
  else
  begin
    if ResultPoly^.NumVertices <= 0 then
      Result := False;
    free_polygon(ResultPoly);
  end;
end;

function test_algo_b_01_tunneling_collision: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:5;Y:0), (X:6;Y:0), (X:6;Y:1), (X:5;Y:1));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 10.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = True;
end;

function test_algo_b_02_clear_miss: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:0;Y:5), (X:1;Y:5), (X:1;Y:6), (X:0;Y:6));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 10.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = False;
end;

function test_algo_b_03_static_overlap: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:2;Y:0), (X:2;Y:2), (X:0;Y:2));
  ObsPts: array[0..3] of TPoint = ((X:1;Y:1), (X:3;Y:1), (X:3;Y:3), (X:1;Y:3));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 0.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = True;
end;

function test_algo_b_04_static_miss: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:10;Y:10), (X:11;Y:10), (X:11;Y:11), (X:10;Y:11));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 0.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = False;
end;

function test_algo_b_05_moving_away: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:-5;Y:0), (X:-4;Y:0), (X:-4;Y:1), (X:-5;Y:1));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 10.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = False;
end;

function test_algo_b_06_diagonal_tunneling: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:5;Y:5), (X:7;Y:5), (X:7;Y:7), (X:5;Y:7));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 10.0;
  Velocity.Y := 10.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = True;
end;

function test_algo_b_07_edge_grazing: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
  ObsPts: array[0..3] of TPoint = ((X:0;Y:1), (X:1;Y:1), (X:1;Y:2), (X:0;Y:2));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 10.0;
  Velocity.Y := 0.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = True;
end;

function test_algo_b_08_negative_velocity: Boolean;
var
  Robot, Obstacle: TPolygon;
  Velocity: TPoint;
  RobPts: array[0..3] of TPoint = ((X:10;Y:10), (X:11;Y:10), (X:11;Y:11), (X:10;Y:11));
  ObsPts: array[0..3] of TPoint = ((X:4;Y:4), (X:6;Y:4), (X:6;Y:6), (X:4;Y:6));
begin
  Robot := make_polygon(RobPts, 'Robot');
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := -10.0;
  Velocity.Y := -10.0;

  Result := check_dynamic_collision(@Obstacle, @Robot, Velocity) = True;
end;

function test_algo_b_09_empty_polygons: Boolean;
var
  EmptyPoly, Obstacle: TPolygon;
  Velocity: TPoint;
  Col1, Col2: Boolean;
  ObsPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
begin
  SetLength(EmptyPoly.Vertices, 0);
  EmptyPoly.NumVertices := 0;
  EmptyPoly.IsConvex := True;
  EmptyPoly.ZoneName := 'Empty';

  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 5.0;
  Velocity.Y := 5.0;

  Col1 := check_dynamic_collision(@Obstacle, @EmptyPoly, Velocity);
  Col2 := check_dynamic_collision(@EmptyPoly, @Obstacle, Velocity);

  Result := (Col1 = False) and (Col2 = False);
end;

function test_algo_b_10_null_arguments: Boolean;
var
  Obstacle: TPolygon;
  Velocity: TPoint;
  Col1, Col2, Col3: Boolean;
  ObsPts: array[0..3] of TPoint = ((X:0;Y:0), (X:1;Y:0), (X:1;Y:1), (X:0;Y:1));
begin
  Obstacle := make_polygon(ObsPts, 'Obstacle');
  Velocity.X := 5.0;
  Velocity.Y := 5.0;

  Col1 := check_dynamic_collision(nil, @Obstacle, Velocity);
  Col2 := check_dynamic_collision(@Obstacle, nil, Velocity);
  Col3 := check_dynamic_collision(nil, nil, Velocity);

  Result := (Col1 = False) and (Col2 = False) and (Col3 = False);
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
  WriteLn('--- Algorithm A: Clean Minkowski Sum (Convex Hull) ---');
  run_test(@test_algo_a_01_basic_squares, 'Test A01 (Basic Squares Hull)');
  run_test(@test_algo_a_02_point_and_polygon, 'Test A02 (Point and Polygon)');
  run_test(@test_algo_a_03_collinear_simplification, 'Test A03 (Collinear Simplification)');
  run_test(@test_algo_a_04_negative_coordinates, 'Test A04 (Negative Coordinates)');
  run_test(@test_algo_a_05_single_points, 'Test A05 (Single Points)');
  run_test(@test_algo_a_06_empty_first_polygon, 'Test A06 (Empty First Polygon)');
  run_test(@test_algo_a_07_empty_second_polygon, 'Test A07 (Empty Second Polygon)');
  run_test(@test_algo_a_08_null_arguments, 'Test A08 (Null Arguments)');
  run_test(@test_algo_a_09_flat_polygon, 'Test A09 (Flat Polygons / Lines)');
  run_test(@test_algo_a_10_stress_test, 'Test A10 (Stress Test 500x500)');

  WriteLn;
  WriteLn('--- Algorithm B: Dynamic Collision Detection ---');
  run_test(@test_algo_b_01_tunneling_collision, 'Test B01 (Tunneling Collision)');
  run_test(@test_algo_b_02_clear_miss, 'Test B02 (Clear Miss)');
  run_test(@test_algo_b_03_static_overlap, 'Test B03 (Static Overlap)');
  run_test(@test_algo_b_04_static_miss, 'Test B04 (Static Miss)');
  run_test(@test_algo_b_05_moving_away, 'Test B05 (Moving Away)');
  run_test(@test_algo_b_06_diagonal_tunneling, 'Test B06 (Diagonal Tunneling)');
  run_test(@test_algo_b_07_edge_grazing, 'Test B07 (Edge Grazing)');
  run_test(@test_algo_b_08_negative_velocity, 'Test B08 (Negative Velocity)');
  run_test(@test_algo_b_09_empty_polygons, 'Test B09 (Empty Polygons)');
  run_test(@test_algo_b_10_null_arguments, 'Test B10 (NULL Arguments)');

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
