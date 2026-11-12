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

type
  THeapItem = record
    Key: Double;
    Vertex: Integer;
  end;

  THeapArray = array of THeapItem;

procedure HeapPush(var H: THeapArray; var Size: Integer; AKey: Double; AVertex: Integer);
var
  I, P: Integer;
  Tmp: THeapItem;
begin
  I := Size;
  Inc(Size);
  H[I].Key := AKey;
  H[I].Vertex := AVertex;
  while I > 0 do
  begin
    P := (I - 1) div 2;
    if H[P].Key <= H[I].Key then
      Break;
    Tmp := H[P];
    H[P] := H[I];
    H[I] := Tmp;
    I := P;
  end;
end;

procedure HeapPop(var H: THeapArray; var Size: Integer; out Top: THeapItem);
var
  I, L, R, M: Integer;
  Tmp: THeapItem;
begin
  Top := H[0];
  Dec(Size);
  if Size > 0 then
  begin
    H[0] := H[Size];
    I := 0;
    while True do
    begin
      L := 2 * I + 1;
      if L >= Size then
        Break;
      R := L + 1;
      M := L;
      if (R < Size) and (H[R].Key < H[L].Key) then
        M := R;
      if H[I].Key <= H[M].Key then
        Break;
      Tmp := H[I];
      H[I] := H[M];
      H[M] := Tmp;
      I := M;
    end;
  end;
end;

function CreateGraph(NumVertices: Integer): PGraph;
var
  I: Integer;
begin
  Result := nil;
  if NumVertices < 0 then
    NumVertices := 0;
  New(Result);
  Result^.NumVertices := NumVertices;
  SetLength(Result^.Adjacency, NumVertices);
  for I := 0 to NumVertices - 1 do
    Result^.Adjacency[I] := nil;
end;

procedure GraphAddEdge(Graph: PGraph; FromV, ToV: Integer; Weight: Double);
var
  Len: Integer;
begin
  if Graph = nil then
    Exit;
  if (FromV < 0) or (FromV >= Graph^.NumVertices) then
    Exit;
  if (ToV < 0) or (ToV >= Graph^.NumVertices) then
    Exit;
  if Weight < 0 then
    Exit;
  Len := Length(Graph^.Adjacency[FromV]);
  SetLength(Graph^.Adjacency[FromV], Len + 1);
  Graph^.Adjacency[FromV][Len].eTo := ToV;
  Graph^.Adjacency[FromV][Len].Weight := Weight;
end;

procedure FreeGraph(var Graph: PGraph);
begin
  if Graph <> nil then
  begin
    Graph^.Adjacency := nil;
    Dispose(Graph);
    Graph := nil;
  end;
end;

function Dijkstra(Graph: PGraph; Source: Integer): PDijkstraResult;
var
  N, I, J, HeapSize, TotalEdges: Integer;
  U, V: Integer;
  Alt: Double;
  E: TEdge;
  Visited: array of Boolean;
  Heap: THeapArray;
  Top: THeapItem;
begin
  Result := nil;
  if (Graph = nil) or (Source < 0) or (Source >= Graph^.NumVertices) then
    Exit;

  N := Graph^.NumVertices;
  New(Result);
  Result^.NumVertices := N;
  Result^.Source := Source;
  SetLength(Result^.Distances, N);
  SetLength(Result^.Predecessors, N);
  SetLength(Visited, N);

  for I := 0 to N - 1 do
  begin
    Result^.Distances[I] := Infinity;
    Result^.Predecessors[I] := -1;
    Visited[I] := False;
  end;
  Result^.Distances[Source] := 0.0;

  TotalEdges := 0;
  for I := 0 to N - 1 do
    Inc(TotalEdges, Length(Graph^.Adjacency[I]));

  SetLength(Heap, TotalEdges + 1);
  HeapSize := 0;
  HeapPush(Heap, HeapSize, 0.0, Source);

  while HeapSize > 0 do
  begin
    HeapPop(Heap, HeapSize, Top);
    U := Top.Vertex;
    if Visited[U] then
      Continue;
    Visited[U] := True;

    for J := 0 to High(Graph^.Adjacency[U]) do
    begin
      E := Graph^.Adjacency[U][J];
      V := E.eTo;
      if Visited[V] then
        Continue;
      Alt := Result^.Distances[U] + E.Weight;
      if Alt < Result^.Distances[V] then
      begin
        Result^.Distances[V] := Alt;
        Result^.Predecessors[V] := U;
        HeapPush(Heap, HeapSize, Alt, V);
      end;
    end;
  end;
end;

function GetShortestDistance(AResult: PDijkstraResult; Target: Integer): Double;
begin
  if (AResult = nil) or (Target < 0) or (Target >= AResult^.NumVertices) then
  begin
    Result := Infinity;
    Exit;
  end;
  Result := AResult^.Distances[Target];
end;

function ReconstructPath(AResult: PDijkstraResult; Target: Integer; out PathLength: Integer): TIntArray;
var
  Count, Cur, I: Integer;
begin
  PathLength := 0;
  Result := nil;
  if (AResult = nil) or (Target < 0) or (Target >= AResult^.NumVertices) then
    Exit;
  if AResult^.Distances[Target] = Infinity then
    Exit;

  Count := 0;
  Cur := Target;
  while Cur <> -1 do
  begin
    Inc(Count);
    if Cur = AResult^.Source then
      Break;
    Cur := AResult^.Predecessors[Cur];
  end;

  SetLength(Result, Count);
  Cur := Target;
  for I := Count - 1 downto 0 do
  begin
    Result[I] := Cur;
    Cur := AResult^.Predecessors[Cur];
  end;
  PathLength := Count;
end;

procedure FreeResult(var AResult: PDijkstraResult);
begin
  if AResult <> nil then
  begin
    AResult^.Distances := nil;
    AResult^.Predecessors := nil;
    Dispose(AResult);
    AResult := nil;
  end;
end;

end.
