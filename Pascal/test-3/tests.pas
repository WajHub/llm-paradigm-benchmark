program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, palindrome_tree;

type
  TTestFunc = function: Boolean;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

{ ========================================================================== }
{ Algorithm A: EertreeBuild, EertreeCountDistinct, EertreeLongestLength       }
{ ========================================================================== }

function test_algo_a_01_basic_aabaa: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 5 then Result := False;
    if EertreeLongestLength(T) <> 5 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_02_single_char: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('a', 1);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 1 then Result := False;
    if EertreeLongestLength(T) <> 1 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_03_all_same_chars: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aaaa', 4);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 4 then Result := False;
    if EertreeLongestLength(T) <> 4 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_04_no_internal_palindromes: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('abcde', 5);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 5 then Result := False;
    if EertreeLongestLength(T) <> 1 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_05_empty_string: Boolean;
var
  T: PEertree;
  S: AnsiString;
begin
  Result := False;
  T := nil;
  S := '';
  try
    T := EertreeBuild(PChar(S), 0);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 0 then Result := False;
    if EertreeLongestLength(T) <> 0 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_06_null_input: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild(nil, 5);
    Result := T = nil;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_07_two_char_palindrome: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aa', 2);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 2 then Result := False;
    if EertreeLongestLength(T) <> 2 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_08_abacaba: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('abacaba', 7);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 7 then Result := False;
    if EertreeLongestLength(T) <> 7 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_09_abba: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('abba', 4);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> 4 then Result := False;
    if EertreeLongestLength(T) <> 4 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_a_10_node_count_invariant: Boolean;
var
  T: PEertree;
  Cases: array[0..3] of AnsiString = ('racecar', 'aabbaa', 'abcbaabcba', 'zzzzzzzzz');
  Lens: array[0..3] of LongInt = (7, 6, 10, 9);
  I, D: LongInt;
begin
  Result := False;
  T := nil;
  try
    for I := 0 to 3 do
    begin
      T := EertreeBuild(PChar(Cases[I]), Lens[I]);
      if T = nil then
        Exit;
      D := EertreeCountDistinct(T);
      EertreeFree(T);
      if (D > Lens[I]) or (D <= 0) then
        Exit;
    end;

    T := EertreeBuild('racecar', 7);
    if T = nil then
      Exit;
    Result := EertreeCountDistinct(T) = 7;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

{ ========================================================================== }
{ Algorithm B: EertreeCountOccurrences                                        }
{ ========================================================================== }

function test_algo_b_01_single_char_occurrences: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'a', 1) = 4;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_02_even_palindrome_occurrences: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'aa', 2) = 2;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_03_full_string_palindrome: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'aabaa', 5) = 1;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_04_pattern_not_in_string: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'xyz', 3) = 0;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_05_pattern_not_a_palindrome: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'ab', 2) = 0;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_06_overlapping_even_palindromes: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    { "aaaa": "aa" appears 3 times (overlapping: [0..1],[1..2],[2..3]) }
    T := EertreeBuild('aaaa', 4);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'aa', 2) = 3;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_07_all_same_single_char: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aaaa', 4);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'a', 1) = 4;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_08_repeated_palindrome: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    { "abacaba": "aba" appears at [0..2] and [4..6] = 2 times }
    T := EertreeBuild('abacaba', 7);
    if T = nil then
      Exit;
    Result := EertreeCountOccurrences(T, 'aba', 3) = 2;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_09_null_arguments: Boolean;
var
  T: PEertree;
begin
  Result := False;
  T := nil;
  try
    T := EertreeBuild('aabaa', 5);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountOccurrences(nil, 'a', 1) <> 0 then Result := False;
    if EertreeCountOccurrences(T, nil, 1) <> 0 then Result := False;
    if EertreeCountOccurrences(T, 'a', 0) <> 0 then Result := False;
    if EertreeCountOccurrences(nil, nil, 0) <> 0 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

function test_algo_b_10_stress_test: Boolean;
var
  T: PEertree;
  S: AnsiString;
  N: LongInt;
begin
  Result := False;
  T := nil;
  N := 50000;
  try
    S := StringOfChar('a', N);
    T := EertreeBuild(PChar(S), N);
    if T = nil then
      Exit;

    Result := True;
    if EertreeCountDistinct(T) <> N then Result := False;
    if EertreeLongestLength(T) <> N then Result := False;
    if EertreeCountOccurrences(T, 'a', 1) <> N then Result := False;
    if EertreeCountOccurrences(T, 'aa', 2) <> N - 1 then Result := False;
  except
    Result := False;
  end;

  EertreeFree(T);
end;

procedure run_test(TestFunc: TTestFunc; const Name: AnsiString);
begin
  Inc(TotalTests);
  if TestFunc() then
  begin
    WriteLn('[PASS] ', Name);
  end
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
  WriteLn('--- Algorithm A: Palindrome Tree Construction & Structural Queries ---');
  run_test(@test_algo_a_01_basic_aabaa, 'Test A01 (Basic - aabaa)');
  run_test(@test_algo_a_02_single_char, 'Test A02 (Single Char)');
  run_test(@test_algo_a_03_all_same_chars, 'Test A03 (All Same Chars - aaaa)');
  run_test(@test_algo_a_04_no_internal_palindromes, 'Test A04 (No Internal Palindromes)');
  run_test(@test_algo_a_05_empty_string, 'Test A05 (Empty String)');
  run_test(@test_algo_a_06_null_input, 'Test A06 (NULL Input)');
  run_test(@test_algo_a_07_two_char_palindrome, 'Test A07 (Two-Char Palindrome - aa)');
  run_test(@test_algo_a_08_abacaba, 'Test A08 (Classic - abacaba)');
  run_test(@test_algo_a_09_abba, 'Test A09 (Even Palindrome - abba)');
  run_test(@test_algo_a_10_node_count_invariant, 'Test A10 (Node Count Invariant)');

  WriteLn;
  WriteLn('--- Algorithm B: Occurrence Counting ---');
  run_test(@test_algo_b_01_single_char_occurrences, 'Test B01 (Single Char Count)');
  run_test(@test_algo_b_02_even_palindrome_occurrences, 'Test B02 (Even Palindrome Count)');
  run_test(@test_algo_b_03_full_string_palindrome, 'Test B03 (Full String Palindrome)');
  run_test(@test_algo_b_04_pattern_not_in_string, 'Test B04 (Pattern Not In String)');
  run_test(@test_algo_b_05_pattern_not_a_palindrome, 'Test B05 (Pattern Not A Palindrome)');
  run_test(@test_algo_b_06_overlapping_even_palindromes, 'Test B06 (Overlapping Even Palindromes)');
  run_test(@test_algo_b_07_all_same_single_char, 'Test B07 (All Same - Single Char)');
  run_test(@test_algo_b_08_repeated_palindrome, 'Test B08 (Repeated Palindrome - aba)');
  run_test(@test_algo_b_09_null_arguments, 'Test B09 (NULL Arguments)');
  run_test(@test_algo_b_10_stress_test, 'Test B10 (Stress Test 50k chars)');

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
