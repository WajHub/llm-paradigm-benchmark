program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, sudoku;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

const
  CLASSIC_STR =
    '530070000 600195000 098000060 800060003 400803001 700020006 060000280 000419005 000080079';
  SOLVED_STR =
    '534678912 672195348 198342567 859761423 426853791 713924856 961537284 287419635 345286179';
  INKALA_STR =
    '800000000 043600000 070090200 050007000 000845700 000100030 001000068 008500010 090000402';
  INKALA_SOL_STR =
    '812753649 943682175 675491283 154237896 369845721 287169534 521974368 438526917 796318452';
  ANTI_BF_STR =
    '000000000 000003085 001020000 000507000 034000100 090000000 500000073 002010560 800040009';
  ANTI_BF_SOL_STR =
    '987654321 246173985 351928746 128537694 634892157 795461832 519286473 472319568 863745219';

{ Helpers }

function MakeInts(const Values: array of LongInt): TIntArray;
var
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, Length(Values));
  for I := 0 to High(Values) do
    Result[I] := Values[I];
end;

{ Row-major digit string -> grid; '.' and '0' are empty cells, spaces are ignored. }
function ParseGrid(const S: AnsiString): TIntArray;
var
  I, N: LongInt;
begin
  Result := nil;
  SetLength(Result, 81);
  N := 0;
  for I := 1 to Length(S) do
    if S[I] = '.' then
    begin
      Result[N] := 0;
      Inc(N);
    end
    else if S[I] in ['0'..'9'] then
    begin
      Result[N] := Ord(S[I]) - Ord('0');
      Inc(N);
    end;
end;

function Zeros(N: LongInt): TIntArray;
var
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, N);
  for I := 0 to N - 1 do
    Result[I] := 0;
end;

function EmptyGrid: TIntArray;
begin
  Result := Zeros(81);
end;

{ Fresh copy of G with cell (Row, Col) set to V. }
function WithCell(const G: TIntArray; Row, Col, V: LongInt): TIntArray;
begin
  Result := Copy(G, 0, Length(G));
  Result[Row * 9 + Col] := V;
end;

function GridEquals(const A, B: TIntArray): Boolean;
var
  I: LongInt;
begin
  if Length(A) <> Length(B) then
    Exit(False);
  for I := 0 to High(A) do
    if A[I] <> B[I] then
      Exit(False);
  Result := True;
end;

function IntsEqual(const Actual: TIntArray; const Expected: array of LongInt): Boolean;
var
  I: LongInt;
begin
  if Length(Actual) <> Length(Expected) then
    Exit(False);
  for I := 0 to High(Expected) do
    if Actual[I] <> Expected[I] then
      Exit(False);
  Result := True;
end;

function Classic: TIntArray;
begin
  Result := ParseGrid(CLASSIC_STR);
end;

function Solved: TIntArray;
begin
  Result := ParseGrid(SOLVED_STR);
end;

{ CLASSIC with (1,1)=8: clashes only with (2,2)=8 in box 0. }
function BoxConflict: TIntArray;
begin
  Result := WithCell(Classic, 1, 1, 8);
end;

{ EMPTY with row 0 = 1 2 3 4 5 6 7 8 0 and (4,8)=9: valid, (0,8) has no candidate. }
function DeadCell: TIntArray;
var
  C: LongInt;
begin
  Result := EmptyGrid;
  for C := 0 to 7 do
    Result[C] := C + 1;
  Result[4 * 9 + 8] := 9;
end;

{ ========================================================================== }
{ Algorithm A: Validation and Candidates                                      }
{ ========================================================================== }

function test_algo_a_01_empty_grid_valid: Boolean;
begin
  try
    Result := SudokuIsValid(EmptyGrid);
  except
    Result := False;
  end;
end;

function test_algo_a_02_solved_grid_valid: Boolean;
begin
  try
    Result := SudokuIsValid(Solved) and SudokuIsValid(Classic);
  except
    Result := False;
  end;
end;

function test_algo_a_03_row_conflict: Boolean;
begin
  try
    Result := (not SudokuIsValid(WithCell(Classic, 0, 8, 5)))
      and SudokuIsValid(Classic);
  except
    Result := False;
  end;
end;

