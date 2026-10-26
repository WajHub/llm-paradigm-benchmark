# Smalltalk

Prompt templates for Smalltalk solutions. [`harness/prompts.py`](../harness/prompts.py) sends the first code
block under **Initial prompt** and under **Follow-up prompt** to the model, with the placeholders filled in
([how](../docs/01-how-it-works.md#prompts)). Editing a template changes what the model sees, so evaluate
the change in a new run (`RUN_ID`).

| | |
|---|---|
| Toolchain | GNU Smalltalk (`gst`), see [`Dockerfile`](Dockerfile) |
| Tests under valgrind | no ([`run-tests.sh`](run-tests.sh)) |
| Shown to the model | `test-N.md`; `<Name>.st` (domain classes, abstract base) |
| Replaced by the model's code | `<Name>Impl.st` (stub) |
| Never shown to the model | `Tests.st` |
| Run one test by hand | `docker compose run --rm evaluator test-N` (from this folder) |

## Prompt

### Initial prompt

```
You are a GNU Smalltalk programming expert. Your task is to implement the required methods in accordance with the provided class hierarchy.

[TASK-SPECIFIC REQUIREMENTS]

General Requirements:
- Use idiomatic GNU Smalltalk (gst) syntax.
- Use object-oriented design and model the domain with classes and message passing.
- Do not redefine built-in classes (e.g. Point, Set, Interval); use them as provided.
- Prefer standard Smalltalk collections and idioms where appropriate.
- Return ONLY raw Smalltalk code (no Markdown tags, no ```smalltalk blocks, no side text). Your code will be directly saved to a .st file and loaded by gst. Do not provide test code.

[INSERT INTERFACE FILE CONTENT HERE]
```

### Follow-up prompt

```
Your previous GNU Smalltalk implementation failed the evaluation. Your task is to analyze the error and provide a corrected version of the code.

[ERROR LOGS / GST OUTPUT]

[FAILING TEST CASE (Code or name of the test case)]

Requirements for the fix:
1. Identify and resolve the core logical issue causing the failure.
2. Ensure nil arguments and edge cases are handled safely.
3. Return ONLY the complete, raw, fixed GNU Smalltalk code for `[TARGET FILE NAME]`.
4. Do NOT include Markdown formatting, do NOT include ```smalltalk blocks, and do NOT write any explanations. Just the code.
```
