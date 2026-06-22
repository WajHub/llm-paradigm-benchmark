# Java

## Prompt

### Initial prompt

```
You are a Java programming expert. Your task is to implement the required methods in accordance with the provided class or interface.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic Java.
- Use object-oriented design and model the domain with classes.
- Prefer standard library collections and utilities where appropriate.
- Return ONLY raw Java code (no Markdown tags, no ```java blocks, no side text). Your code will be directly saved to a .java file and compiled. Do not provide a main() method or test code.

[INSERT CLASS OR INTERFACE CONTENT HERE]
```

### Follow-up prompt

```
Your previous Java implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS / COMPILER OUTPUT]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical or resource-management issue causing the failure.
2. Ensure resources are handled safely.
3. Return ONLY the complete, raw, fixed Java code for the target source file.
4. Do NOT include Markdown formatting, do NOT include ```java blocks, and do NOT write any explanations. Just the code.
```