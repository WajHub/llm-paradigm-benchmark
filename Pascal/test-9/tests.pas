program tests;

{$mode objfpc}{$H+}

uses
  SysUtils, Math, btree;

type
  TTestFunc = function: Boolean;

  TTreeStats = record
    Height: LongInt;       { levels; a single (possibly empty) root leaf = 1 }
    NodeCount: LongInt;
    InOrder: TIntArray;    { in-order key list }
    Count: LongInt;        { number of used entries in InOrder }
  end;

var
  FailedCount: LongInt = 0;
  TotalTests: LongInt = 0;
  FailedTests: array of AnsiString;

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

{ First Count keys 10, 20, ..., 10*Count. }
function Tens(Count: LongInt): TIntArray;
var
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I] := 10 * (I + 1);
end;

{ Generator G(seed, count, mod): LCG x = (x * 1103515245 + 12345) mod 2^31,
  outputs (x div 65536) mod Modulus. }
function Gen(Seed, Count, Modulus: LongInt): TIntArray;
var
  X: Int64;
  I: LongInt;
begin
  Result := nil;
  SetLength(Result, Count);
  X := Seed;
  for I := 0 to Count - 1 do
  begin
    X := (X * 1103515245 + 12345) mod 2147483648;
    Result[I] := LongInt((X div 65536) mod Modulus);
  end;
end;

{ Sorted copy without duplicates. }
function SortedDistinct(const Values: TIntArray): TIntArray;
var
  Tmp: TIntArray;
  I, J, V, N: LongInt;
begin
  Tmp := Copy(Values, 0, Length(Values));
  for I := 1 to High(Tmp) do
  begin
    V := Tmp[I];
    J := I - 1;
    while (J >= 0) and (Tmp[J] > V) do
    begin
      Tmp[J + 1] := Tmp[J];
      Dec(J);
    end;
    Tmp[J + 1] := V;
  end;
  Result := nil;
  SetLength(Result, Length(Tmp));
  N := 0;
  for I := 0 to High(Tmp) do
    if (N = 0) or (Result[N - 1] <> Tmp[I]) then
    begin
      Result[N] := Tmp[I];
      Inc(N);
    end;
  SetLength(Result, N);
end;

{ Sorted distinct Values minus every element of Removed. }
function SortedDifference(const Values, Removed: TIntArray): TIntArray;
var
  S: TIntArray;
  I, J, N: LongInt;
  Found: Boolean;
begin
  S := SortedDistinct(Values);
  Result := nil;
  SetLength(Result, Length(S));
  N := 0;
  for I := 0 to High(S) do
  begin
    Found := False;
    for J := 0 to High(Removed) do
      if Removed[J] = S[I] then
      begin
        Found := True;
        Break;
      end;
    if not Found then
    begin
      Result[N] := S[I];
      Inc(N);
    end;
  end;
  SetLength(Result, N);
end;

function SumOf(const Values: TIntArray): Int64;
var
  I: LongInt;
begin
  Result := 0;
  for I := 0 to High(Values) do
    Result := Result + Values[I];
end;

{ dump(leaf) = "(k0 k1 ...)", dump(internal) = "(dump(c0) k0 dump(c1) ... dump(ck))". }
function Dump(Node: PBTreeNode): AnsiString;
var
  I: LongInt;
begin
  if Node = nil then
    Exit('NIL');
  Result := '(';
  if Length(Node^.Children) = 0 then
  begin
    for I := 0 to High(Node^.Keys) do
    begin
      if I > 0 then Result := Result + ' ';
      Result := Result + IntToStr(Node^.Keys[I]);
    end;
  end
  else
  begin
    Result := Result + Dump(Node^.Children[0]);
    for I := 0 to High(Node^.Keys) do
    begin
      Result := Result + ' ' + IntToStr(Node^.Keys[I]) + ' ';
      if I + 1 <= High(Node^.Children) then
        Result := Result + Dump(Node^.Children[I + 1])
      else
        Result := Result + 'MISSING';
    end;
  end;
  Result := Result + ')';
