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

function EertreeBuild(S: PChar; Len: LongInt): PEertree;
begin
  raise Exception.Create('EertreeBuild not implemented');
  Result := nil;
end;

function EertreeCountDistinct(const T: PEertree): LongInt;
begin
  raise Exception.Create('EertreeCountDistinct not implemented');
  Result := 0;
end;

function EertreeCountOccurrences(const T: PEertree; Pattern: PChar; PLen: LongInt): Int64;
begin
  raise Exception.Create('EertreeCountOccurrences not implemented');
  Result := 0;
end;

function EertreeLongestLength(const T: PEertree): LongInt;
begin
  raise Exception.Create('EertreeLongestLength not implemented');
  Result := 0;
end;

procedure EertreeFree(var T: PEertree);
begin
  if T <> nil then
  begin
    Dispose(T);
    T := nil;
  end;
end;

end.
