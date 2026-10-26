{$mode objfpc}{$H+}

unit expression;

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

var
  GSrc: AnsiString;
  GPos: Integer;

function ParseExpr: PAstNode; forward;
function ParsePower: PAstNode; forward;
function ParseUnary: PAstNode; forward;

procedure SkipWhitespace;
begin
  while (GPos <= Length(GSrc)) and (GSrc[GPos] in [' ', #9, #10, #13]) do
    Inc(GPos);
end;

function PeekChar: AnsiChar;
begin
  SkipWhitespace;
  if GPos <= Length(GSrc) then
    Result := GSrc[GPos]
  else
    Result := #0;
end;

function NewNode(AKind: TAstNodeKind): PAstNode;
begin
  New(Result);
  Result^.Kind := AKind;
  Result^.NumValue := 0.0;
  Result^.StrValue := '';
  SetLength(Result^.Children, 0);
end;

function MakeBinary(const Op: AnsiString; L, R: PAstNode): PAstNode;
begin
  Result := NewNode(ankBinaryOp);
  Result^.StrValue := Op;
  SetLength(Result^.Children, 2);
  Result^.Children[0] := L;
  Result^.Children[1] := R;
end;

function MakeUnary(const Op: AnsiString; C: PAstNode): PAstNode;
begin
  Result := NewNode(ankUnaryOp);
  Result^.StrValue := Op;
  SetLength(Result^.Children, 1);
  Result^.Children[0] := C;
end;

procedure FreeAst(var Ast: PAstNode);
var
  i: Integer;
begin
  if Ast <> nil then begin
    for i := 0 to High(Ast^.Children) do
      FreeAst(Ast^.Children[i]);
    SetLength(Ast^.Children, 0);
    Dispose(Ast);
    Ast := nil;
  end;
end;

procedure FreeArgs(var Args: TAstNodeArray);
var
  i: Integer;
begin
  for i := 0 to High(Args) do
    FreeAst(Args[i]);
  SetLength(Args, 0);
end;

function FunctionArity(const AName: AnsiString): Integer;
begin
  if (AName = 'sqrt') or (AName = 'abs') or (AName = 'sin') or (AName = 'cos') then
    Result := 1
  else if (AName = 'min') or (AName = 'max') or (AName = 'pow') then
    Result := 2
  else
    Result := -1;
end;

function ParsePrimary: PAstNode;
var
  C: AnsiChar;
  Start, N, Expected: Integer;
  Name, S: AnsiString;
  Args: TAstNodeArray;
  E, Node: PAstNode;
  Ok: Boolean;
  Code: Integer;
begin
  Result := nil;
  C := PeekChar;

  if C in ['0'..'9'] then begin
    Start := GPos;
    while (GPos <= Length(GSrc)) and (GSrc[GPos] in ['0'..'9']) do
      Inc(GPos);
    if (GPos <= Length(GSrc)) and (GSrc[GPos] = '.') then begin
      Inc(GPos);
      if not ((GPos <= Length(GSrc)) and (GSrc[GPos] in ['0'..'9'])) then
        Exit;
      while (GPos <= Length(GSrc)) and (GSrc[GPos] in ['0'..'9']) do
        Inc(GPos);
    end;
    S := Copy(GSrc, Start, GPos - Start);
    Node := NewNode(ankNumber);
    Val(S, Node^.NumValue, Code);
    if Code <> 0 then begin
      FreeAst(Node);
      Exit;
    end;
    Result := Node;
    Exit;
  end;

  if C in ['A'..'Z', 'a'..'z', '_'] then begin
    Start := GPos;
    while (GPos <= Length(GSrc)) and
          (GSrc[GPos] in ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
      Inc(GPos);
    Name := Copy(GSrc, Start, GPos - Start);

    if PeekChar = '(' then begin
      Expected := FunctionArity(Name);
      if Expected < 0 then
        Exit;
      Inc(GPos);
      SetLength(Args, 0);
      Ok := True;
      repeat
        E := ParseExpr;
        if E = nil then begin
          Ok := False;
          Break;
        end;
        N := Length(Args);
        SetLength(Args, N + 1);
        Args[N] := E;
        if PeekChar <> ',' then
          Break;
        Inc(GPos);
      until False;
      if not Ok then begin
        FreeArgs(Args);
        Exit;
      end;
      if PeekChar <> ')' then begin
        FreeArgs(Args);
        Exit;
      end;
      Inc(GPos);
      if Length(Args) <> Expected then begin
        FreeArgs(Args);
        Exit;
      end;
      Node := NewNode(ankFunction);
      Node^.StrValue := Name;
      Node^.Children := Args;
      Args := nil;
      Result := Node;
    end
    else begin
      Node := NewNode(ankVariable);
      Node^.StrValue := Name;
      Result := Node;
    end;
    Exit;
  end;

  if C = '(' then begin
    Inc(GPos);
    E := ParseExpr;
    if E = nil then
      Exit;
    if PeekChar <> ')' then begin
      FreeAst(E);
      Exit;
    end;
    Inc(GPos);
    Result := E;
  end;
end;

function ParsePower: PAstNode;
var
  Base, Expo: PAstNode;
begin
  Result := nil;
  Base := ParsePrimary;
  if Base = nil then
    Exit;
  if PeekChar = '^' then begin
    Inc(GPos);
    Expo := ParseUnary;
    if Expo = nil then begin
      FreeAst(Base);
      Exit;
    end;
    Result := MakeBinary('^', Base, Expo);
  end
  else
    Result := Base;
end;

function ParseUnary: PAstNode;
var
  Op: AnsiChar;
  Operand: PAstNode;
  C: AnsiChar;
begin
  Result := nil;
  C := PeekChar;
  if (C = '+') or (C = '-') then begin
    Op := C;
    Inc(GPos);
    Operand := ParseUnary;
    if Operand = nil then
      Exit;
    Result := MakeUnary(Op, Operand);
  end
  else
    Result := ParsePower;
end;

function ParseTerm: PAstNode;
var
  Left, Right: PAstNode;
  Op, C: AnsiChar;
begin
  Result := nil;
  Left := ParseUnary;
  if Left = nil then
    Exit;
  C := PeekChar;
  while (C = '*') or (C = '/') or (C = '%') do begin
    Op := C;
    Inc(GPos);
    Right := ParseUnary;
    if Right = nil then begin
      FreeAst(Left);
      Exit;
    end;
    Left := MakeBinary(Op, Left, Right);
    C := PeekChar;
  end;
  Result := Left;
end;

function ParseExpr: PAstNode;
var
  Left, Right: PAstNode;
  Op, C: AnsiChar;
begin
  Result := nil;
  Left := ParseTerm;
  if Left = nil then
    Exit;
  C := PeekChar;
  while (C = '+') or (C = '-') do begin
    Op := C;
    Inc(GPos);
    Right := ParseTerm;
    if Right = nil then begin
      FreeAst(Left);
      Exit;
    end;
    Left := MakeBinary(Op, Left, Right);
    C := PeekChar;
  end;
  Result := Left;
end;

function ParseExpression(const Expr: AnsiString): PAstNode;
var
  Root: PAstNode;
begin
  GSrc := Expr;
  GPos := 1;
  Root := ParseExpr;
  if Root <> nil then begin
    SkipWhitespace;
    if GPos <= Length(GSrc) then
      FreeAst(Root);
  end;
  Result := Root;
end;

function IsFiniteValue(V: Double): Boolean;
begin
  Result := not (IsNan(V) or IsInfinite(V));
end;

function FindVar(const Vars: TVariableArray; const AName: AnsiString;
  out Value: Double): Boolean;
var
  i: Integer;
begin
  Result := False;
  Value := 0.0;
  for i := 0 to High(Vars) do
    if Vars[i].Name = AName then begin
      Value := Vars[i].Value;
      Result := True;
      Exit;
    end;
end;

function PowerChecked(X, Y: Double): TEvalResult;
var
  Res, Acc, B: Double;
  N: Int64;
begin
  Result.Status := esOk;
  Result.Value := 0.0;
  Res := 0.0;

  if Y = 0.0 then
    Res := 1.0
  else if X = 0.0 then begin
    if Y < 0.0 then begin
      Result.Status := esDomainError;
      Exit;
    end;
    Res := 0.0;
  end
  else if (Int(Y) = Y) and (Abs(Y) <= 1.0e9) then begin
    N := Trunc(Abs(Y));
    B := X;
    Acc := 1.0;
    while N > 0 do begin
      if (N and 1) = 1 then
        Acc := Acc * B;
      B := B * B;
      N := N shr 1;
    end;
    if Y < 0.0 then
      Res := 1.0 / Acc
    else
      Res := Acc;
  end
  else if X < 0.0 then begin
    Result.Status := esDomainError;
    Exit;
  end
  else
    Res := Exp(Y * Ln(X));

  if not IsFiniteValue(Res) then
    Result.Status := esDomainError
  else
    Result.Value := Res;
end;

function ApplyBinary(const Op: AnsiString; X, Y: Double): TEvalResult;
begin
  Result.Status := esOk;
  Result.Value := 0.0;
  if Op = '+' then
    Result.Value := X + Y
  else if Op = '-' then
    Result.Value := X - Y
  else if Op = '*' then
    Result.Value := X * Y
  else if Op = '/' then begin
    if Y = 0.0 then
      Result.Status := esDivByZero
    else
      Result.Value := X / Y;
  end
  else if Op = '%' then begin
    if Y = 0.0 then
      Result.Status := esDivByZero
    else
      Result.Value := X - Y * Int(X / Y);
  end
  else if Op = '^' then
    Result := PowerChecked(X, Y)
  else
    Result.Status := esInvalidOp;
end;

function Evaluate(Ast: PAstNode; const Vars: TVariableArray): TEvalResult;
var
  L, R: TEvalResult;
  Name: AnsiString;
begin
  Result.Status := esOk;
  Result.Value := 0.0;

  if Ast = nil then begin
    Result.Status := esInvalidOp;
    Exit;
  end;

  case Ast^.Kind of
    ankNumber:
      Result.Value := Ast^.NumValue;

    ankVariable:
      if not FindVar(Vars, Ast^.StrValue, Result.Value) then
        Result.Status := esUndefinedVar;

    ankUnaryOp: begin
      L := Evaluate(Ast^.Children[0], Vars);
      if L.Status <> esOk then begin
        Result := L;
        Exit;
      end;
      if Ast^.StrValue = '-' then
        Result.Value := -L.Value
      else
        Result.Value := L.Value;
    end;

    ankBinaryOp: begin
      L := Evaluate(Ast^.Children[0], Vars);
      if L.Status <> esOk then begin
        Result := L;
        Exit;
      end;
      R := Evaluate(Ast^.Children[1], Vars);
      if R.Status <> esOk then begin
        Result := R;
        Exit;
      end;
      Result := ApplyBinary(Ast^.StrValue, L.Value, R.Value);
    end;

    ankFunction: begin
      Name := Ast^.StrValue;
      L := Evaluate(Ast^.Children[0], Vars);
      if L.Status <> esOk then begin
        Result := L;
        Exit;
      end;
      R.Status := esOk;
      R.Value := 0.0;
      if Length(Ast^.Children) = 2 then begin
        R := Evaluate(Ast^.Children[1], Vars);
        if R.Status <> esOk then begin
          Result := R;
          Exit;
        end;
      end;

      if Name = 'sqrt' then begin
        if L.Value < 0.0 then
          Result.Status := esDomainError
        else
          Result.Value := Sqrt(L.Value);
      end
      else if Name = 'abs' then
        Result.Value := Abs(L.Value)
      else if Name = 'sin' then
        Result.Value := Sin(L.Value)
      else if Name = 'cos' then
        Result.Value := Cos(L.Value)
      else if Name = 'min' then
        Result.Value := Min(L.Value, R.Value)
      else if Name = 'max' then
        Result.Value := Max(L.Value, R.Value)
      else if Name = 'pow' then
        Result := PowerChecked(L.Value, R.Value)
      else
        Result.Status := esInvalidOp;
    end;

  else
    Result.Status := esInvalidOp;
  end;
end;

end.
