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

function AlignmentScore(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): LongInt;
begin
  raise Exception.Create('AlignmentScore not implemented');
  Result := -1;
end;

function AlignmentAlign(const A, B: AnsiString; MatchScore, MismatchPenalty,
  GapOpen, GapExtend: LongInt): PAlignmentResult;
begin
  raise Exception.Create('AlignmentAlign not implemented');
  Result := nil;
end;

procedure FreeAlignmentResult(var R: PAlignmentResult);
begin
  if R <> nil then begin
    Dispose(R);
    R := nil;
  end;
end;

end.
