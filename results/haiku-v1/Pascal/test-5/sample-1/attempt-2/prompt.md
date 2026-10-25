Your previous Pascal implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

Build/load output:
fpc -Mobjfpc -Sh -O1 -g -Futest-5 -otest_runner test-5/tests.pas
Free Pascal Compiler version 3.2.2+dfsg-20 [2023/03/30] for x86_64
Copyright (c) 1993-2021 by Florian Klaempfl and others
Target OS: Linux for x86-64
Compiling test-5/tests.pas
Compiling test-5/expression.pas
expression.pas(308,3) Note: Local variable "Rest" is assigned but never used
tests.pas(20,19) Warning: function result variable of a managed type does not seem to be initialized
Linking test-5/test_runner
779 lines compiled, 0.4 sec
1 warning(s) issued
1 note(s) issued

Test output:
--- Algorithm A: Parsing & AST Construction ---
[PASS] Test A01 (Single Number)
[PASS] Test A02 (Binary + Precedence)
[PASS] Test A03 (Parentheses)
[PASS] Test A04 (Function Calls)
[FAIL] Test A05 (Nested + Unary)
[PASS] Test A06 (Dangling Operator)
[PASS] Test A07 (Empty String)
[PASS] Test A08 (Unbalanced Parens)
[PASS] Test A09 (Trailing Garbage)
[PASS] Test A10 (Bad Function Call)
--- Algorithm B: Evaluation & Error Semantics ---
[PASS] Test B01 (Operator Precedence)
[PASS] Test B02 (Parentheses Override)
[PASS] Test B03 (Power Right-Assoc)
[FAIL] Test B04 (Unary vs Power)
[PASS] Test B05 (Variables)
[PASS] Test B06 (Undefined Variable)
[PASS] Test B07 (Division & Modulo)
[FAIL] Test B08 (Built-in Functions)
[FAIL] Test B09 (Domain Error)
[PASS] Test B10 (Error Propagation)
Completed 20 tests.
Tests that failed (4):
 - Test A05 (Nested + Unary)
 - Test B04 (Unary vs Power)
 - Test B08 (Built-in Functions)
 - Test B09 (Domain Error)

Valgrind:
==14== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)

Failing tests:
- Test A05 (Nested + Unary)
- Test B04 (Unary vs Power)
- Test B08 (Built-in Functions)
- Test B09 (Domain Error)

Requirements for the fix:
1. Identify and resolve the core logical or memory issue causing the failure.
2. Ensure memory is managed safely.
3. Return ONLY the complete, raw, fixed Pascal code for `expression.pas`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.