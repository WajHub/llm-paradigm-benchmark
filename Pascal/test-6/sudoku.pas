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

function SudokuIsValid(const Grid: TIntArray): Boolean;
begin
  raise Exception.Create('SudokuIsValid not implemented');
  Result := False;
end;

function SudokuCandidates(const Grid: TIntArray; Row, Col: LongInt): TIntArray;
begin
  raise Exception.Create('SudokuCandidates not implemented');
  Result := nil;
end;

function SudokuSolve(const Grid: TIntArray): TIntArray;
begin
  raise Exception.Create('SudokuSolve not implemented');
  Result := nil;
end;

function SudokuCountSolutions(const Grid: TIntArray; Limit: LongInt): LongInt;
begin
  raise Exception.Create('SudokuCountSolutions not implemented');
  Result := -1;
end;

end.
