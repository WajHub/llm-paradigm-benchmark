"""Runs a test-N folder in the language's Docker image and classifies the outcome."""

from __future__ import annotations

import os
import re
import shutil
import subprocess
import time
import uuid
from dataclasses import asdict, dataclass, field
from pathlib import Path

from tasks import REPO, TEST_ID, Task

# Outcomes whose code compiled/loaded: the judge scores only these.
COMPILED = {"pass", "test_failures", "memory_error", "runtime_crash", "timeout"}

# Same artefact list as .claude/skills/new-benchmark/scripts/verify.sh.
_ARTEFACT_SUFFIXES = {".o", ".ppu", ".hi", ".class"}
_ARTEFACT_NAMES = {"test_runner"}

_RESULT_LINE = re.compile(r"^\[(PASS|FAIL)\] (.*?)\s*$", re.MULTILINE)
_VALGRIND = re.compile(r"^==\d+==.*$", re.MULTILINE)
_VALGRIND_PROBLEM = re.compile(
    r"Invalid (read|write|free)|uninitialised|Mismatched|definitely lost|indirectly lost|"
    r"possibly lost|ERROR SUMMARY|Process terminating|overflow")

LOG_LIMIT = 6000


_DOCKER_DESKTOP_BINS = [
    Path(os.environ.get("LOCALAPPDATA", "")) / "Programs/DockerDesktop/resources/bin/docker.exe",
    Path(os.environ.get("ProgramFiles", r"C:\Program Files")) / "Docker/Docker/resources/bin/docker.exe",
]


def docker_bin() -> str:
    """DOCKER_BIN, then PATH, then the usual Docker Desktop install locations on Windows."""
    found = os.environ.get("DOCKER_BIN") or shutil.which("docker")
    if found:
        return found
    for candidate in _DOCKER_DESKTOP_BINS:
        if candidate.is_file():
            return str(candidate)
    raise RuntimeError("docker not found: start Docker Desktop, add docker to PATH or set DOCKER_BIN")


def image_name(lang: str) -> str:
    return f"llmbench-{lang.lower()}"


def build_images(langs: list[str], repo: Path = REPO) -> None:
    """Builds (or refreshes from cache) one image per language."""
    for lang in sorted(set(langs)):
        print(f"[docker] building {image_name(lang)} ...", flush=True)
        proc = subprocess.run([docker_bin(), "build", "-q", "-t", image_name(lang), str(repo / lang)],
                              capture_output=True, text=True, encoding="utf-8", errors="replace")
        if proc.returncode != 0:
            raise RuntimeError(f"docker build failed for {lang}:\n{proc.stdout}\n{proc.stderr}")


@dataclass
class EvalResult:
    category: str                    # pass | test_failures | memory_error | compile_error | runtime_crash | timeout
    passed: list[str] = field(default_factory=list)      # test IDs, e.g. ["A01", ...]
    failed: list[str] = field(default_factory=list)      # includes tests missing from the output
    names: dict[str, str] = field(default_factory=dict)  # ID -> full name printed by the runner
    exit_code: int | None = None
    duration_s: float = 0.0
    timed_out: bool = False

    @property
    def n_pass(self) -> int:
        return len(self.passed)

    @property
    def n_tests(self) -> int:
        return len(self.passed) + len(self.failed)

    def failing_names(self) -> list[str]:
        return [self.names.get(i, f"Test {i}") for i in self.failed]

    def to_dict(self) -> dict:
        return asdict(self) | {"n_pass": self.n_pass, "n_tests": self.n_tests}


def _copy_normalized(src: Path, dst: Path) -> None:
    data = src.read_bytes()
    if b"\0" not in data:
        data = data.replace(b"\r\n", b"\n")
    dst.write_bytes(data)


def prepare_workdir(task: Task, workdir: Path, files: dict[str, str] | None = None,
                    repo: Path = REPO) -> Path:
    """Creates <workdir>/<Lang>/ with the build scripts and a clean copy of test-N.

    `files` maps file names inside test-N to their content (e.g. the model's solution).
    Returns the directory to mount as /app.
    """
    lang_dir = workdir / task.lang
    if lang_dir.exists():
        shutil.rmtree(lang_dir)
    test_dir = lang_dir / task.test
    test_dir.mkdir(parents=True)
    for name in ("Makefile", "run-tests.sh"):
        _copy_normalized(repo / task.lang / name, lang_dir / name)
    for src in task.dir.iterdir():
        if src.is_file() and src.suffix not in _ARTEFACT_SUFFIXES and src.name not in _ARTEFACT_NAMES:
            _copy_normalized(src, test_dir / src.name)
    for name, content in (files or {}).items():
        (test_dir / name).write_text(content.replace("\r\n", "\n"), encoding="utf-8", newline="\n")
    return lang_dir


