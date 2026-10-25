unit spatial_logic;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TPoint = record
    X: Double;
    Y: Double;
  end;

  TPointArray = array of TPoint;

  PPolygon = ^TPolygon;
  TPolygon = record
    Vertices: TPointArray;
    NumVertices: LongInt;
    IsConvex: Boolean;
    ZoneName: AnsiString;
  end;

  TPolygonPtrArray = array of PPolygon;

  PSpatialLayer = ^TSpatialLayer;
  TSpatialLayer = record
    Polygons: TPolygonPtrArray;
    PolygonCount: LongInt;
    LayerName: AnsiString;
  end;

function calculate_clean_minkowski_sum(const Poly1, Poly2: PPolygon): PPolygon;
function check_dynamic_collision(const Obstacle, Robot: PPolygon; const Velocity: TPoint): Boolean;

function create_polygon(NumVertices: LongInt; const Name: AnsiString): PPolygon;
procedure free_polygon(Poly: PPolygon);
function create_layer(const Name: AnsiString): PSpatialLayer;
procedure free_layer(Layer: PSpatialLayer);

implementation

const
  GEOM_EPS = 1e-9;

function PointLess(const P, Q: TPoint): Boolean;
begin
  Result := (P.X < Q.X) or ((P.X = Q.X) and (P.Y < Q.Y));
end;

function Cross(const O, A, B: TPoint): Double;
begin
  Result := (A.X - O.X) * (B.Y - O.Y) - (A.Y - O.Y) * (B.X - O.X);
end;

procedure QuickSortPoints(var A: TPointArray; L, R: LongInt);
var
  I, J: LongInt;
  Pivot, Tmp: TPoint;
begin
  I := L;
  J := R;
  Pivot := A[(L + R) div 2];
  while I <= J do
  begin
    while PointLess(A[I], Pivot) do
      Inc(I);
    while PointLess(Pivot, A[J]) do
      Dec(J);
    if I <= J then
    begin
      Tmp := A[I];
      A[I] := A[J];
      A[J] := Tmp;
      Inc(I);
      Dec(J);
    end;
  end;
  if L < J then
    QuickSortPoints(A, L, J);
  if I < R then
    QuickSortPoints(A, I, R);
end;

// Returns the strict convex hull (CCW, no collinear points, no duplicates)
function ConvexHull(const Pts: TPointArray): TPointArray;
var
  P, H: TPointArray;
  N, M, K, T, I: LongInt;
begin
  SetLength(Result, 0);
  N := Length(Pts);
  if N = 0 then
    Exit;

  P := Copy(Pts);
  QuickSortPoints(P, 0, N - 1);

  // Remove duplicates
  M := 1;
  for I := 1 to N - 1 do
    if (P[I].X <> P[M - 1].X) or (P[I].Y <> P[M - 1].Y) then
    begin
      P[M] := P[I];
      Inc(M);
    end;

  if M = 1 then
  begin
    SetLength(Result, 1);
    Result[0] := P[0];
    Exit;
  end;

  SetLength(H, 2 * M);
  K := 0;
  for I := 0 to M - 1 do
  begin
    while (K >= 2) and (Cross(H[K - 2], H[K - 1], P[I]) <= 0) do
      Dec(K);
    H[K] := P[I];
    Inc(K);
  end;

  T := K + 1;
  for I := M - 2 downto 0 do
  begin
    while (K >= T) and (Cross(H[K - 2], H[K - 1], P[I]) <= 0) do
      Dec(K);
    H[K] := P[I];
    Inc(K);
  end;

  // Last point repeats the first one
  Dec(K);
  SetLength(Result, K);
  for I := 0 to K - 1 do
    Result[I] := H[I];
end;

// Minkowski sum of two convex point sets, reduced to its strict convex hull
function MinkowskiPoints(const A, B: TPointArray): TPointArray;
var
  S: TPointArray;
  I, J, K: LongInt;
begin
  SetLength(Result, 0);
  if (Length(A) = 0) or (Length(B) = 0) then
    Exit;

  SetLength(S, Length(A) * Length(B));
  K := 0;
  for I := 0 to High(A) do
    for J := 0 to High(B) do
    begin
      S[K].X := A[I].X + B[J].X;
      S[K].Y := A[I].Y + B[J].Y;
      Inc(K);
    end;

  Result := ConvexHull(S);
end;

function OnSegment(const A, B, P: TPoint): Boolean;
begin
  Result := (Abs(Cross(A, B, P)) <= GEOM_EPS) and
            (P.X >= Min(A.X, B.X) - GEOM_EPS) and (P.X <= Max(A.X, B.X) + GEOM_EPS) and
            (P.Y >= Min(A.Y, B.Y) - GEOM_EPS) and (P.Y <= Max(A.Y, B.Y) + GEOM_EPS);
end;

