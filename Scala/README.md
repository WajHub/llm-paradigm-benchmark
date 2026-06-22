# Scala

## Prompt

### Initial prompt

```text
You are a Scala programming expert. Your task is to implement the required functions in accordance with the provided module interface.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic Scala.
- Prefer immutable data structures and pure functions where practical.
- Model absence with `Option` instead of null values.
- Return ONLY raw Scala code (no Markdown tags, no ```scala blocks, no side text). Your code will be directly saved to a `.scala` file and compiled.
- Do not provide test runner code.

[INSERT MODULE INTERFACE HERE]
```

### Follow-up prompt

```text
Your previous Scala implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Scala.
3. Return ONLY the complete, raw, fixed Scala code for `SpatialLogic.scala`.
4. Do NOT include Markdown formatting, do NOT include ```scala tags, and do NOT write any explanations. Just the code.
```