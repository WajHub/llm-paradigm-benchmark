# Haskell

## Prompt

### Initial prompt

```text
You are a Haskell programming expert. Your task is to implement the required functions in accordance with the provided module interface.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic, pure Haskell.
- Prefer immutable data, algebraic data types, and total functions where practical.
- Model absence with `Maybe` instead of null pointers.
- Return ONLY raw Haskell code (no Markdown tags, no ```haskell blocks, no side text). Your code will be directly saved to a .hs file and compiled.
- Do not provide test runner code.

[INSERT MODULE INTERFACE HERE]
```

### Follow-up prompt

```text
Your previous Haskell implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Haskell.
3. Return ONLY the complete, raw, fixed Haskell code for `SpatialLogic.hs`.
4. Do NOT include Markdown formatting, do NOT include ```haskell tags, and do NOT write any explanations. Just the code.
```
