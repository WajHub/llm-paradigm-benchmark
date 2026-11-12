You are a Pascal programming expert. Your task is to implement the required functions in accordance with the provided unit interface.

- Implement `CreateGraph`: Allocate a directed weighted graph with given vertices (0-indexed). Use dynamic arrays for adjacency lists.
- Implement `GraphAddEdge`: Add directed edge from FromV to ToV with given non-negative weight.
- Implement `Dijkstra`: Run Dijkstra's algorithm from source. Return PDijkstraResult with distances and predecessors. Unreachable → Infinity. Return nil if graph is nil or source out of bounds.
- Implement `GetShortestDistance`: Return distance to target. Return Infinity if out of bounds or result is nil.
- Implement `ReconstructPath`: Return TIntArray of vertex indices. Set PathLength. Return nil if unreachable.
- Implement `FreeGraph`, `FreeResult`: Safely dispose all allocated memory.
- Use a priority queue for O((V+E) log V) complexity.

General Requirements:
- Use idiomatic procedural Pascal.
- Manage dynamically allocated structures safely.
- Return ONLY raw Pascal code (no Markdown tags, no side text).
- Do not provide test runner code.

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