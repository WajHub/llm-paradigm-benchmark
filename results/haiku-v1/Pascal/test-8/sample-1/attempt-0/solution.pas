unit tsp_approx;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TIntArray = array of LongInt;

  { A point; vertex i is Pts[i] (0-based, input order). }
  TTspPoint = record
    X, Y: LongInt;
  end;

  TTspPointArray = array of TTspPoint;

  { A closed tour: Tour is a permutation of 0..n-1 starting with 0,
    Cost includes the edge from the last vertex back to Tour[0]. }
  PTourResult = ^TTourResult;
  TTourResult = record
    Tour: TIntArray;
    Cost: LongInt;
  end;

function TspMstWeight(const Pts: TTspPointArray): LongInt;
function TspDoubleTree(const Pts: TTspPointArray): PTourResult;
function TspMatchingWeight(const Pts: TTspPointArray): LongInt;
function TspChristofides(const Pts: TTspPointArray): PTourResult;
procedure FreeTourResult(var R: PTourResult);

implementation

const
  BigVal = 1000000000;

function Dist(const P, Q: TTspPoint): LongInt;
begin
  Dist := Abs(P.X - Q.X) + Abs(P.Y - Q.Y);
end;

{ Prim's algorithm from vertex 0 with the prescribed tie-breaking.
  par[v] is the parent of v (par[0] = -1). total receives the MST weight. }
procedure PrimMst(const Pts: TTspPointArray; var par: TIntArray; var total: LongInt);
var
  n, v, step, best, d: LongInt;
  key: TIntArray;
  intree: array of Boolean;
begin
  n := Length(Pts);
  SetLength(par, n);
  SetLength(key, n);
  SetLength(intree, n);
  total := 0;
  for v := 0 to n - 1 do begin
    intree[v] := False;
    key[v] := BigVal;
    par[v] := -1;
  end;
  if n = 0 then
    Exit;
  intree[0] := True;
  for v := 1 to n - 1 do begin
    key[v] := Dist(Pts[0], Pts[v]);
    par[v] := 0;
  end;
  for step := 1 to n - 1 do begin
    best := -1;
    for v := 0 to n - 1 do
      if (not intree[v]) and ((best < 0) or (key[v] < key[best])) then
        best := v;
    intree[best] := True;
    total := total + key[best];
    for v := 0 to n - 1 do
      if not intree[v] then begin
        d := Dist(Pts[best], Pts[v]);
        if (d < key[v]) or ((d = key[v]) and (best < par[v])) then begin
          key[v] := d;
          par[v] := best;
        end;
      end;
  end;
end;

{ Exact minimum-weight perfect matching on the vertex list odd (even length).
  Returns the matched pairs in pu/pv (cnt pairs) and the total cost. }
procedure MinMatching(const Pts: TTspPointArray; const odd: TIntArray;
  var pu, pv: TIntArray; var cnt: LongInt; var cost: LongInt);
var
  m, full, mask, i, j, nb, nc, code: LongInt;
  dp, pick: TIntArray;
begin
  m := Length(odd);
  cnt := 0;
  cost := 0;
  SetLength(pu, 0);
  SetLength(pv, 0);
  if m = 0 then
    Exit;
  full := (1 shl m) - 1;
  SetLength(dp, full + 1);
  SetLength(pick, full + 1);
  for mask := 0 to full do
    dp[mask] := BigVal;
  dp[0] := 0;
  for mask := 0 to full - 1 do
    if dp[mask] < BigVal then begin
      i := 0;
      while ((mask shr i) and 1) = 1 do
        Inc(i);
      for j := i + 1 to m - 1 do
        if ((mask shr j) and 1) = 0 then begin
          nb := mask or (1 shl i) or (1 shl j);
          nc := dp[mask] + Dist(Pts[odd[i]], Pts[odd[j]]);
          if nc < dp[nb] then begin
            dp[nb] := nc;
            pick[nb] := i * 64 + j;
          end;
        end;
    end;
  cost := dp[full];
  SetLength(pu, m div 2);
  SetLength(pv, m div 2);
  mask := full;
  while mask <> 0 do begin
    code := pick[mask];
    i := code div 64;
    j := code mod 64;
    pu[cnt] := odd[i];
    pv[cnt] := odd[j];
    Inc(cnt);
    mask := mask xor (1 shl i) xor (1 shl j);
  end;
end;

{ Preorder DFS of the rooted tree given by par; children in ascending index order. }
procedure Preorder(u: LongInt; const par: TIntArray; var tr: TIntArray; var pos: LongInt);
var
  v: LongInt;
begin
  tr[pos] := u;
  Inc(pos);
  for v := 1 to High(par) do
    if par[v] = u then
      Preorder(v, par, tr, pos);
end;

function TourCost(const tr: TIntArray; const Pts: TTspPointArray): LongInt;
var
  i, n, s: LongInt;
begin
  n := Length(tr);
  s := 0;
  if n <= 1 then begin
    TourCost := 0;
    Exit;
  end;
  for i := 0 to n - 1 do
    s := s + Dist(Pts[tr[i]], Pts[tr[(i + 1) mod n]]);
  TourCost := s;
