You are a Pascal programming expert. Your task is to implement the required functions in accordance with the provided unit interface.

Implement a Palindrome Tree (also known as Eertree) data structure in Pascal (Free
Pascal, {$mode objfpc}) using the unit palindrome_tree. The Eertree is a linear-time
data structure that implicitly represents all distinct palindromic substrings of a
string. It was introduced by Mikhail Rubinchik and Arseny M. Shur in 2014.

- Implement `EertreeBuild(S: PChar; Len: LongInt): PEertree`: Build the palindrome tree
  for a given string of length `Len` in O(n) time. The tree must include two imaginary
  root nodes at indices 0 and 1: root 0 has Len = -1 (the "odd root"), root 1 has Len = 0
  (the "even root"). After building, propagate occurrence counts from longer palindromes
  to shorter ones by traversing nodes in decreasing order of `Len` and adding each node's
  `Cnt` to its `SuffixLink`'s `Cnt`. The final `Cnt` of each node must equal the total
  number of times that palindrome appears as a substring in the input.

- Implement `EertreeCountDistinct(const T: PEertree): LongInt`: Return the number of
  distinct palindromic substrings (i.e., the number of real nodes, excluding the two
  imaginary roots).

- Implement `EertreeCountOccurrences(const T: PEertree; Pattern: PChar; PLen: LongInt):
  Int64`: Find the node in the tree whose palindrome matches `Pattern` (using `EndPos` to
  locate the substring in the stored string) and return its propagated `Cnt`. Return 0 if
  the pattern is not found, not a palindrome, or any argument is nil.

- Implement `EertreeLongestLength(const T: PEertree): LongInt`: Return the maximum `Len`
  among all real nodes.

- Implement `EertreeFree(var T: PEertree)`: Free all dynamically allocated memory and set
  T to nil. Must not leak memory (verified by valgrind).

Constraints:
  - Input strings contain only lowercase Latin letters ('a'..'z').
  - `EertreeBuild(nil, n)` with n > 0 must return nil.
  - `EertreeBuild(PChar(''), 0)` must return a valid Eertree with only the two imaginary
    roots.
  - All query functions must return 0 on nil input without raising.
  - Keep the contract (type declarations and signatures) in the `interface` section of
    `palindrome_tree.pas`.

General Requirements:
- Use idiomatic procedural Pascal.
- Manage dynamically allocated structures safely.
- Return ONLY raw Pascal code (no Markdown tags, no side text).
- Do not provide test runner code.

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