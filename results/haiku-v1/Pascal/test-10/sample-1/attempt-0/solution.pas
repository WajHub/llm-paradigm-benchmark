unit order_stats;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TIntArray = array of LongInt;

  { Result of SelectKth: the k-th smallest value and the trace of top-level pivots. }
  PSelectResult = ^TSelectResult;
  TSelectResult = record
    Value: LongInt;
    Pivots: TIntArray;
  end;

  { A read-only sorted (non-decreasing) virtual sequence of Len elements.
    Element I (0 <= I < Len) is read ONLY as Src^.Get(Src, I); Ctx belongs to the caller. }
  PSortedSource = ^TSortedSource;
  TGetFunc = function(Src: PSortedSource; Index: LongInt): LongInt;
  TSortedSource = record
    Len: LongInt;
    Get: TGetFunc;
    Ctx: Pointer;
  end;

function MedianOfMedians(const Xs: TIntArray; out Value: LongInt): Boolean;
function SelectKth(const Xs: TIntArray; K: LongInt): PSelectResult;
procedure FreeSelectResult(var R: PSelectResult);
function MedianTwoSorted(A, B: PSortedSource; out Value: Double): Boolean;

implementation

procedure InsertionSortInts(var Arr: TIntArray; cnt: LongInt);
var
  a, b: LongInt;
  tmp: LongInt;
begin
  for a := 1 to cnt - 1 do begin
    tmp := Arr[a];
    b := a - 1;
    while (b >= 0) and (Arr[b] > tmp) do begin
      Arr[b + 1] := Arr[b];
      Dec(b);
    end;
    Arr[b + 1] := tmp;
  end;
end;

procedure SiftDownInts(var Arr: TIntArray; start, stop: LongInt);
var
  root, child, tmp: LongInt;
begin
  root := start;
  while 2 * root + 1 <= stop do begin
    child := 2 * root + 1;
    if (child + 1 <= stop) and (Arr[child] < Arr[child + 1]) then
      Inc(child);
    if Arr[root] < Arr[child] then begin
      tmp := Arr[root];
      Arr[root] := Arr[child];
      Arr[child] := tmp;
      root := child;
    end
    else
      Exit;
  end;
end;

procedure HeapSortInts(var Arr: TIntArray);
var
  n, i: LongInt;
  tmp: LongInt;
begin
  n := Length(Arr);
  if n < 2 then
    Exit;
  for i := (n div 2) - 1 downto 0 do
    SiftDownInts(Arr, i, n - 1);
  for i := n - 1 downto 1 do begin
    tmp := Arr[0];
    Arr[0] := Arr[i];
    Arr[i] := tmp;
    SiftDownInts(Arr, 0, i - 1);
  end;
end;

function MedianOfMedians(const Xs: TIntArray; out Value: LongInt): Boolean;
var
  n, g, cnt, k, mCount: LongInt;
  Meds, Grp: TIntArray;
begin
  Value := 0;
  n := Length(Xs);
  if n = 0 then begin
    Result := False;
    Exit;
  end;
  mCount := (n + 4) div 5;
  SetLength(Meds, mCount);
  SetLength(Grp, 5);
  for g := 0 to mCount - 1 do begin
    cnt := n - g * 5;
    if cnt > 5 then
      cnt := 5;
    for k := 0 to cnt - 1 do
      Grp[k] := Xs[g * 5 + k];
    InsertionSortInts(Grp, cnt);
    Meds[g] := Grp[(cnt - 1) div 2];
  end;
  HeapSortInts(Meds);
  Value := Meds[(mCount - 1) div 2];
  Result := True;
end;

function SelectKth(const Xs: TIntArray; K: LongInt): PSelectResult;
var
  R: PSelectResult;
  Cur, L, G: TIntArray;
  nCur, nL, nG, nE, iL, iG, idx, kk: LongInt;
  P: LongInt;
begin
  Result := nil;
  if (K < 0) or (K >= Length(Xs)) then
    Exit;

  New(R);
  R^.Value := 0;
  R^.Pivots := nil;

  Cur := Copy(Xs, 0, Length(Xs));
  kk := K;
  while True do begin
    nCur := Length(Cur);
    if nCur <= 5 then begin
      InsertionSortInts(Cur, nCur);
      R^.Value := Cur[kk];
      Break;
    end;

    MedianOfMedians(Cur, P);
    SetLength(R^.Pivots, Length(R^.Pivots) + 1);
    R^.Pivots[High(R^.Pivots)] := P;

    nL := 0;
    nE := 0;
    nG := 0;
    for idx := 0 to nCur - 1 do begin
      if Cur[idx] < P then
        Inc(nL)
      else if Cur[idx] = P then
        Inc(nE)
      else
        Inc(nG);
    end;

    SetLength(L, nL);
    SetLength(G, nG);
    iL := 0;
    iG := 0;
    for idx := 0 to nCur - 1 do begin
      if Cur[idx] < P then begin
        L[iL] := Cur[idx];
        Inc(iL);
      end
      else if Cur[idx] > P then begin
        G[iG] := Cur[idx];
        Inc(iG);
      end;
    end;

    if kk < nL then begin
      Cur := L;
      L := nil;
    end
    else if kk < nL + nE then begin
      R^.Value := P;
      Break;
    end
    else begin
      kk := kk - nL - nE;
      Cur := G;
      G := nil;
    end;
  end;

  Result := R;
end;

procedure FreeSelectResult(var R: PSelectResult);
begin
  if R <> nil then begin
    R^.Pivots := nil;
    Dispose(R);
    R := nil;
  end;
end;

function MedianTwoSorted(A, B: PSortedSource; out Value: Double): Boolean;
var
  X, Y: PSortedSource;
  m, n, total, half, lo, hi, i, j: Int64;
  leftMax, rightMin, v: LongInt;
  hasLeft, hasRight: Boolean;
  dS: Double;
begin
  Value := 0.0;
  Result := False;
  if (A^.Len = 0) and (B^.Len = 0) then
    Exit;

  if A^.Len <= B^.Len then begin
    X := A;
    Y := B;
  end
  else begin
    X := B;
    Y := A;
  end;

  m := X^.Len;
  n := Y^.Len;
  total := m + n;
  half := (total + 1) div 2;

  lo := half - n;
  if lo < 0 then
    lo := 0;
  hi := m;
  if half < hi then
    hi := half;

  while lo < hi do begin
    i := (lo + hi) div 2;
    j := half - i;
    { i < hi <= m and i < half, so j >= 1 and j - 1 < n }
    if Y^.Get(Y, LongInt(j - 1)) > X^.Get(X, LongInt(i)) then
      lo := i + 1
    else
      hi := i;
  end;

  i := lo;
  j := half - i;

  hasLeft := False;
  leftMax := 0;
  if i > 0 then begin
    leftMax := X^.Get(X, LongInt(i - 1));
    hasLeft := True;
  end;
  if j > 0 then begin
    v := Y^.Get(Y, LongInt(j - 1));
    if (not hasLeft) or (v > leftMax) then
      leftMax := v;
    hasLeft := True;
  end;

  if total mod 2 = 1 then begin
    Value := leftMax;
    Result := True;
    Exit;
  end;

  hasRight := False;
  rightMin := 0;
  if i < m then begin
    rightMin := X^.Get(X, LongInt(i));
    hasRight := True;
  end;
  if j < n then begin
    v := Y^.Get(Y, LongInt(j));
    if (not hasRight) or (v < rightMin) then
      rightMin := v;
    hasRight := True;
  end;

  dS := Double(Int64(leftMax) + Int64(rightMin));
  Value := dS / 2;
  Result := True;
end;

end.