function test_algo_a_04_column_conflict: Boolean;
begin
  try
    Result := (not SudokuIsValid(WithCell(Classic, 8, 0, 5)))
      and SudokuIsValid(Classic);
  except
    Result := False;
  end;
end;

function test_algo_a_05_box_only_conflict: Boolean;
var
  G2: TIntArray;
begin
  try
    G2 := EmptyGrid;
    G2[0] := 1;
    G2[1 * 9 + 1] := 1;
    Result := (not SudokuIsValid(BoxConflict))
      and (not SudokuIsValid(G2))
      and SudokuIsValid(Classic);
  except
    Result := False;
  end;
end;

function test_algo_a_06_wrong_length: Boolean;
var
  Longer: TIntArray;
begin
  try
    Longer := Solved;
    SetLength(Longer, 82);
    Longer[81] := 0;
    Result := (not SudokuIsValid(Zeros(80)))
      and (not SudokuIsValid(Zeros(82)))
      and (not SudokuIsValid(Longer))
      and SudokuIsValid(Solved);
  except
    Result := False;
  end;
end;

function test_algo_a_07_value_out_of_range: Boolean;
begin
  try
    Result := (not SudokuIsValid(WithCell(Classic, 0, 2, 10)))
      and (not SudokuIsValid(WithCell(Classic, 0, 2, -1)))
      and SudokuIsValid(Classic);
  except
    Result := False;
  end;
end;

function test_algo_a_08_candidates_basic: Boolean;
var
  G: TIntArray;
begin
  try
    G := Classic;
    Result := IntsEqual(SudokuCandidates(G, 0, 2), [1, 2, 4])
      and IntsEqual(SudokuCandidates(G, 4, 4), [5])
      and IntsEqual(SudokuCandidates(G, 8, 0), [1, 2, 3]);
  except
    Result := False;
  end;
end;

function test_algo_a_09_candidates_edge_cells: Boolean;
begin
  try
    Result := (Length(SudokuCandidates(Classic, 0, 0)) = 0)
      and (Length(SudokuCandidates(Classic, 8, 8)) = 0)
      and IntsEqual(SudokuCandidates(EmptyGrid, 8, 8), [1, 2, 3, 4, 5, 6, 7, 8, 9]);
  except
    Result := False;
  end;
end;

function test_algo_a_10_candidates_sweep: Boolean;
var
  S, G, C: TIntArray;
  R, Col, Sum: LongInt;
begin
  Result := False;
  try
    S := Solved;
    for R := 0 to 8 do
      for Col := 0 to 8 do
      begin
        G := WithCell(S, R, Col, 0);
        C := SudokuCandidates(G, R, Col);
        if not IntsEqual(C, [S[R * 9 + Col]]) then
          Exit(False);
      end;
    G := Classic;
    Sum := 0;
    for R := 0 to 8 do
      for Col := 0 to 8 do
        Sum := Sum + Length(SudokuCandidates(G, R, Col));
    Result := Sum = 153;
  except
    Result := False;
  end;
end;

{ ========================================================================== }
{ Algorithm B: Solving                                                        }
{ ========================================================================== }

function test_algo_b_01_already_solved: Boolean;
begin
  try
    Result := GridEquals(SudokuSolve(Solved), Solved);
  except
    Result := False;
  end;
end;

function test_algo_b_02_classic_puzzle: Boolean;
var
  G, R: TIntArray;
begin
  try
    G := Classic;
    R := SudokuSolve(G);
    Result := GridEquals(R, Solved) and GridEquals(G, Classic);
  except
    Result := False;
  end;
end;

function test_algo_b_03_invalid_grid: Boolean;
begin
  try
    Result := (Length(SudokuSolve(BoxConflict)) = 0)
      and (Length(SudokuSolve(Zeros(80))) = 0)
      and (Length(SudokuSolve(WithCell(Classic, 0, 2, 10))) = 0)
      and (SudokuCountSolutions(BoxConflict, 5) = 0)
      and (SudokuCountSolutions(Zeros(80), 5) = 0);
  except
    Result := False;
  end;
end;

function test_algo_b_04_dead_cell: Boolean;
begin
  try
    Result := (Length(SudokuSolve(DeadCell)) = 0)
      and (SudokuCountSolutions(DeadCell, 5) = 0);
  except
    Result := False;
  end;
end;

function test_algo_b_05_hidden_contradiction: Boolean;
var
  G: TIntArray;
