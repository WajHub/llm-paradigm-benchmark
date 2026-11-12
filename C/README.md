# C

Prompt templates for C solutions. [`harness/prompts.py`](../harness/prompts.py) sends the first code
block under **Initial prompt** and under **Follow-up prompt** to the model, with the placeholders filled in
([how](../docs/01-how-it-works.md#prompts)). Editing a template changes what the model sees, so evaluate
the change in a new run (`RUN_ID`).

| | |
|---|---|
| Toolchain | gcc, see [`Dockerfile`](Dockerfile) |
| Tests under valgrind | yes ([`run-tests.sh`](run-tests.sh)) |
| Shown to the model | `test-N.md`; `<name>.h` (contract) |
| Replaced by the model's code | `<name>.c` (stub) |
| Never shown to the model | `tests.c` |
| Run one test by hand | `docker compose run --rm evaluator test-N` (from this folder) |

## Prompt

### Initial prompt 

```
You are a C programming expert. Your task is to implement the required functions in accordance with the provided header file.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Memory must be managed dynamically (malloc/calloc). Functions responsible for deallocation (the `free_*` functions) must safely free all nested pointers and structures to avoid memory leaks.
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
3. Return ONLY the complete, raw, fixed C code for `[TARGET FILE NAME]`.
4. Do NOT include Markdown formatting, do NOT include ```c tags, and do NOT write any explanations. Just the code.

```