// Closed segment intersection test (touching counts as intersecting)
function SegmentsIntersect(const P1, P2, Q1, Q2: TPoint): Boolean;
var
  D1, D2, D3, D4: Double;
begin
  D1 := Cross(Q1, Q2, P1);
  D2 := Cross(Q1, Q2, P2);
  D3 := Cross(P1, P2, Q1);
  D4 := Cross(P1, P2, Q2);

  if (((D1 > GEOM_EPS) and (D2 < -GEOM_EPS)) or ((D1 < -GEOM_EPS) and (D2 > GEOM_EPS))) and
     (((D3 > GEOM_EPS) and (D4 < -GEOM_EPS)) or ((D3 < -GEOM_EPS) and (D4 > GEOM_EPS))) then
  begin
    Result := True;
    Exit;
  end;

  Result := OnSegment(Q1, Q2, P1) or OnSegment(Q1, Q2, P2) or
            OnSegment(P1, P2, Q1) or OnSegment(P1, P2, Q2);
end;

// Closed point-in-convex-polygon test for a CCW polygon with at least 3 vertices
function PointInConvex(const H: TPointArray; const P: TPoint): Boolean;
var
  I, N: LongInt;
begin
  N := Length(H);
  Result := False;
  if N < 3 then
    Exit;
  for I := 0 to N - 1 do
    if Cross(H[I], H[(I + 1) mod N], P) < -GEOM_EPS then
      Exit;
  Result := True;
end;

function calculate_clean_minkowski_sum(const Poly1, Poly2: PPolygon): PPolygon;
var
  H: TPointArray;
begin
  Result := nil;
  if (Poly1 = nil) or (Poly2 = nil) then
    Exit;

  H := MinkowskiPoints(Poly1^.Vertices, Poly2^.Vertices);

  Result := create_polygon(Length(H), Poly1^.ZoneName + '+' + Poly2^.ZoneName);
  Result^.Vertices := H;
  Result^.NumVertices := Length(H);
  Result^.IsConvex := True;
end;

function check_dynamic_collision(const Obstacle, Robot: PPolygon; const Velocity: TPoint): Boolean;
var
  NegRobot, C: TPointArray;
  Origin, Target: TPoint;
  I, J, N: LongInt;
begin
  Result := False;
  if (Obstacle = nil) or (Robot = nil) then
    Exit;
  if (Length(Obstacle^.Vertices) = 0) or (Length(Robot^.Vertices) = 0) then
    Exit;

  // Configuration space obstacle: Obstacle (+) (-Robot)
  SetLength(NegRobot, Length(Robot^.Vertices));
  for I := 0 to High(Robot^.Vertices) do
  begin
    NegRobot[I].X := -Robot^.Vertices[I].X;
    NegRobot[I].Y := -Robot^.Vertices[I].Y;
  end;

  C := MinkowskiPoints(Obstacle^.Vertices, NegRobot);
  N := Length(C);
  if N = 0 then
    Exit;

  // Robot reference point at origin sweeps along segment [0, Velocity].
  // Collision occurs iff this segment touches the configuration space obstacle.
  Origin.X := 0.0;
  Origin.Y := 0.0;
  Target := Velocity;

  for I := 0 to N - 1 do
  begin
    J := (I + 1) mod N;
    if SegmentsIntersect(Origin, Target, C[I], C[J]) then
    begin
      Result := True;
      Exit;
    end;
  end;

  if (N >= 3) and (PointInConvex(C, Origin) or PointInConvex(C, Target)) then
    Result := True;
end;

function create_polygon(NumVertices: LongInt; const Name: AnsiString): PPolygon;
var
  Count: LongInt;
begin
  New(Result);
  Result^.Vertices := nil;

  Count := NumVertices;
  if Count < 0 then
    Count := 0;

  SetLength(Result^.Vertices, Count);
  Result^.NumVertices := Count;
  Result^.IsConvex := False;
  Result^.ZoneName := Name;
end;

procedure free_polygon(Poly: PPolygon);
begin
  if Poly <> nil then
  begin
    Poly^.Vertices := nil;
    Poly^.ZoneName := '';
    Dispose(Poly);
  end;
end;

function create_layer(const Name: AnsiString): PSpatialLayer;
begin
  New(Result);
  Result^.Polygons := nil;
  Result^.PolygonCount := 0;
  Result^.LayerName := Name;
end;

// The layer owns the polygons it references and frees them.
procedure free_layer(Layer: PSpatialLayer);
var
  I: LongInt;
begin
  if Layer <> nil then
  begin
    for I := 0 to High(Layer^.Polygons) do
    begin
      free_polygon(Layer^.Polygons[I]);
      Layer^.Polygons[I] := nil;
    end;
    Layer^.Polygons := nil;
    Layer^.PolygonCount := 0;
    Layer^.LayerName := '';
    Dispose(Layer);
  end;
end;

end.
