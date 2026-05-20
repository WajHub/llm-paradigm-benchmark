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
EPS = 1e-9;
function Cross(const A, B: TPoint): Double;
begin
Result := A.X * B.Y - A.Y * B.X;
end;
function SubPoint(const A, B: TPoint): TPoint;
begin
Result.X := A.X - B.X;
Result.Y := A.Y - B.Y;
end;
function AddPoint(const A, B: TPoint): TPoint;
begin
Result.X := A.X + B.X;
Result.Y := A.Y + B.Y;
end;
function LexLess(const A, B: TPoint): Boolean;
begin
if A.X < B.X then
Exit(True);
if A.X > B.X then
Exit(False);
Result := A.Y < B.Y;
end;
procedure SwapPoint(var A, B: TPoint);
var
Tmp: TPoint;
begin
Tmp := A;
A := B;
B := Tmp;
end;
procedure QuickSortPoints(var Arr: TPointArray; L, R: LongInt);
var
I, J: LongInt;
Pivot: TPoint;
begin
if L >= R then Exit;
I := L;
J := R;
Pivot := Arr[(L + R) div 2];
repeat
while LexLess(Arr[I], Pivot) do Inc(I);
while LexLess(Pivot, Arr[J]) do Dec(J);

if I <= J then
begin
  SwapPoint(Arr[I], Arr[J]);
  Inc(I);
  Dec(J);