def run_tests(task: Task, mount_dir: Path, timeout_s: int) -> tuple[EvalResult, str]:
    """Runs run-tests.sh in a throwaway container. Returns (result, combined output)."""
    name = f"llmb-{uuid.uuid4().hex[:12]}"
    cmd = [docker_bin(), "run", "--rm", "--name", name,
           "-v", f"{mount_dir.resolve()}:/app", "-w", "/app",
           "--entrypoint", "sh", image_name(task.lang), "run-tests.sh", task.test]
    env = os.environ | {"MSYS_NO_PATHCONV": "1"}  # keep /app intact when launched from Git Bash
    start = time.monotonic()
    try:
        proc = subprocess.run(cmd, capture_output=True, timeout=timeout_s, env=env)
        output = (proc.stdout + proc.stderr).decode("utf-8", errors="replace")
        exit_code, timed_out = proc.returncode, False
    except subprocess.TimeoutExpired as exc:
        subprocess.run([docker_bin(), "kill", name], capture_output=True, env=env)
        output = ((exc.stdout or b"") + (exc.stderr or b"")).decode("utf-8", errors="replace")
        exit_code, timed_out = None, True
    result = parse_output(output, exit_code, task.test_ids, timed_out)
    result.duration_s = round(time.monotonic() - start, 1)
    return result, output


def parse_output(output: str, exit_code: int | None, test_ids: tuple[str, ...],
                 timed_out: bool = False) -> EvalResult:
    """`test_ids` are the task's tests; a test missing from the output counts as failed."""
    names: dict[str, str] = {}
    status: dict[str, str] = {}
    for verdict, name in _RESULT_LINE.findall(output):
        match = TEST_ID.search(name)
        if match:
            names[match.group(1)] = name
            status[match.group(1)] = verdict
    ids = [*test_ids, *(i for i in status if i not in test_ids)]
    passed = [i for i in ids if status.get(i) == "PASS"]
    failed = [i for i in ids if status.get(i) != "PASS"]

    if timed_out:
        category = "timeout"
    elif "=== START ===" not in output:
        category = "compile_error"
    elif "=== BENCHMARK RESULTS ===" not in output:
        category = "runtime_crash"
    elif not failed:
        category = "pass" if exit_code == 0 else "memory_error"
    else:
        category = "test_failures"
    return EvalResult(category=category, passed=passed, failed=failed, names=names,
                      exit_code=exit_code, timed_out=timed_out)


def _clip_head(text: str, limit: int) -> str:
    return text if len(text) <= limit else text[:limit] + "\n... [truncated]"


def _clip_tail(text: str, limit: int) -> str:
    return text if len(text) <= limit else "[truncated] ...\n" + text[-limit:]


def _without_build_noise(output: str) -> str:
    """Drops harness chatter (benchmark banner, make clean) that tells the model nothing."""
    keep = []
    for line in output.splitlines():
        if line.startswith("=== Running benchmark") or line.startswith("rm -f") or line.startswith("rm -rf"):
            continue
        keep.append(line)
    return "\n".join(keep)


def log_excerpt(result: EvalResult, output: str, timeout_s: int | None = None) -> str:
    """The part of the test output that goes into the follow-up prompt."""
    text = _without_build_noise(output)
    if result.category == "compile_error":
        return _clip_head(text.strip(), LOG_LIMIT)
    if result.category == "timeout":
        return (f"The test run exceeded the time limit of {timeout_s} s and was killed "
                f"(possible infinite loop or far too slow algorithm).\n"
                f"Output before the timeout:\n" + _clip_tail(text.strip(), LOG_LIMIT - 300))
    if result.category == "runtime_crash":
        return ("The test program crashed before printing the results summary.\n"
                + _clip_tail(text.strip(), LOG_LIMIT - 100))

    before_start, _, after_start = text.partition("=== START ===")
    valgrind = [line for line in _VALGRIND.findall(text) if _VALGRIND_PROBLEM.search(line)]
    if result.category == "memory_error":
        context = [line for line in _VALGRIND.findall(text)]
        return ("All tests passed, but the memory checker (valgrind) reported errors:\n"
                + _clip_tail("\n".join(context), LOG_LIMIT - 100))

    # test_failures: compiler/loader diagnostics + the result lines + valgrind summary lines.
    diagnostics = "\n".join(line for line in before_start.splitlines()
                            if line.strip() and not line.startswith("=="))
    results = "\n".join(line for line in after_start.splitlines()
                        if line.strip() and not line.startswith("=="))
    parts = []
    if diagnostics.strip():
        parts.append("Build/load output:\n" + _clip_tail(diagnostics, 2000))
    parts.append("Test output:\n" + _clip_head(results, 3000))
    if valgrind:
        parts.append("Valgrind:\n" + _clip_tail("\n".join(valgrind), 800))
    return "\n\n".join(parts)
