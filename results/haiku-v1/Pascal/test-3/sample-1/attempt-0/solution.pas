unit palindrome_tree;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  EERTREE_ALPHA = 26;

type
  TEertreeNode = record
    Len: LongInt;
    SuffixLink: LongInt;
    Children: array[0..EERTREE_ALPHA - 1] of LongInt;
    Cnt: Int64;
    EndPos: LongInt;
  end;

  TEertreeNodeArray = array of TEertreeNode;

  PEertree = ^TEertree;
  TEertree = record
    Nodes: TEertreeNodeArray;
    Size: LongInt;
    Capacity: LongInt;
    Last: LongInt;
    Str: AnsiString;
    StrLen: LongInt;
  end;

function EertreeBuild(S: PChar; Len: LongInt): PEertree;
function EertreeCountDistinct(const T: PEertree): LongInt;
function EertreeCountOccurrences(const T: PEertree; Pattern: PChar; PLen: LongInt): Int64;
function EertreeLongestLength(const T: PEertree): LongInt;
procedure EertreeFree(var T: PEertree);

implementation

function EertreeCanExtend(S: PChar; Pos, NodeLen: LongInt): Boolean;
begin
  Result := (Pos - NodeLen - 1 >= 0) and (S[Pos - NodeLen - 1] = S[Pos]);
end;

function EertreeBuild(S: PChar; Len: LongInt): PEertree;
var
  T: PEertree;
  i, c, cur, w, v, link, child: LongInt;
  L, pos, tmp, k, maxIdx: LongInt;
  bucket, order: array of LongInt;
begin
  Result := nil;
  if Len < 0 then
    Exit;
  if (S = nil) and (Len > 0) then
    Exit;
  for i := 0 to Len - 1 do
    if (S[i] < 'a') or (S[i] > 'z') then
      Exit;

  New(T);
  T^.Nodes := nil;
  T^.Str := '';
  SetLength(T^.Nodes, Len + 2);
  FillChar(T^.Nodes[0], (Len + 2) * SizeOf(TEertreeNode), 0);

  T^.Nodes[0].Len := -1;
  T^.Nodes[0].SuffixLink := 0;
  T^.Nodes[1].Len := 0;
  T^.Nodes[1].SuffixLink := 0;

  T^.Size := 2;
  T^.Capacity := Len + 2;
  T^.Last := 1;
  T^.StrLen := Len;
  SetLength(T^.Str, Len);
  if Len > 0 then
    Move(S^, T^.Str[1], Len);

  for i := 0 to Len - 1 do
  begin
    c := Ord(S[i]) - Ord('a');
    cur := T^.Last;
    while not EertreeCanExtend(S, i, T^.Nodes[cur].Len) do
      cur := T^.Nodes[cur].SuffixLink;

    child := T^.Nodes[cur].Children[c];
    if child <> 0 then
      T^.Last := child
    else
    begin
      v := T^.Size;
      Inc(T^.Size);
      T^.Nodes[v].Len := T^.Nodes[cur].Len + 2;
      T^.Nodes[v].EndPos := i;
      T^.Nodes[v].Cnt := 0;
      FillChar(T^.Nodes[v].Children, SizeOf(T^.Nodes[v].Children), 0);

      if T^.Nodes[v].Len = 1 then
        link := 1
      else
      begin
        w := T^.Nodes[cur].SuffixLink;
        while not EertreeCanExtend(S, i, T^.Nodes[w].Len) do
          w := T^.Nodes[w].SuffixLink;
        link := T^.Nodes[w].Children[c];
      end;

      T^.Nodes[v].SuffixLink := link;
      T^.Nodes[cur].Children[c] := v;
      T^.Last := v;
    end;

    T^.Nodes[T^.Last].Cnt := T^.Nodes[T^.Last].Cnt + 1;
  end;

  // Propagate counts in decreasing order of Len (counting sort by Len)
  SetLength(bucket, Len + 2);
  FillChar(bucket[0], (Len + 2) * SizeOf(LongInt), 0);
  for v := 2 to T^.Size - 1 do
    Inc(bucket[T^.Nodes[v].Len]);

  pos := 0;
  for L := Len downto 0 do
  begin
    tmp := bucket[L];
    bucket[L] := pos;
    Inc(pos, tmp);
  end;

  SetLength(order, T^.Size);
  for v := 2 to T^.Size - 1 do
  begin
    maxIdx := T^.Nodes[v].Len;
    order[bucket[maxIdx]] := v;
    Inc(bucket[maxIdx]);
  end;

  for k := 0 to T^.Size - 3 do
  begin
    v := order[k];
    T^.Nodes[T^.Nodes[v].SuffixLink].Cnt :=
      T^.Nodes[T^.Nodes[v].SuffixLink].Cnt + T^.Nodes[v].Cnt;
  end;

  Result := T;
end;

function EertreeCountDistinct(const T: PEertree): LongInt;
begin
  if T = nil then
    Result := 0
  else
    Result := T^.Size - 2;
end;

function EertreeCountOccurrences(const T: PEertree; Pattern: PChar; PLen: LongInt): Int64;
var
  v, k, start: LongInt;
  match: Boolean;
begin
  Result := 0;
  if (T = nil) or (Pattern = nil) or (PLen <= 0) or (PLen > T^.StrLen) then
    Exit;

  for v := 2 to T^.Size - 1 do
  begin
    if T^.Nodes[v].Len = PLen then
    begin
      start := T^.Nodes[v].EndPos - PLen + 1;
      match := True;
      for k := 0 to PLen - 1 do
        if T^.Str[start + k + 1] <> Pattern[k] then
        begin
          match := False;
          Break;
        end;
      if match then
      begin
        Result := T^.Nodes[v].Cnt;
        Exit;
      end;
    end;
  end;
end;

function EertreeLongestLength(const T: PEertree): LongInt;
var
  v: LongInt;
begin
  Result := 0;
  if T = nil then
    Exit;
  for v := 2 to T^.Size - 1 do
    if T^.Nodes[v].Len > Result then
      Result := T^.Nodes[v].Len;
end;

procedure EertreeFree(var T: PEertree);
begin
  if T <> nil then
  begin
    T^.Nodes := nil;
    T^.Str := '';
    Dispose(T);
    T := nil;
  end;
end;

end.
