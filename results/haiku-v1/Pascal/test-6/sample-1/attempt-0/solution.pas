unit sudoku;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  { A 9x9 board: 81 cells in row-major order (index = Row * 9 + Col), 0 = empty. }
  TIntArray = array of LongInt;

function SudokuIsValid(const Grid: TIntArray): Boolean;
function SudokuCandidates(const Grid: TIntArray; Row, Col: LongInt): TIntArray;
function SudokuSolve(const Grid: TIntArray): TIntArray;
function SudokuCountSolutions(const Grid: TIntArray; Limit: LongInt): LongInt;

implementation

function PopCountMask(M: LongInt): LongInt;
var
  i: LongInt;
begin
  Result := 0;
  for i := 1 to 9 do
    if (M and (1 shl i)) <> 0 then
      Inc(Result);
end;

{ Bitmask (bit d set for digit d) of digits already used in the row, column
  and box of cell (r, c). The cell itself is ignored only if it is empty. }
function UsedMask(const B: TIntArray; r, c: LongInt): LongInt;
var
  i, j, v, br, bc: LongInt;
begin
  Result := 0;
  for i := 0 to 8 do
  begin
    v := B[r * 9 + i];
    if v <> 0 then
      Result := Result or (1 shl v);
    v := B[i * 9 + c];
    if v <> 0 then
      Result := Result or (1 shl v);
  end;
  br := (r div 3) * 3;
  bc := (c div 3) * 3;
  for i := 0 to 2 do
    for j := 0 to 2 do
    begin
      v := B[(br + i) * 9 + (bc + j)];
      if v <> 0 then
        Result := Result or (1 shl v);
    end;
end;

function SudokuIsValid(const Grid: TIntArray): Boolean;
var
  rowM, colM, boxM: array[0..8] of LongInt;
  i, r, c, v, bit, b: LongInt;
begin
  Result := False;
  if Length(Grid) <> 81 then
    Exit;
  for i := 0 to 8 do
  begin
    rowM[i] := 0;
    colM[i] := 0;
    boxM[i] := 0;
  end;
  for i := 0 to 80 do
  begin
    v := Grid[i];
    if (v < 0) or (v > 9) then
      Exit;
    if v <> 0 then
    begin
      r := i div 9;
      c := i mod 9;
      b := (r div 3) * 3 + (c div 3);
      bit := 1 shl v;
      if (rowM[r] and bit) <> 0 then
        Exit;
      if (colM[c] and bit) <> 0 then
        Exit;
      if (boxM[b] and bit) <> 0 then
        Exit;
      rowM[r] := rowM[r] or bit;
      colM[c] := colM[c] or bit;
      boxM[b] := boxM[b] or bit;
    end;
  end;
  Result := True;
end;

function SudokuCandidates(const Grid: TIntArray; Row, Col: LongInt): TIntArray;
var
  used, d, n: LongInt;
begin
  SetLength(Result, 0);
  if Length(Grid) <> 81 then
    Exit;
  if Grid[Row * 9 + Col] <> 0 then
    Exit;
  used := UsedMask(Grid, Row, Col);
  SetLength(Result, 9);
  n := 0;
  for d := 1 to 9 do
    if (used and (1 shl d)) = 0 then
    begin
      Result[n] := d;
      Inc(n);
    end;
  SetLength(Result, n);
end;

{ Recursive MRV backtracking on a working board B (modified in place).
  Counts complete boards in Count. Returns True when Count reaches Limit;
  in that case B holds the last found complete board. }
function Search(var B: TIntArray; Limit: LongInt; var Count: LongInt): Boolean;
var
  i, d, best, bestCnt, cnt, free, bestFree, used: LongInt;
begin
  Result := False;
  best := -1;
  bestCnt := 10;
  bestFree := 0;
  for i := 0 to 80 do
    if B[i] = 0 then
    begin
      used := UsedMask(B, i div 9, i mod 9);
      free := (not used) and $3FE;
      cnt := PopCountMask(free);
      if cnt = 0 then
        Exit;
      if cnt < bestCnt then
      begin
        best := i;
        bestCnt := cnt;
        bestFree := free;
      end;
    end;

  if best < 0 then
  begin
    Inc(Count);
    Result := Count >= Limit;
    Exit;
  end;

  for d := 1 to 9 do
    if (bestFree and (1 shl d)) <> 0 then
    begin
      B[best] := d;
      if Search(B, Limit, Count) then
      begin
        Result := True;
        Exit;
      end;
    end;
  B[best] := 0;
end;

function SudokuSolve(const Grid: TIntArray): TIntArray;
var
  B: TIntArray;
  Count: LongInt;
begin
  SetLength(Result, 0);
  if not SudokuIsValid(Grid) then
    Exit;
  B := Copy(Grid, 0, 81);
  Count := 0;
  if Search(B, 1, Count) then
    Result := B;
end;

function SudokuCountSolutions(const Grid: TIntArray; Limit: LongInt): LongInt;
var
  B: TIntArray;
  Count: LongInt;
begin
  Result := 0;
  if Limit <= 0 then
    Exit;
  if not SudokuIsValid(Grid) then
    Exit;
  B := Copy(Grid, 0, 81);
  Count := 0;
  Search(B, Limit, Count);
  Result := Count;
end;

end.
