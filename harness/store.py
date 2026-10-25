"""Layout of results/<run_id>/ and helpers to read it back."""

from __future__ import annotations

import json
import subprocess
from pathlib import Path

from tasks import REPO

RESULTS = REPO / "results"
WORK = REPO / ".work"


def write_json(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def read_json(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def write_jsonl(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8", newline="\n") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")


def git_state() -> dict:
    def git(*args: str) -> str:
        return subprocess.run(["git", *args], cwd=REPO, capture_output=True, text=True).stdout.strip()
    return {"commit": git("rev-parse", "HEAD"), "dirty": bool(git("status", "--porcelain"))}


def sample_dir(run_dir: Path, lang: str, test: str, sample: int) -> Path:
    return run_dir / lang / test / f"sample-{sample}"


def finished_samples(run_dir: Path) -> list[Path]:
    """Sample directories with a final.json, in a stable order."""
    return sorted(p.parent for p in run_dir.glob("*/test-*/sample-*/final.json"))


def attempt_dirs(sample: Path) -> list[Path]:
    return sorted((p for p in sample.glob("attempt-*") if p.is_dir()),
                  key=lambda p: int(p.name.split("-")[1]))


def collect_attempts(run_dir: Path) -> list[dict]:
    rows = []
    for sample in finished_samples(run_dir):
        for attempt in attempt_dirs(sample):
            if (attempt / "attempt.json").exists():
                rows.append(read_json(attempt / "attempt.json"))
    return rows


def collect_finals(run_dir: Path) -> list[dict]:
    return [read_json(sample / "final.json") for sample in finished_samples(run_dir)]
