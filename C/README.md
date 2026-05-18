# C

## Prompt

### Initial prompt 

```
You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (like free_polygon) must safely free all nested pointers and structures to avoid memory leaks.
- Return ONLY raw C code (no Markdown tags, no ```c blocks, no side text). Your code will be directly saved to a .c file and compiled. Do not provide main() or test functions.

[INSERT HEADER FILE CONTENT HERE]
```

### Follow-up prompt

```
Your previous C implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS / VALGRIND OUTPUT]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical or memory issue causing the failure.
2. Ensure memory is managed safely.
3. Return ONLY the complete, raw, fixed C code for `spatial_logic.c`. 
4. Do NOT include Markdown formatting, do NOT include ```c tags, and do NOT write any explanations. Just the code.

```