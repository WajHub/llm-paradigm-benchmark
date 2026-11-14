unit btree;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TIntArray = array of LongInt;

  { A B-tree node. Keys are strictly ascending. A leaf has Length(Children) = 0;
    an internal node with k keys has exactly k + 1 children.
    The empty tree is a root leaf with no keys (not nil). }
  PBTreeNode = ^TBTreeNode;
  TBTreeNodeArray = array of PBTreeNode;
  TBTreeNode = record
    Keys: TIntArray;
    Children: TBTreeNodeArray;
  end;

function BTreeInsertAll(MinDegree: LongInt; const Keys: TIntArray): PBTreeNode;
function BTreeDeleteAll(MinDegree: LongInt; const Keys, Deletions: TIntArray): PBTreeNode;
procedure FreeBTree(var Root: PBTreeNode);

implementation

function NewNode: PBTreeNode;
var
  p: PBTreeNode;
begin
  New(p);
  p^.Keys := nil;
  p^.Children := nil;
  Result := p;
end;

procedure IntInsertAt(var A: TIntArray; pos: LongInt; v: LongInt);
var
  j, n: LongInt;
begin
  n := Length(A);
  SetLength(A, n + 1);
  for j := n downto pos + 1 do
    A[j] := A[j - 1];
  A[pos] := v;
end;

procedure IntDeleteAt(var A: TIntArray; pos: LongInt);
var
  j, n: LongInt;
begin
  n := Length(A);
  for j := pos to n - 2 do
    A[j] := A[j + 1];
  SetLength(A, n - 1);
end;

procedure IntAppend(var A: TIntArray; const B: TIntArray);
var
  j, m: LongInt;
begin
  m := Length(A);
  SetLength(A, m + Length(B));
  for j := 0 to High(B) do
    A[m + j] := B[j];
end;

procedure NodeInsertAt(var A: TBTreeNodeArray; pos: LongInt; v: PBTreeNode);
var
  j, n: LongInt;
begin
  n := Length(A);
  SetLength(A, n + 1);
  for j := n downto pos + 1 do
    A[j] := A[j - 1];
  A[pos] := v;
end;

procedure NodeDeleteAt(var A: TBTreeNodeArray; pos: LongInt);
var
  j, n: LongInt;
begin
  n := Length(A);
  for j := pos to n - 2 do
    A[j] := A[j + 1];
  SetLength(A, n - 1);
end;

procedure NodeAppend(var A: TBTreeNodeArray; const B: TBTreeNodeArray);
var
  j, m: LongInt;
begin
  m := Length(A);
  SetLength(A, m + Length(B));
  for j := 0 to High(B) do
    A[m + j] := B[j];
end;

{ First index i with A[i] >= k, or Length(A) if none }
function LowerBound(const A: TIntArray; k: LongInt): LongInt;
var
  lo, hi, mid: LongInt;
begin
  lo := 0;
  hi := Length(A);
  while lo < hi do begin
    mid := (lo + hi) div 2;
    if A[mid] < k then
      lo := mid + 1
    else
      hi := mid;
  end;
  Result := lo;
end;

function Contains(Root: PBTreeNode; k: LongInt): Boolean;
var
  x: PBTreeNode;
  j: LongInt;
begin
  x := Root;
  while x <> nil do begin
    j := LowerBound(x^.Keys, k);
    if (j < Length(x^.Keys)) and (x^.Keys[j] = k) then begin
      Result := True;
      exit;
    end;
    if Length(x^.Children) = 0 then begin
      Result := False;
      exit;
    end;
    x := x^.Children[j];
  end;
  Result := False;
end;

function MaxKey(x: PBTreeNode): LongInt;
begin
  while Length(x^.Children) > 0 do
    x := x^.Children[High(x^.Children)];
  Result := x^.Keys[High(x^.Keys)];
end;

function MinKey(x: PBTreeNode): LongInt;
begin
  while Length(x^.Children) > 0 do
    x := x^.Children[0];
  Result := x^.Keys[0];
end;

{ Split full child i of x (child has 2t-1 keys) }
procedure SplitChild(x: PBTreeNode; i: LongInt; t: LongInt);
var
  y, z: PBTreeNode;
  j: LongInt;
  median: LongInt;
begin
  y := x^.Children[i];
  z := NewNode;
  median := y^.Keys[t - 1];

  SetLength(z^.Keys, t - 1);
  for j := 0 to t - 2 do
    z^.Keys[j] := y^.Keys[t + j];

  if Length(y^.Children) > 0 then begin
    SetLength(z^.Children, t);
    for j := 0 to t - 1 do
      z^.Children[j] := y^.Children[t + j];
    SetLength(y^.Children, t);
  end;

  SetLength(y^.Keys, t - 1);

  IntInsertAt(x^.Keys, i, median);
  NodeInsertAt(x^.Children, i + 1, z);
end;

procedure InsertNonFull(x: PBTreeNode; k: LongInt; t: LongInt);
var
  i: LongInt;
begin
  while Length(x^.Children) > 0 do begin
    i := LowerBound(x^.Keys, k);
    if Length(x^.Children[i]^.Keys) = 2 * t - 1 then begin
      SplitChild(x, i, t);
      if k > x^.Keys[i] then
        Inc(i);
    end;
    x := x^.Children[i];
  end;
  i := LowerBound(x^.Keys, k);
  IntInsertAt(x^.Keys, i, k);
end;

function BuildTree(t: LongInt; const Keys: TIntArray): PBTreeNode;
var
  root, s: PBTreeNode;
  idx: LongInt;
