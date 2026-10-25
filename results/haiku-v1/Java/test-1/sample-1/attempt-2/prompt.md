Your previous Java implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

javac -g -d test-1 test-1/SpatialLogicImpl.java test-1/SpatialLogic.java test-1/Tests.java
test-1/SpatialLogicImpl.java:1: error: class, interface, enum, or record expected
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                  ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                             ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                        ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                             ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                                                                                                              ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                                                                                                                   ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                                                                                                                                      ^
test-1/SpatialLogicImpl.java:1: error: illegal character: '`'
The failure is in `calculateCleanMinkowskiSum`. When either argument is `null`, the method returned an empty polygon instead of signalling invalid input with `null`. The fix returns `null` for null arguments and keeps returning an empty polygon for valid but empty inputs, which test A06 and A07 already pass.
                                                                                                                                                                                           ^
9 errors
make: *** [Makefile:10: test] Error 1

Failing tests: all (no test results were produced, see above).

Requirements for the fix:
1. Identify and resolve the core logical or resource-management issue causing the failure.
2. Ensure resources are handled safely.
3. Return ONLY the complete, raw, fixed Java code for `SpatialLogicImpl.java`.
4. Do NOT include Markdown formatting, do NOT include ```java blocks, and do NOT write any explanations. Just the code.