end;

function TspMstWeight(const Pts: TTspPointArray): LongInt;
var
  par: TIntArray;
  total: LongInt;
begin
  if Length(Pts) <= 1 then begin
    TspMstWeight := 0;
    Exit;
  end;
  PrimMst(Pts, par, total);
  TspMstWeight := total;
end;

function TspDoubleTree(const Pts: TTspPointArray): PTourResult;
var
  n: LongInt;
  par, tr: TIntArray;
  total, pos: LongInt;
  res: PTourResult;
begin
  n := Length(Pts);
  if n = 0 then begin
    TspDoubleTree := nil;
    Exit;
  end;
  PrimMst(Pts, par, total);
  SetLength(tr, n);
  pos := 0;
  Preorder(0, par, tr, pos);
  New(res);
  res^.Tour := tr;
  res^.Cost := TourCost(tr, Pts);
  TspDoubleTree := res;
end;

function TspMatchingWeight(const Pts: TTspPointArray): LongInt;
var
  n, v, k, mstw, mc, cnt: LongInt;
  par, deg, odd, pu, pv: TIntArray;
begin
  n := Length(Pts);
  if n <= 1 then begin
    TspMatchingWeight := 0;
    Exit;
  end;
  PrimMst(Pts, par, mstw);
  SetLength(deg, n);
  for v := 0 to n - 1 do
    deg[v] := 0;
  for v := 1 to n - 1 do begin
    Inc(deg[v]);
    Inc(deg[par[v]]);
  end;
  SetLength(odd, n);
  k := 0;
  for v := 0 to n - 1 do
    if (deg[v] and 1) = 1 then begin
      odd[k] := v;
      Inc(k);
    end;
  SetLength(odd, k);
  MinMatching(Pts, odd, pu, pv, cnt, mc);
  TspMatchingWeight := mc;
end;

function TspChristofides(const Pts: TTspPointArray): PTourResult;
var
  n, v, k, mstw, mc, cnt, E, sp, cl, cur, found, tl, i, pos: LongInt;
  par, deg, odd, pu, pv, stk, circ, tr, adj: TIntArray;
  vis: array of Boolean;
  res: PTourResult;
begin
  n := Length(Pts);
  if n = 0 then begin
    TspChristofides := nil;
    Exit;
  end;
  New(res);
  if n = 1 then begin
    SetLength(res^.Tour, 1);
    res^.Tour[0] := 0;
    res^.Cost := 0;
    TspChristofides := res;
    Exit;
  end;

  PrimMst(Pts, par, mstw);
  SetLength(deg, n);
  for v := 0 to n - 1 do
    deg[v] := 0;
  for v := 1 to n - 1 do begin
    Inc(deg[v]);
    Inc(deg[par[v]]);
  end;
  SetLength(odd, n);
  k := 0;
  for v := 0 to n - 1 do
    if (deg[v] and 1) = 1 then begin
      odd[k] := v;
      Inc(k);
    end;
  SetLength(odd, k);
  MinMatching(Pts, odd, pu, pv, cnt, mc);

  { multigraph as multiplicity matrix }
  SetLength(adj, n * n);
  for i := 0 to n * n - 1 do
    adj[i] := 0;
  for v := 1 to n - 1 do begin
    Inc(adj[v * n + par[v]]);
    Inc(adj[par[v] * n + v]);
  end;
  for i := 0 to cnt - 1 do begin
    Inc(adj[pu[i] * n + pv[i]]);
    Inc(adj[pv[i] * n + pu[i]]);
  end;

  { Hierholzer from vertex 0 }
  E := (n - 1) + cnt;
  SetLength(stk, E + 2);
  SetLength(circ, E + 2);
  stk[0] := 0;
  sp := 1;
  cl := 0;
  while sp > 0 do begin
    cur := stk[sp - 1];
    found := -1;
    v := 0;
    while (v < n) and (found < 0) do begin
      if adj[cur * n + v] > 0 then
        found := v;
      Inc(v);
    end;
    if found >= 0 then begin
      Dec(adj[cur * n + found]);
      Dec(adj[found * n + cur]);
      stk[sp] := found;
      Inc(sp);
    end
    else begin
      circ[cl] := cur;
      Inc(cl);
      Dec(sp);
    end;
  end;

  { shortcut: keep first occurrence of each vertex }
  SetLength(vis, n);
  for v := 0 to n - 1 do
    vis[v] := False;
  SetLength(tr, n);
  tl := 0;
  for i := 0 to cl - 1 do
    if not vis[circ[i]] then begin
      vis[circ[i]] := True;
      tr[tl] := circ[i];
      Inc(tl);
    end;
  pos := tl;
  SetLength(tr, n);
  if pos < n then
    for v := 0 to n - 1 do
      if not vis[v] then begin
        tr[pos] := v;
        Inc(pos);
      end;

  res^.Tour := tr;
  res^.Cost := TourCost(tr, Pts);
  TspChristofides := res;
end;

procedure FreeTourResult(var R: PTourResult);
begin
  if R <> nil then begin
    R^.Tour := nil;
    Dispose(R);
    R := nil;
  end;
end;

end.
