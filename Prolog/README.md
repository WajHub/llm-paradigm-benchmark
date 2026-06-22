# Prolog

## Prompt

### Initial prompt

```text
You are a Prolog programming expert. Your task is to implement the required predicates in accordance with the provided module interface.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic SWI-Prolog.
- Prefer pure predicates and relational style where practical.
- Model failure through predicate failure rather than exceptions.
- Return ONLY raw Prolog code (no Markdown tags, no side text). Your code will be directly saved to a .pl file and executed.
- Do not provide test runner code.

[INSERT MODULE INTERFACE HERE]
```

### Follow-up prompt

```text
Your previous Prolog implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Keep the solution idiomatic for Prolog.
3. Return ONLY the complete, raw, fixed Prolog code for `spatial_logic.pl`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.
```