end;

{ Recursively validates the B-tree invariants of the subtree Node: key counts,
  strictly ascending keys inside the open interval (Lo, Hi), child count = keys + 1,
  all leaves at the same depth. Collects node count and in-order keys. }
function CheckNode(Node: PBTreeNode; T: LongInt; IsRoot: Boolean; Lo, Hi: Int64;
  Depth: LongInt; var LeafDepth: LongInt; var Stats: TTreeStats): Boolean;
var
  I, K: LongInt;
  ChildLo, ChildHi: Int64;
begin
  Result := False;
  if Node = nil then Exit;
  Inc(Stats.NodeCount);
  K := Length(Node^.Keys);
  if K > 2 * T - 1 then Exit;
  if (not IsRoot) and (K < T - 1) then Exit;
  for I := 0 to K - 1 do
  begin
    if (Node^.Keys[I] <= Lo) or (Node^.Keys[I] >= Hi) then Exit;
    if (I > 0) and (Node^.Keys[I] <= Node^.Keys[I - 1]) then Exit;
  end;
  if Length(Node^.Children) = 0 then
  begin
    if LeafDepth < 0 then
      LeafDepth := Depth
    else if LeafDepth <> Depth then
      Exit;
    for I := 0 to K - 1 do
    begin
      if Stats.Count >= Length(Stats.InOrder) then
        SetLength(Stats.InOrder, 2 * Stats.Count + 16);
      Stats.InOrder[Stats.Count] := Node^.Keys[I];
      Inc(Stats.Count);
    end;
    Exit(True);
  end;
  if (K = 0) or (Length(Node^.Children) <> K + 1) then Exit;
  for I := 0 to K do
  begin
    if I = 0 then ChildLo := Lo else ChildLo := Node^.Keys[I - 1];
    if I = K then ChildHi := Hi else ChildHi := Node^.Keys[I];
    if not CheckNode(Node^.Children[I], T, False, ChildLo, ChildHi, Depth + 1,
      LeafDepth, Stats) then
      Exit;
    if I < K then
    begin
      if Stats.Count >= Length(Stats.InOrder) then
        SetLength(Stats.InOrder, 2 * Stats.Count + 16);
      Stats.InOrder[Stats.Count] := Node^.Keys[I];
      Inc(Stats.Count);
    end;
  end;
  Result := True;
end;

{ Validates the whole tree; on success Stats holds height, node count, in-order keys. }
function ValidTree(Root: PBTreeNode; T: LongInt; out Stats: TTreeStats): Boolean;
var
  LeafDepth: LongInt;
begin
  Stats.Height := 0;
  Stats.NodeCount := 0;
  Stats.InOrder := nil;
  Stats.Count := 0;
  LeafDepth := -1;
  Result := CheckNode(Root, T, True, -High(Int64), High(Int64), 1, LeafDepth, Stats);
  SetLength(Stats.InOrder, Stats.Count);
  Stats.Height := LeafDepth;
end;

function CheckInsertDump(T: LongInt; const Keys: TIntArray; const Expected: AnsiString): Boolean;
var
  R: PBTreeNode;
begin
  Result := False;
  R := nil;
  try
    R := BTreeInsertAll(T, Keys);
    if R = nil then Exit;
    Result := Dump(R) = Expected;
  except
    Result := False;
  end;
  FreeBTree(R);
end;

function CheckDeleteDump(T: LongInt; const Keys, Deletions: TIntArray;
  const Expected: AnsiString): Boolean;
var
  R: PBTreeNode;
begin
  Result := False;
  R := nil;
  try
    R := BTreeDeleteAll(T, Keys, Deletions);
    if R = nil then Exit;
    Result := Dump(R) = Expected;
  except
    Result := False;
  end;
  FreeBTree(R);
end;

{ ========================================================================== }
{ Algorithm A: Insertion                                                      }
{ ========================================================================== }

function test_algo_a_01_empty: Boolean;
begin
  Result := CheckInsertDump(2, nil, '()');