begin
  try
    G := WithCell(Classic, 0, 2, 1);
    Result := (Length(SudokuSolve(G)) = 0)
      and (SudokuCountSolutions(G, 5) = 0);
  except
    Result := False;
  end;
end;

function test_algo_b_06_backtracking_required: Boolean;
begin
  try
    Result := GridEquals(SudokuSolve(ParseGrid(INKALA_STR)), ParseGrid(INKALA_SOL_STR));
  except
    Result := False;
  end;
end;

function test_algo_b_07_count_unique: Boolean;
begin
  try
    Result := (SudokuCountSolutions(Classic, 2) = 1)
      and (SudokuCountSolutions(Solved, 2) = 1);
  except
    Result := False;
  end;
end;

function test_algo_b_08_count_multiple: Boolean;
var
  Multi: TIntArray;
begin
  try
    Multi := WithCell(Classic, 2, 2, 0);
    Result := (SudokuCountSolutions(Multi, 100) = 8)
      and (SudokuCountSolutions(Multi, 5) = 5)
      and (SudokuCountSolutions(Multi, 1) = 1);
  except
    Result := False;
  end;
end;

function test_algo_b_09_count_empty_grid_limit: Boolean;
begin
  try
    Result := (SudokuCountSolutions(EmptyGrid, 2) = 2)
      and (SudokuCountSolutions(EmptyGrid, 1) = 1)
      and (SudokuCountSolutions(EmptyGrid, 0) = 0)
      and (SudokuCountSolutions(EmptyGrid, -3) = 0);
  except
    Result := False;
  end;
end;

function test_algo_b_10_stress_anti_brute_force: Boolean;
begin
  try
    Result := GridEquals(SudokuSolve(ParseGrid(ANTI_BF_STR)), ParseGrid(ANTI_BF_SOL_STR));
  except
    Result := False;
  end;
end;

procedure run_test(TestFunc: TTestFunc; const Name: AnsiString);
begin
  Inc(TotalTests);
  if TestFunc() then
    WriteLn('[PASS] ', Name)
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
  WriteLn('--- Algorithm A: Validation and Candidates ---');
  run_test(@test_algo_a_01_empty_grid_valid, 'Test A01 (Empty Grid Valid)');
  run_test(@test_algo_a_02_solved_grid_valid, 'Test A02 (Solved Grid Valid)');
  run_test(@test_algo_a_03_row_conflict, 'Test A03 (Row Conflict)');
  run_test(@test_algo_a_04_column_conflict, 'Test A04 (Column Conflict)');
  run_test(@test_algo_a_05_box_only_conflict, 'Test A05 (Box Only Conflict)');
  run_test(@test_algo_a_06_wrong_length, 'Test A06 (Wrong Length)');
  run_test(@test_algo_a_07_value_out_of_range, 'Test A07 (Value Out Of Range)');
  run_test(@test_algo_a_08_candidates_basic, 'Test A08 (Candidates Basic)');
  run_test(@test_algo_a_09_candidates_edge_cells, 'Test A09 (Candidates Edge Cells)');
  run_test(@test_algo_a_10_candidates_sweep, 'Test A10 (Candidates Sweep)');

  WriteLn;
  WriteLn('--- Algorithm B: Solving ---');
  run_test(@test_algo_b_01_already_solved, 'Test B01 (Already Solved)');
  run_test(@test_algo_b_02_classic_puzzle, 'Test B02 (Classic Puzzle)');
  run_test(@test_algo_b_03_invalid_grid, 'Test B03 (Invalid Grid)');
  run_test(@test_algo_b_04_dead_cell, 'Test B04 (Dead Cell)');
  run_test(@test_algo_b_05_hidden_contradiction, 'Test B05 (Hidden Contradiction)');
  run_test(@test_algo_b_06_backtracking_required, 'Test B06 (Backtracking Required)');
  run_test(@test_algo_b_07_count_unique, 'Test B07 (Count Unique)');
  run_test(@test_algo_b_08_count_multiple, 'Test B08 (Count Multiple)');
  run_test(@test_algo_b_09_count_empty_grid_limit, 'Test B09 (Count Empty Grid Limit)');
  run_test(@test_algo_b_10_stress_anti_brute_force, 'Test B10 (Stress Anti Brute Force)');

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
