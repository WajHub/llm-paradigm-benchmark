Your previous Prolog implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

Build/load output:
cd test-9 && swipl -q -g halt -s tests.pl

Test output:
--- Algorithm A: Insertion ---
[PASS] Test A01 (Empty)
[PASS] Test A02 (Invalid Degree)
[PASS] Test A03 (Single Leaf)
[PASS] Test A04 (Root Split)
[PASS] Test A05 (Duplicate On Full Root)
[PASS] Test A06 (Ascending)
[PASS] Test A07 (Proactive Split)
[PASS] Test A08 (Textbook t3)
[PASS] Test A09 (Invariants)
[PASS] Test A10 (Stress)
--- Algorithm B: Deletion ---
[PASS] Test B01 (Delete From Leaf)
[PASS] Test B02 (Absent Key Unchanged)
[FAIL] Test B03 (Delete All)
[PASS] Test B04 (Predecessor Preferred)
[PASS] Test B05 (Successor)
[PASS] Test B06 (Merge Children)
[PASS] Test B07 (Borrow Left First)
[FAIL] Test B08 (Merge Right First)
[FAIL] Test B09 (Root Shrink)
[FAIL] Test B10 (Stress Invariants)
Completed 20 tests.
Passed: 16
Failed: 4
Tests that failed:
 - Test B03 (Delete All)
 - Test B08 (Merge Right First)
 - Test B09 (Root Shrink)
 - Test B10 (Stress Invariants)

Valgrind:
==13==    definitely lost: 1,752 bytes in 12 blocks
==13==    indirectly lost: 0 bytes in 0 blocks
==13==      possibly lost: 589,480 bytes in 5,493 blocks
==13== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)

Failing tests:
- Test B03 (Delete All)
- Test B08 (Merge Right First)
- Test B09 (Root Shrink)
- Test B10 (Stress Invariants)

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Prolog.
3. Return ONLY the complete, raw, fixed Prolog code for `btree.pl`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.