end;
until I > J;
if L < J then QuickSortPoints(Arr, L, J);
if I < R then QuickSortPoints(Arr, I, R);
end;
function SamePoint(const A, B: TPoint): Boolean;
begin
Result := (Abs(A.X - B.X) <= EPS) and (Abs(A.Y - B.Y) <= EPS);
end;
function ClampName(const Name: AnsiString; MaxLen: LongInt): AnsiString;
begin
if Length(Name) > MaxLen then
Result := Copy(Name, 1, MaxLen)
else
Result := Name;
end;
function create_polygon(NumVertices: LongInt; const Name: AnsiString): PPolygon;
begin
if NumVertices < 0 then NumVertices := 0;
New(Result);
SetLength(Result^.Vertices, NumVertices);
Result^.NumVertices := NumVertices;
Result^.IsConvex := False;
Result^.ZoneName := ClampName(Name, 31);
end;
procedure free_polygon(Poly: PPolygon);
begin
if Poly = nil then Exit;
SetLength(Poly^.Vertices, 0);
Dispose(Poly);
end;
function create_layer(const Name: AnsiString): PSpatialLayer;
begin
New(Result);
SetLength(Result^.Polygons, 0);
Result^.PolygonCount := 0;
Result^.LayerName := ClampName(Name, 63);
end;
procedure free_layer(Layer: PSpatialLayer);
var
I: LongInt;
begin
if Layer = nil then Exit;
for I := 0 to Layer^.PolygonCount - 1 do
free_polygon(Layer^.Polygons[I]);
SetLength(Layer^.Polygons, 0);
Dispose(Layer);
end;
function calculate_clean_minkowski_sum(const Poly1, Poly2: PPolygon): PPolygon;
var
N, M, Total, I, J, K, H, T, CleanH: LongInt;
Pts, Hull: TPointArray;
CP: Double;
begin
if (Poly1 = nil) or (Poly2 = nil) then Exit(nil);
if (Poly1^.NumVertices = 0) or (Poly2^.NumVertices = 0) then
begin
Result := create_polygon(0, 'mink_sum');
Result^.IsConvex := True;
Exit;
end;
N := Poly1^.NumVertices;
M := Poly2^.NumVertices;
Total := N * M;
SetLength(Pts, Total);
K := 0;
for I := 0 to N - 1 do
for J := 0 to M - 1 do
begin
Pts[K] := AddPoint(Poly1^.Vertices[I], Poly2^.Vertices[J]);
Inc(K);
end;
if Total > 1 then
QuickSortPoints(Pts, 0, Total - 1);
SetLength(Hull, Total * 2 + 1);
H := 0;
for I := 0 to Total - 1 do
begin
while H >= 2 do
begin
CP := Cross(SubPoint(Hull[H - 1], Hull[H - 2]), SubPoint(Pts[I], Hull[H - 2]));
if CP <= EPS then Dec(H) else Break;
end;
Hull[H] := Pts[I];
Inc(H);
end;
T := H + 1;
for I := Total - 2 downto 0 do
begin
while H >= T do
begin
CP := Cross(SubPoint(Hull[H - 1], Hull[H - 2]), SubPoint(Pts[I], Hull[H - 2]));
if CP <= EPS then Dec(H) else Break;
end;
Hull[H] := Pts[I];
Inc(H);
end;
if (H > 1) and SamePoint(Hull[H - 1], Hull[0]) then Dec(H);
CleanH := 0;
if H > 0 then
begin
Hull[CleanH] := Hull[0];
CleanH := 1;
for I := 1 to H - 1 do
begin
if not SamePoint(Hull[I], Hull[CleanH - 1]) then
begin
Hull[CleanH] := Hull[I];
Inc(CleanH);
end;
end;
end;
H := CleanH;
Result := create_polygon(H, 'mink_sum');
Result^.IsConvex := True;
for I := 0 to H - 1 do
Result^.Vertices[I] := Hull[I];
end;
function point_in_convex(const Poly: PPolygon; const P: TPoint): Boolean;
var
I, N: LongInt;
CP: Double;
begin
if (Poly = nil) or (Poly^.NumVertices < 3) then Exit(False);
N := Poly^.NumVertices;
for I := 0 to N - 1 do
begin
CP := Cross(SubPoint(Poly^.Vertices[(I + 1) mod N], Poly^.Vertices[I]), SubPoint(P, Poly^.Vertices[I]));
if CP < -EPS then Exit(False);
end;
Result := True;
end;
function segments_intersect(const P1, P2, Q1, Q2: TPoint): Boolean;
var
D1, D2, D3, D4: Double;
begin
D1 := Cross(SubPoint(P2, P1), SubPoint(Q1, P1));
D2 := Cross(SubPoint(P2, P1), SubPoint(Q2, P1));
D3 := Cross(SubPoint(Q2, Q1), SubPoint(P1, Q1));
D4 := Cross(SubPoint(Q2, Q1), SubPoint(P2, Q1));
Result := ((D1 > EPS) and (D2 < -EPS) or (D1 < -EPS) and (D2 > EPS)) and
((D3 > EPS) and (D4 < -EPS) or (D3 < -EPS) and (D4 > EPS));
end;
function check_dynamic_collision(const Obstacle, Robot: PPolygon; const Velocity: TPoint): Boolean;
var
I, N, NV: LongInt;
NegRobot: TPolygon;
CSpace: PPolygon;
Origin: TPoint;
begin
if (Obstacle = nil) or (Robot = nil) or (Obstacle^.NumVertices = 0) or (Robot^.NumVertices = 0) then
Exit(False);
N := Robot^.NumVertices;
SetLength(NegRobot.Vertices, N);
NegRobot.NumVertices := N;
NegRobot.IsConvex := True;
NegRobot.ZoneName := '';
for I := 0 to N - 1 do
begin
NegRobot.Vertices[I].X := -Robot^.Vertices[I].X;
NegRobot.Vertices[I].Y := -Robot^.Vertices[I].Y;
end;
CSpace := calculate_clean_minkowski_sum(Obstacle, @NegRobot);
if (CSpace = nil) or (CSpace^.NumVertices = 0) then
begin
free_polygon(CSpace);
Exit(False);
end;
Origin.X := 0.0;
Origin.Y := 0.0;
Result := False;
if point_in_convex(CSpace, Origin) or point_in_convex(CSpace, Velocity) then
begin
Result := True;
end
else
begin
NV := CSpace^.NumVertices;
for I := 0 to NV - 1 do
begin
if segments_intersect(Origin, Velocity, CSpace^.Vertices[I], CSpace^.Vertices[(I + 1) mod NV]) then
begin
Result := True;
Break;
end;
end;
end;
free_polygon(CSpace);
end;
end.