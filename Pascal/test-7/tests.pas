program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, sequence_alignment;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

const
  STRESS_A =
    'CCCCACCACCAGGACACTTTCAGAGTTCTCCGTCATCGTTAGCAGCACGGTTAGCTTGTCTCTGTCTATTTCACGACTGGTGGAGTCGTATAGTCACGAGCTGGGTATGTCCTGAAGCTA';
  STRESS_B =
    'GACATTGGAACTATGTAAGTCCTCTTCCGGACCTTTTCAGAGACTTAGGAGGTCGGCCCGGGGCTCTACACGGGGTGGACTGTTTGACCTAATGGCCCTTCCGACCAGGC';

{ Helpers }

{ S without '-' characters. }
function StripGaps(const S: AnsiString): AnsiString;
var
  I: LongInt;
begin
  Result := '';
  for I := 1 to Length(S) do
    if S[I] <> '-' then
      Result := Result + S[I];
end;

{ Score of the alignment SA/SB by definition: per column +M / -X for two characters,
  every maximal run of '-' in one row of length L costs O + L*E.
  Returns False if the two rows differ in length or a column is '-'/'-'. }
function RecomputeScore(const SA, SB: AnsiString; M, X, O, E: LongInt;
  out Score: LongInt): Boolean;
var
  K, Row, RunLen: LongInt;
  S: AnsiString;
begin
  Score := 0;
  if Length(SA) <> Length(SB) then
    Exit(False);
  for K := 1 to Length(SA) do
  begin
    if (SA[K] = '-') and (SB[K] = '-') then
      Exit(False);
    if (SA[K] <> '-') and (SB[K] <> '-') then
    begin
      if SA[K] = SB[K] then
        Score := Score + M
      else
        Score := Score - X;
    end;
  end;
  for Row := 0 to 1 do
  begin
    if Row = 0 then S := SA else S := SB;
    RunLen := 0;
    for K := 1 to Length(S) + 1 do
    begin
      if (K <= Length(S)) and (S[K] = '-') then
        Inc(RunLen)
      else if RunLen > 0 then
      begin
        Score := Score - (O + RunLen * E);
        RunLen := 0;
      end;
    end;
  end;
  Result := True;
end;

{ Full check of an alignment result: Score field, equal lengths, gaps removed give
  A and B back, no '-'/'-' column, recomputed score = Expected. }
function ValidAlignment(R: PAlignmentResult; const A, B: AnsiString;
  M, X, O, E, Expected: LongInt): Boolean;
var
  Recomputed: LongInt;
begin
  Result := False;
  if R = nil then Exit;
  if R^.Score <> Expected then Exit;
  if Length(R^.AlignedA) <> Length(R^.AlignedB) then Exit;
  if StripGaps(R^.AlignedA) <> A then Exit;
  if StripGaps(R^.AlignedB) <> B then Exit;
  if not RecomputeScore(R^.AlignedA, R^.AlignedB, M, X, O, E, Recomputed) then Exit;
  Result := Recomputed = Expected;
end;

{ Runs AlignmentAlign and checks all invariants; if ExpA/ExpB are given (Exact=True)
  the aligned strings must match them exactly. }
function CheckAlign(const A, B: AnsiString; M, X, O, E, Expected: LongInt;
  Exact: Boolean; const ExpA, ExpB: AnsiString): Boolean;
var
  R: PAlignmentResult;
begin
  Result := False;
  R := nil;
  try
    R := AlignmentAlign(A, B, M, X, O, E);
    if R = nil then Exit;
    Result := ValidAlignment(R, A, B, M, X, O, E, Expected);
    if Result and Exact then
      Result := (R^.AlignedA = ExpA) and (R^.AlignedB = ExpB);
  except
    Result := False;
  end;
  FreeAlignmentResult(R);
end;

{ ========================================================================== }
{ Algorithm A: Alignment Score                                                }
{ ========================================================================== }

function test_algo_a_01_both_empty: Boolean;
begin
  try
    Result := AlignmentScore('', '', 1, 1, 2, 1) = 0;
  except
    Result := False;
  end;
end;

function test_algo_a_02_one_empty: Boolean;
begin
  try
    Result := AlignmentScore('', 'ACG', 1, 1, 2, 1) = -5;
  except
    Result := False;
  end;
end;

function test_algo_a_03_identical: Boolean;
begin
  try
    Result := AlignmentScore('GATTACA', 'GATTACA', 2, 1, 3, 1) = 14;
  except
    Result := False;
  end;
end;

function test_algo_a_04_mismatch_beats_gaps: Boolean;
begin
  try
    Result := AlignmentScore('A', 'C', 1, 1, 2, 1) = -1;
  except
    Result := False;
  end;
end;

function test_algo_a_05_textbook: Boolean;
begin
  try
    Result := AlignmentScore('GATTACA', 'GCATGCU', 1, 1, 1, 1) = -1;
  except
    Result := False;
  end;
end;

function test_algo_a_06_one_long_gap: Boolean;
begin
  try
    Result := AlignmentScore('AAAGGGTTT', 'AAATTT', 2, 2, 5, 1) = 4;
  except
    Result := False;
  end;
end;

