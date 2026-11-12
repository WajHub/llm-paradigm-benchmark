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

function BTreeInsertAll(MinDegree: LongInt; const Keys: TIntArray): PBTreeNode;
begin
  raise Exception.Create('BTreeInsertAll not implemented');
  Result := nil;
end;

function BTreeDeleteAll(MinDegree: LongInt; const Keys, Deletions: TIntArray): PBTreeNode;
begin
  raise Exception.Create('BTreeDeleteAll not implemented');
  Result := nil;
end;

procedure FreeBTree(var Root: PBTreeNode);
begin
  if Root <> nil then begin
    Dispose(Root);
    Root := nil;
  end;
end;

end.
