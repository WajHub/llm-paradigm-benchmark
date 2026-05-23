# Pascal

## Prompt

### Initial prompt

```
You are a Pascal programming expert. Your task is to implement the required functions in accordance with the provided unit interface.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic procedural Pascal.
- Manage dynamically allocated structures safely.
- Return ONLY raw Pascal code (no Markdown tags, no side text).
- Do not provide test runner code.

[INSERT UNIT INTERFACE HERE]
```

### Follow-up prompt

```
Your previous Pascal implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical or memory issue causing the failure.
2. Ensure memory is managed safely.
3. Return ONLY the complete, raw, fixed Pascal code for `spatial_logic.pas`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.
```