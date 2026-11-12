# Prolog

Prompt templates for Prolog solutions. [`harness/prompts.py`](../harness/prompts.py) sends the first code
block under **Initial prompt** and under **Follow-up prompt** to the model, with the placeholders filled in
([how](../docs/01-how-it-works.md#prompts)). Editing a template changes what the model sees, so evaluate
the change in a new run (`RUN_ID`).

| | |
|---|---|
| Toolchain | SWI-Prolog, see [`Dockerfile`](Dockerfile) |
| Tests under valgrind | yes, without leak checking ([`run-tests.sh`](run-tests.sh)) |
| Shown to the model | `test-N.md`; `<name>.pl`: the module, documented predicates + stubs |
| Replaced by the model's code | the same module, returned in full |
| Never shown to the model | `tests.pl` |
| Run one test by hand | `docker compose run --rm evaluator test-N` (from this folder) |

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
3. Return ONLY the complete, raw, fixed Prolog code for `[TARGET FILE NAME]`.
4. Do NOT include Markdown formatting and do NOT write any explanations. Just the code.
```