end;

function test_algo_a_02_invalid_degree: Boolean;
var
  R: PBTreeNode;
begin
  Result := False;
  R := nil;
  try
    R := BTreeInsertAll(1, MakeInts([1, 2, 3]));
    Result := R = nil;
  except
    Result := False;
  end;
  FreeBTree(R);
end;

function test_algo_a_03_single_leaf: Boolean;
begin
  Result := CheckInsertDump(3, MakeInts([5, 1, 3]), '(1 3 5)');
end;

function test_algo_a_04_root_split: Boolean;
begin
  Result := CheckInsertDump(2, MakeInts([1, 2, 3, 4]), '((1) 2 (3 4))');
end;

function test_algo_a_05_duplicate_on_full_root: Boolean;
begin
  Result := CheckInsertDump(2, MakeInts([1, 2, 3, 2]), '(1 2 3)');
end;

function test_algo_a_06_ascending: Boolean;
begin
  Result := CheckInsertDump(2, Tens(10),
    '(((10) 20 (30)) 40 ((50) 60 (70) 80 (90 100)))');
end;

function test_algo_a_07_proactive_split: Boolean;
begin
  Result := CheckInsertDump(2, MakeInts([10, 9, 8, 7, 6, 5, 4, 3, 2, 1]),
    '(((1 2) 3 (4) 5 (6)) 7 ((8) 9 (10)))');
end;

function test_algo_a_08_textbook_t3: Boolean;
begin
  Result := CheckInsertDump(3,
    MakeInts([8, 3, 15, 1, 20, 6, 11, 17, 4, 25, 13, 9, 30, 2, 22, 7, 14, 18]),
    '((1 2) 3 (4 6 7) 8 (9 11 13 14 15) 17 (18 20 22 25 30))');
end;

function test_algo_a_09_invariants: Boolean;
var
  Keys, Expected: TIntArray;
  R: PBTreeNode;
  Stats: TTreeStats;
begin
  Result := False;
  R := nil;
  Keys := Gen(7, 100, 1000);
  Expected := SortedDistinct(Keys);
  try
    R := BTreeInsertAll(3, Keys);
    if R = nil then Exit;
    Result := ValidTree(R, 3, Stats)
      and (Length(Expected) = 95)
      and IntsEqual(Stats.InOrder, Expected)
      and (Stats.Height = 3)
      and (Stats.NodeCount = 28);
  except
    Result := False;
  end;
  FreeBTree(R);
end;

function test_algo_a_10_stress: Boolean;
var
  Keys, Expected: TIntArray;
  R: PBTreeNode;
  Stats: TTreeStats;
begin
  Result := False;
  R := nil;
  Keys := Gen(42, 2000, 100000);
  Expected := SortedDistinct(Keys);
  try
    R := BTreeInsertAll(4, Keys);
    if R = nil then Exit;
    Result := ValidTree(R, 4, Stats)
      and (Length(Expected) = 1937)
      and (SumOf(Expected) = 31779629)
      and IntsEqual(Stats.InOrder, Expected)
      and (Stats.Height = 5)
      and (Stats.NodeCount = 413)
      and IntsEqual(R^.Keys, [15269]);
  except
    Result := False;
  end;
  FreeBTree(R);
end;

{ ========================================================================== }
{ Algorithm B: Deletion                                                       }
{ ========================================================================== }

function test_algo_b_01_delete_from_leaf: Boolean;
begin
  Result := CheckDeleteDump(3, MakeInts([5, 1, 3, 9, 7]), MakeInts([3]), '(1 5 7 9)');
end;

function test_algo_b_02_absent_key_unchanged: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([10, 30, 20, 40]), MakeInts([15]),
    '((10) 20 (30 40))');
end;

function test_algo_b_03_delete_all: Boolean;
begin
  Result := CheckDeleteDump(2, Tens(10),
    MakeInts([50, 10, 100, 30, 70, 20, 90, 40, 80, 60, 999]), '()');
