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

function TspMstWeight(const Pts: TTspPointArray): LongInt;
begin
  raise Exception.Create('TspMstWeight not implemented');
  Result := -1;
end;

function TspDoubleTree(const Pts: TTspPointArray): PTourResult;
begin
  raise Exception.Create('TspDoubleTree not implemented');
  Result := nil;
end;

function TspMatchingWeight(const Pts: TTspPointArray): LongInt;
begin
  raise Exception.Create('TspMatchingWeight not implemented');
  Result := -1;
end;

function TspChristofides(const Pts: TTspPointArray): PTourResult;
begin
  raise Exception.Create('TspChristofides not implemented');
  Result := nil;
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
