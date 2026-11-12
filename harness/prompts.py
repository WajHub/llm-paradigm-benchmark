"""Prompt rendering from the templates in <Language>/README.md and <Language>/test-N/test-N.md."""

from __future__ import annotations

import re
from functools import lru_cache
from pathlib import Path

from tasks import REPO, Task

# A fenced block: opening ``` (optionally with a language tag) and closing ``` at line start.
# Inline mentions such as "no ```c blocks" sit mid-line and do not end the block.
_FENCE = re.compile(r"^```[^\n]*\n(.*?)^```[ \t]*$", re.MULTILINE | re.DOTALL)

_TASK = re.compile(r"\[TASK-SPECIFIC REQUIREMENTS\]")
_INSERT = re.compile(r"\[INSERT[^\]]*\]")
_ERROR_LOGS = re.compile(r"\[ERROR LOGS[^\]]*\]")
_FAILING = re.compile(r"\[FAILING TEST CASE[^\]]*\]")
_TARGET = re.compile(r"\[TARGET FILE NAME\]")
_LEFTOVER = re.compile(r"\[(INSERT|ERROR LOGS|FAILING TEST CASE|TASK-SPECIFIC|TARGET FILE)")


class TemplateError(ValueError):
    pass


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8").replace("\r\n", "\n")


def _first_block_after(text: str, heading: str, source: Path) -> str:
    start = text.find(heading)
    if start < 0:
        raise TemplateError(f"{source}: heading {heading!r} not found")
    match = _FENCE.search(text, start)
    if not match:
        raise TemplateError(f"{source}: no fenced block after {heading!r}")
    return match.group(1).rstrip("\n")


@lru_cache(maxsize=None)
def templates(lang: str, repo: Path = REPO) -> tuple[str, str]:
    """(initial, follow-up) templates of a language."""
    readme = repo / lang / "README.md"
    text = _read(readme)
    return (_first_block_after(text, "### Initial prompt", readme),
            _first_block_after(text, "### Follow-up prompt", readme))


def task_requirements(task: Task) -> str:
    return _first_block_after(_read(task.spec), "## Prompt", task.spec)


def _sub(pattern: re.Pattern, value: str, text: str, what: str) -> str:
    # A function replacement keeps backslashes in code (e.g. "\n" in C) literal.
    result, count = pattern.subn(lambda _: value, text)
    if count == 0:
        raise TemplateError(f"placeholder for {what} not found in template")
    return result


def _check(text: str, task: Task, kind: str) -> str:
    left = _LEFTOVER.search(text)
    if left:
        raise TemplateError(f"{task.id}: unresolved placeholder {left.group(0)!r} in {kind} prompt")
    return text


def render_initial(task: Task) -> str:
    initial, _ = templates(task.lang)
    text = _sub(_TASK, task_requirements(task), initial, "task requirements")
    text = _sub(_INSERT, _read(task.contract).rstrip("\n"), text, "contract")
    return _check(text, task, "initial")


def render_followup(task: Task, error_log: str, failing_tests: list[str]) -> str:
    _, followup = templates(task.lang)
    failing = ("Failing tests:\n" + "\n".join(f"- {name}" for name in failing_tests)
               if failing_tests else "Failing tests: all (no test results were produced, see above).")
    text = _sub(_ERROR_LOGS, error_log.rstrip("\n"), followup, "error logs")
    text = _sub(_FAILING, failing, text, "failing test case")
    text = _sub(_TARGET, task.target, text, "target file name")
    return _check(text, task, "follow-up")
