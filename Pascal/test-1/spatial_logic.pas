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

function calculate_clean_minkowski_sum(const Poly1, Poly2: PPolygon): PPolygon;
begin
  raise Exception.Create('calculate_clean_minkowski_sum not implemented');
  Result := nil;
end;

function check_dynamic_collision(const Obstacle, Robot: PPolygon; const Velocity: TPoint): Boolean;
begin
  raise Exception.Create('check_dynamic_collision not implemented');
  Result := False;
end;

function create_polygon(NumVertices: LongInt; const Name: AnsiString): PPolygon;
begin
  raise Exception.Create('create_polygon not implemented');
  Result := nil;
end;

procedure free_polygon(Poly: PPolygon);
begin
  if Poly <> nil then
    Dispose(Poly);
end;

function create_layer(const Name: AnsiString): PSpatialLayer;
begin
  raise Exception.Create('create_layer not implemented');
  Result := nil;
end;

procedure free_layer(Layer: PSpatialLayer);
begin
  if Layer <> nil then
    Dispose(Layer);
end;

end.