end;

function test_algo_b_04_predecessor_preferred: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([10, 20, 30, 40, 5]), MakeInts([20]),
    '((5) 10 (30 40))');
end;

function test_algo_b_05_successor: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([10, 20, 30, 40, 35]), MakeInts([20]),
    '((10) 30 (35 40))');
end;

function test_algo_b_06_merge_children: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([14, 3, 4, 11, 5, 15]), MakeInts([4]),
    '((3 5) 11 (14 15))');
end;

function test_algo_b_07_borrow_left_first: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([21, 12, 9, 10, 17, 23, 24]), MakeInts([17]),
    '((9) 10 (12) 21 (23 24))');
end;

function test_algo_b_08_merge_right_first: Boolean;
begin
  Result := CheckDeleteDump(2, MakeInts([3, 4, 19, 12, 7, 15, 22, 28]), MakeInts([7]),
    '((3) 4 (12 15) 19 (22 28))');
end;

function test_algo_b_09_root_shrink: Boolean;
begin
  Result := CheckDeleteDump(2, Tens(10), MakeInts([10, 20]),
    '((30) 40 (50) 60 (70) 80 (90 100))');
end;

function test_algo_b_10_stress_invariants: Boolean;
var
  Keys, Dels, Expected: TIntArray;
  R: PBTreeNode;
  Stats: TTreeStats;
begin
  Result := False;
  R := nil;
  Keys := Gen(9, 300, 500);
  Dels := Gen(3, 250, 500);
  Expected := SortedDifference(Keys, Dels);
  try
    R := BTreeDeleteAll(3, Keys, Dels);
    if R = nil then Exit;
    Result := ValidTree(R, 3, Stats)
      and (Length(Expected) = 150)
      and (SumOf(Expected) = 39704)
      and IntsEqual(Stats.InOrder, Expected)
      and (Stats.Height = 4)
      and (Stats.NodeCount = 55)
      and IntsEqual(R^.Keys, [293]);
  except
    Result := False;
  end;
  FreeBTree(R);
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
  WriteLn('--- Algorithm A: Insertion ---');
  run_test(@test_algo_a_01_empty, 'Test A01 (Empty)');
  run_test(@test_algo_a_02_invalid_degree, 'Test A02 (Invalid Degree)');
  run_test(@test_algo_a_03_single_leaf, 'Test A03 (Single Leaf)');
  run_test(@test_algo_a_04_root_split, 'Test A04 (Root Split)');
  run_test(@test_algo_a_05_duplicate_on_full_root, 'Test A05 (Duplicate On Full Root)');
  run_test(@test_algo_a_06_ascending, 'Test A06 (Ascending)');
  run_test(@test_algo_a_07_proactive_split, 'Test A07 (Proactive Split)');
  run_test(@test_algo_a_08_textbook_t3, 'Test A08 (Textbook t3)');
  run_test(@test_algo_a_09_invariants, 'Test A09 (Invariants)');
  run_test(@test_algo_a_10_stress, 'Test A10 (Stress)');

  WriteLn;
  WriteLn('--- Algorithm B: Deletion ---');
  run_test(@test_algo_b_01_delete_from_leaf, 'Test B01 (Delete From Leaf)');
  run_test(@test_algo_b_02_absent_key_unchanged, 'Test B02 (Absent Key Unchanged)');
  run_test(@test_algo_b_03_delete_all, 'Test B03 (Delete All)');
  run_test(@test_algo_b_04_predecessor_preferred, 'Test B04 (Predecessor Preferred)');
  run_test(@test_algo_b_05_successor, 'Test B05 (Successor)');
  run_test(@test_algo_b_06_merge_children, 'Test B06 (Merge Children)');
  run_test(@test_algo_b_07_borrow_left_first, 'Test B07 (Borrow Left First)');
  run_test(@test_algo_b_08_merge_right_first, 'Test B08 (Merge Right First)');
  run_test(@test_algo_b_09_root_shrink, 'Test B09 (Root Shrink)');
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
