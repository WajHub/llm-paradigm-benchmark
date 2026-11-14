unit sequence_alignment;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  { One optimal global alignment. AlignedA / AlignedB have equal length and use '-'
    as the gap character. Allocated by AlignmentAlign, freed with FreeAlignmentResult. }
  PAlignmentResult = ^TAlignmentResult;
  TAlignmentResult = record
    Score: LongInt;
    AlignedA: AnsiString;
    AlignedB: AnsiString;
  end;

function AlignmentScore(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): LongInt;
function AlignmentAlign(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): PAlignmentResult;
procedure FreeAlignmentResult(var R: PAlignmentResult);

implementation

type
  TDPTable = array of array of LongInt;

const
  NegInf: LongInt = -500000000;

function Max3(x, y, z: LongInt): LongInt;
begin
  Result := x;
  if y > Result then
    Result := y;
  if z > Result then
    Result := z;
end;

{ MM: best score ending with a letter/letter column.
  XX: best score ending with A-letter over a gap (gap in B).
  YY: best score ending with a gap over B-letter (gap in A). }
procedure FillTables(const SeqA, SeqB: AnsiString; Match, Mismatch, GOpen,
  GExt: LongInt; var MM, XX, YY: TDPTable);
var
  n, m, i, j, s, openExt: LongInt;
begin
  n := Length(SeqA);
  m := Length(SeqB);
  SetLength(MM, n + 1, m + 1);
  SetLength(XX, n + 1, m + 1);
  SetLength(YY, n + 1, m + 1);
  for i := 0 to n do
    for j := 0 to m do begin
      MM[i, j] := NegInf;
      XX[i, j] := NegInf;
      YY[i, j] := NegInf;
    end;
  MM[0, 0] := 0;
  for i := 1 to n do
    XX[i, 0] := -(GOpen + i * GExt);
  for j := 1 to m do
    YY[0, j] := -(GOpen + j * GExt);
  openExt := GOpen + GExt;
  for i := 1 to n do
    for j := 1 to m do begin
      if SeqA[i] = SeqB[j] then
        s := Match
      else
        s := -Mismatch;
      MM[i, j] := Max3(MM[i - 1, j - 1], XX[i - 1, j - 1], YY[i - 1, j - 1]) + s;
      XX[i, j] := Max3(MM[i - 1, j] - openExt, XX[i - 1, j] - GExt,
        YY[i - 1, j] - openExt);
      YY[i, j] := Max3(MM[i, j - 1] - openExt, YY[i, j - 1] - GExt,
        XX[i, j - 1] - openExt);
    end;
end;

function AlignmentScore(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): LongInt;
var
  MM, XX, YY: TDPTable;
  n, m: LongInt;
begin
  n := Length(A);
  m := Length(B);
  FillTables(A, B, MatchScore, MismatchPenalty, GapOpen, GapExtend, MM, XX, YY);
  Result := Max3(MM[n, m], XX[n, m], YY[n, m]);
end;

function AlignmentAlign(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): PAlignmentResult;
var
  MM, XX, YY: TDPTable;
  n, m, i, j, s, pos, st, best, openExt: LongInt;
  ra, rb: AnsiString;
  R: PAlignmentResult;
  v: LongInt;
begin
  n := Length(A);
  m := Length(B);
  openExt := GapOpen + GapExtend;
  FillTables(A, B, MatchScore, MismatchPenalty, GapOpen, GapExtend, MM, XX, YY);

  st := 0;
  best := MM[n, m];
  if XX[n, m] > best then begin
    best := XX[n, m];
    st := 1;
  end;
  if YY[n, m] > best then begin
    best := YY[n, m];
    st := 2;
  end;

  SetLength(ra, n + m);
  SetLength(rb, n + m);
  pos := n + m + 1;
  i := n;
  j := m;
  while (i > 0) or (j > 0) do begin
    case st of
      0:
        begin
          if A[i] = B[j] then
            s := MatchScore
          else
            s := -MismatchPenalty;
          v := MM[i, j] - s;
          Dec(pos);
          ra[pos] := A[i];
          rb[pos] := B[j];
          if MM[i - 1, j - 1] = v then
            st := 0
          else if XX[i - 1, j - 1] = v then
            st := 1
          else
            st := 2;
          Dec(i);
          Dec(j);
        end;
      1:
        begin
          v := XX[i, j];
          Dec(pos);
          ra[pos] := A[i];
          rb[pos] := '-';
          if XX[i - 1, j] - GapExtend = v then
            st := 1
          else if MM[i - 1, j] - openExt = v then
            st := 0
          else
            st := 2;
          Dec(i);
        end;
      2:
        begin
          v := YY[i, j];
          Dec(pos);
          ra[pos] := '-';
          rb[pos] := B[j];
          if YY[i, j - 1] - GapExtend = v then
            st := 2
          else if MM[i, j - 1] - openExt = v then
            st := 0
          else
            st := 1;
          Dec(j);
        end;
    end;
  end;

  New(R);
  R^.Score := best;
  R^.AlignedA := Copy(ra, pos, n + m + 1 - pos);
  R^.AlignedB := Copy(rb, pos, n + m + 1 - pos);
  Result := R;
end;

procedure FreeAlignmentResult(var R: PAlignmentResult);
begin
  if R <> nil then begin
    Dispose(R);
    R := nil;
  end;
end;

end.