begin
  root := NewNode;
  for idx := 0 to High(Keys) do begin
    if not Contains(root, Keys[idx]) then begin
      if Length(root^.Keys) = 2 * t - 1 then begin
        s := NewNode;
        SetLength(s^.Children, 1);
        s^.Children[0] := root;
        SplitChild(s, 0, t);
        root := s;
      end;
      InsertNonFull(root, Keys[idx], t);
    end;
  end;
  Result := root;
end;

{ CLRS top-down delete of k, assumed to be present in the subtree of x.
  x is never the tree root with zero keys here; non-root x has >= t keys. }
procedure DeleteFrom(x: PBTreeNode; k: LongInt; t: LongInt);
var
  j, i, n, m, idx: LongInt;
  y, z, c, lft, rgt: PBTreeNode;
  kp: LongInt;
begin
  n := Length(x^.Keys);
  j := LowerBound(x^.Keys, k);
  if (j < n) and (x^.Keys[j] = k) then begin
    if Length(x^.Children) = 0 then begin
      { case 1: leaf }
      IntDeleteAt(x^.Keys, j);
    end else begin
      { case 2: internal }
      y := x^.Children[j];
      z := x^.Children[j + 1];
      if Length(y^.Keys) >= t then begin
        kp := MaxKey(y);
        DeleteFrom(y, kp, t);
        x^.Keys[j] := kp;
      end else if Length(z^.Keys) >= t then begin
        kp := MinKey(z);
        DeleteFrom(z, kp, t);
        x^.Keys[j] := kp;
      end else begin
        { merge y, k, z into y }
        m := Length(y^.Keys);
        SetLength(y^.Keys, m + 1);
        y^.Keys[m] := k;
        IntAppend(y^.Keys, z^.Keys);
        if Length(z^.Children) > 0 then
          NodeAppend(y^.Children, z^.Children);
        Dispose(z);
        IntDeleteAt(x^.Keys, j);
        NodeDeleteAt(x^.Children, j + 1);
        DeleteFrom(y, k, t);
      end;
    end;
  end else begin
    { case 3: k lies in child j }
    i := j;
    c := x^.Children[i];
    if Length(c^.Keys) = t - 1 then begin
      if (i > 0) and (Length(x^.Children[i - 1]^.Keys) >= t) then begin
        { rotate right }
        lft := x^.Children[i - 1];
        IntInsertAt(c^.Keys, 0, x^.Keys[i - 1]);
        idx := Length(lft^.Keys) - 1;
        x^.Keys[i - 1] := lft^.Keys[idx];
        IntDeleteAt(lft^.Keys, idx);
        if Length(lft^.Children) > 0 then begin
          idx := Length(lft^.Children) - 1;
          NodeInsertAt(c^.Children, 0, lft^.Children[idx]);
          NodeDeleteAt(lft^.Children, idx);
        end;
      end else if (i < n) and (Length(x^.Children[i + 1]^.Keys) >= t) then begin
        { rotate left }
        rgt := x^.Children[i + 1];
        IntInsertAt(c^.Keys, Length(c^.Keys), x^.Keys[i]);
        x^.Keys[i] := rgt^.Keys[0];
        IntDeleteAt(rgt^.Keys, 0);
        if Length(rgt^.Children) > 0 then begin
          NodeInsertAt(c^.Children, Length(c^.Children), rgt^.Children[0]);
          NodeDeleteAt(rgt^.Children, 0);
        end;
      end else if i < n then begin
        { merge c, separator x.Keys[i], right sibling into c }
        rgt := x^.Children[i + 1];
        IntInsertAt(c^.Keys, Length(c^.Keys), x^.Keys[i]);
        IntAppend(c^.Keys, rgt^.Keys);
        if Length(rgt^.Children) > 0 then
          NodeAppend(c^.Children, rgt^.Children);
        Dispose(rgt);
        IntDeleteAt(x^.Keys, i);
        NodeDeleteAt(x^.Children, i + 1);
      end else begin
        { merge left sibling, separator x.Keys[i-1], c into left }
        lft := x^.Children[i - 1];
        IntInsertAt(lft^.Keys, Length(lft^.Keys), x^.Keys[i - 1]);
        IntAppend(lft^.Keys, c^.Keys);
        if Length(c^.Children) > 0 then
          NodeAppend(lft^.Children, c^.Children);
        Dispose(c);
        IntDeleteAt(x^.Keys, i - 1);
        NodeDeleteAt(x^.Children, i);
      end;
    end;
    j := LowerBound(x^.Keys, k);
    DeleteFrom(x^.Children[j], k, t);
  end;
end;

procedure FreeNode(p: PBTreeNode);
var
  j: LongInt;
begin
  if p = nil then
    exit;
  for j := 0 to High(p^.Children) do
    FreeNode(p^.Children[j]);
  Dispose(p);
end;

function BTreeInsertAll(MinDegree: LongInt; const Keys: TIntArray): PBTreeNode;
begin
  if MinDegree < 2 then begin
    Result := nil;
    exit;
  end;
  Result := BuildTree(MinDegree, Keys);
end;

function BTreeDeleteAll(MinDegree: LongInt; const Keys, Deletions: TIntArray): PBTreeNode;
var
  root, old: PBTreeNode;
  idx: LongInt;
begin
  if MinDegree < 2 then begin
    Result := nil;
    exit;
  end;
  root := BuildTree(MinDegree, Keys);
  for idx := 0 to High(Deletions) do begin
    if Contains(root, Deletions[idx]) then begin
      DeleteFrom(root, Deletions[idx], MinDegree);
      if (Length(root^.Keys) = 0) and (Length(root^.Children) > 0) then begin
        old := root;
        root := old^.Children[0];
        Dispose(old);
      end;
    end;
  end;
  Result := root;
end;

procedure FreeBTree(var Root: PBTreeNode);
begin
  FreeNode(Root);
  Root := nil;
end;

end.
