# Scala

Prompt templates for Scala solutions. [`harness/prompts.py`](../harness/prompts.py) sends the first code
block under **Initial prompt** and under **Follow-up prompt** to the model, with the placeholders filled in
([how](../docs/01-how-it-works.md#prompts)). Editing a template changes what the model sees, so evaluate
the change in a new run (`RUN_ID`).

| | |
|---|---|
| Toolchain | Scala (`scalac`), see [`Dockerfile`](Dockerfile) |
| Tests under valgrind | no ([`run-tests.sh`](run-tests.sh)) |
| Shown to the model | `test-N.md`; `<Name>.scala`: the object, types + stub methods |
| Replaced by the model's code | the same file, returned in full |
| Never shown to the model | `Tests.scala` |
| Run one test by hand | `docker compose run --rm evaluator test-N` (from this folder) |

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
3. Return ONLY the complete, raw, fixed Scala code for `[TARGET FILE NAME]`.
4. Do NOT include Markdown formatting, do NOT include ```scala tags, and do NOT write any explanations. Just the code.
```