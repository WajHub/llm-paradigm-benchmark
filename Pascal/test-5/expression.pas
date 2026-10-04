unit expression;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  TAstNodeKind = (ankNumber, ankVariable, ankBinaryOp, ankUnaryOp, ankFunction);

  PAstNode = ^TAstNode;
  TAstNodeArray = array of PAstNode;

  TAstNode = record
    Kind: TAstNodeKind;
    NumValue: Double;
    StrValue: AnsiString;
    Children: TAstNodeArray;
  end;

  TVariable = record
    Name: AnsiString;
    Value: Double;
  end;

  TVariableArray = array of TVariable;

  TEvalStatus = (esOk, esDivByZero, esUndefinedVar, esInvalidOp, esDomainError);

  TEvalResult = record
    Status: TEvalStatus;
    Value: Double;
  end;

function ParseExpression(const Expr: AnsiString): PAstNode;
function Evaluate(Ast: PAstNode; const Vars: TVariableArray): TEvalResult;
procedure FreeAst(var Ast: PAstNode);

implementation

function ParseExpression(const Expr: AnsiString): PAstNode;
begin
  raise Exception.Create('ParseExpression not implemented');
  Result := nil;
end;

function Evaluate(Ast: PAstNode; const Vars: TVariableArray): TEvalResult;
begin
  raise Exception.Create('Evaluate not implemented');
  Result.Status := esInvalidOp;
  Result.Value := 0.0;
end;

procedure FreeAst(var Ast: PAstNode);
begin
  if Ast <> nil then begin
    Dispose(Ast);
    Ast := nil;
  end;
end;

end.
