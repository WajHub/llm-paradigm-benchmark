unit shortest_path;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TEdge = record
    eTo: Integer;
    Weight: Double;
  end;

  TEdgeArray = array of TEdge;

  PGraph = ^TGraph;
  TGraph = record
    Adjacency: array of TEdgeArray;
    NumVertices: Integer;
  end;

  PDijkstraResult = ^TDijkstraResult;
  TDijkstraResult = record
    Distances: array of Double;
    Predecessors: array of Integer;
    NumVertices: Integer;
    Source: Integer;
  end;

  TIntArray = array of Integer;

function CreateGraph(NumVertices: Integer): PGraph;
procedure GraphAddEdge(Graph: PGraph; FromV, ToV: Integer; Weight: Double);
procedure FreeGraph(var Graph: PGraph);

function Dijkstra(Graph: PGraph; Source: Integer): PDijkstraResult;
function GetShortestDistance(AResult: PDijkstraResult; Target: Integer): Double;
function ReconstructPath(AResult: PDijkstraResult; Target: Integer; out PathLength: Integer): TIntArray;
procedure FreeResult(var AResult: PDijkstraResult);

implementation

function CreateGraph(NumVertices: Integer): PGraph;
begin
  raise Exception.Create('CreateGraph not implemented');
  Result := nil;
end;

procedure GraphAddEdge(Graph: PGraph; FromV, ToV: Integer; Weight: Double);
begin
  raise Exception.Create('GraphAddEdge not implemented');
end;

procedure FreeGraph(var Graph: PGraph);
begin
  if Graph <> nil then begin
    Dispose(Graph);
    Graph := nil;
  end;
end;

function Dijkstra(Graph: PGraph; Source: Integer): PDijkstraResult;
begin
  raise Exception.Create('Dijkstra not implemented');
  Result := nil;
end;

function GetShortestDistance(AResult: PDijkstraResult; Target: Integer): Double;
begin
  raise Exception.Create('GetShortestDistance not implemented');
  Result := -1.0;
end;

function ReconstructPath(AResult: PDijkstraResult; Target: Integer; out PathLength: Integer): TIntArray;
begin
  raise Exception.Create('ReconstructPath not implemented');
  PathLength := 0;
  Result := nil;
end;

procedure FreeResult(var AResult: PDijkstraResult);
begin
  if AResult <> nil then begin
    Dispose(AResult);
    AResult := nil;
  end;
end;

end.
