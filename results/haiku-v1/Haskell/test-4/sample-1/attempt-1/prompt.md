Your previous Haskell implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

ghc -Wall -Wextra -g -itest-4 -o test_runner test-4/Tests.hs
[1 of 2] Compiling Knapsack         ( test-4/Knapsack.hs, test-4/Knapsack.o )

test-4/Knapsack.hs:66:1: error: parse error on input `</'
   |
66 | </br>
   | ^^
make: *** [Makefile:7: test] Error 1

Failing tests: all (no test results were produced, see above).

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Haskell.
3. Return ONLY the complete, raw, fixed Haskell code for `Knapsack.hs`.
4. Do NOT include Markdown formatting, do NOT include ```haskell tags, and do NOT write any explanations. Just the code.