Your previous Prolog implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

Build/load output:
cd test-2 && swipl -q -g halt -s tests.pl

Test output:
--- Algorithm A: Shortest Distances ---
[PASS] Test A01 (Linear Chain)
[PASS] Test A02 (Diamond)
[PASS] Test A03 (Disconnected)
[PASS] Test A04 (Single Vertex)
[PASS] Test A05 (Parallel Edges)
[PASS] Test A06 (Zero-Weight Edges)
[PASS] Test A07 (Null Graph)
[PASS] Test A08 (Invalid Source)
[PASS] Test A09 (Complex Graph)
[FAIL] Test A10 (Stress 1000-Chain)
--- Algorithm B: Path Reconstruction ---
[PASS] Test B01 (Simple Path)
[PASS] Test B02 (Diamond Path)
[PASS] Test B03 (Self Path)
[PASS] Test B04 (Unreachable)
[FAIL] Test B05 (Long Chain)
[PASS] Test B06 (Cycle)
[PASS] Test B07 (Star)
[PASS] Test B08 (Null Result)
[PASS] Test B09 (Bidirectional)
[FAIL] Test B10 (Stress Path 1000-Chain)
Completed 20 tests.
Passed: 17
Failed: 3
Tests that failed:
 - Test A10 (Stress 1000-Chain)
 - Test B05 (Long Chain)
 - Test B10 (Stress Path 1000-Chain)

Valgrind:
==13==    definitely lost: 67,480 bytes in 20 blocks
==13==    indirectly lost: 0 bytes in 0 blocks
==13==      possibly lost: 115,708 bytes in 1,073 blocks
==13== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)

Failing tests:
- Test A10 (Stress 1000-Chain)
- Test B05 (Long Chain)
- Test B10 (Stress Path 1000-Chain)

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Prolog.
3. Return ONLY the complete, raw, fixed Prolog code for `shortest_path.pl`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.