function test_algo_a_07_zero_extend: Boolean;
begin
  try
    Result := AlignmentScore('TTACGGA', 'ACG', 2, 2, 2, 0) = 2;
  except
    Result := False;
  end;
end;

function test_algo_a_08_adjacent_gaps_beat_mismatch: Boolean;
begin
  try
    Result := AlignmentScore('XAY', 'XCY', 1, 10, 1, 1) = -2;
  except
    Result := False;
  end;
end;

function test_algo_a_09_terminal_gaps_penalized: Boolean;
begin
  try
    Result := AlignmentScore('AAAACCCC', 'CCCC', 2, 1, 3, 1) = 1;
  except
    Result := False;
  end;
end;

function test_algo_a_10_stress: Boolean;
begin
  try
    Result := AlignmentScore(STRESS_A, STRESS_B, 2, 1, 3, 1) = 16;
  except
    Result := False;
  end;
end;

{ ========================================================================== }
{ Algorithm B: Alignment Reconstruction                                       }
{ ========================================================================== }

function test_algo_b_01_both_empty: Boolean;
begin
  Result := CheckAlign('', '', 1, 1, 2, 1, 0, True, '', '');
end;

function test_algo_b_02_second_empty: Boolean;
begin
  Result := CheckAlign('ACG', '', 1, 1, 2, 1, -5, True, 'ACG', '---');
end;

function test_algo_b_03_identical: Boolean;
begin
  Result := CheckAlign('GATTACA', 'GATTACA', 2, 1, 3, 1, 14, True, 'GATTACA', 'GATTACA');
end;

function test_algo_b_04_unique_long_gap: Boolean;
begin
  Result := CheckAlign('AAAGGGTTT', 'AAATTT', 2, 2, 5, 1, 4, True, 'AAAGGGTTT', 'AAA---TTT');
end;

function test_algo_b_05_adjacent_gaps: Boolean;
begin
  Result := CheckAlign('XAY', 'XCY', 1, 10, 1, 1, -2, False, '', '');
end;

function test_algo_b_06_textbook_unique: Boolean;
begin
  Result := CheckAlign('GATTACA', 'GCATGCU', 1, 1, 1, 1, -1, True, 'GATTACA', 'GCATGCU');
end;

function test_algo_b_07_gap_merging: Boolean;
begin
  Result := CheckAlign('ACCCGT', 'AGT', 2, 3, 6, 1, -3, True, 'ACCCGT', 'A---GT');
end;

function test_algo_b_08_gaps_in_both_rows: Boolean;
begin
  Result := CheckAlign('CACGCA', 'AGGCGC', 3, 2, 3, 1, -1, True, 'CA--CGCA', '-AGGCGC-');
end;

function test_algo_b_09_tied_gap_positions: Boolean;
begin
  Result := CheckAlign('AAAA', 'AA', 1, 1, 1, 1, -1, False, '', '');
end;

function test_algo_b_10_stress_invariants: Boolean;
begin
  Result := CheckAlign(STRESS_A, STRESS_B, 3, 2, 5, 1, 10, False, '', '');
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
  WriteLn('--- Algorithm A: Alignment Score ---');
  run_test(@test_algo_a_01_both_empty, 'Test A01 (Both Empty)');
  run_test(@test_algo_a_02_one_empty, 'Test A02 (One Empty)');
  run_test(@test_algo_a_03_identical, 'Test A03 (Identical)');
  run_test(@test_algo_a_04_mismatch_beats_gaps, 'Test A04 (Mismatch Beats Gaps)');
  run_test(@test_algo_a_05_textbook, 'Test A05 (Textbook)');
  run_test(@test_algo_a_06_one_long_gap, 'Test A06 (One Long Gap)');
  run_test(@test_algo_a_07_zero_extend, 'Test A07 (Zero Extend)');
  run_test(@test_algo_a_08_adjacent_gaps_beat_mismatch, 'Test A08 (Adjacent Gaps Beat Mismatch)');
  run_test(@test_algo_a_09_terminal_gaps_penalized, 'Test A09 (Terminal Gaps Penalized)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress)');

  WriteLn;
  WriteLn('--- Algorithm B: Alignment Reconstruction ---');
  run_test(@test_algo_b_01_both_empty, 'Test B01 (Both Empty)');
  run_test(@test_algo_b_02_second_empty, 'Test B02 (Second Empty)');
  run_test(@test_algo_b_03_identical, 'Test B03 (Identical)');
  run_test(@test_algo_b_04_unique_long_gap, 'Test B04 (Unique Long Gap)');
  run_test(@test_algo_b_05_adjacent_gaps, 'Test B05 (Adjacent Gaps)');
  run_test(@test_algo_b_06_textbook_unique, 'Test B06 (Textbook Unique)');
  run_test(@test_algo_b_07_gap_merging, 'Test B07 (Gap Merging)');
  run_test(@test_algo_b_08_gaps_in_both_rows, 'Test B08 (Gaps In Both Rows)');
  run_test(@test_algo_b_09_tied_gap_positions, 'Test B09 (Tied Gap Positions)');
  run_test(@test_algo_b_10_stress_invariants, 'Test B10 (Stress Invariants)');

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
