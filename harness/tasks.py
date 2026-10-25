"""Discovery of benchmark tasks: one task = one <Language>/test-N folder."""

from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent

PARADIGMS = {
    "C": "imperative",
    "Pascal": "imperative",
    "Java": "object-oriented",
    "Smalltalk": "object-oriented",
    "Haskell": "functional",
    "Scala": "functional",
    "Prolog": "logic",
}
LANGUAGES = list(PARADIGMS)

# Test runner file in each test-N folder (never shown to the model, never overwritten).
TEST_FILES = {
    "C": "tests.c",
    "Pascal": "tests.pas",
    "Java": "Tests.java",
    "Smalltalk": "Tests.st",
    "Haskell": "Tests.hs",
    "Scala": "Tests.scala",
    "Prolog": "tests.pl",
}
EXTENSIONS = {
    "C": ".c",
    "Pascal": ".pas",
    "Java": ".java",
    "Smalltalk": ".st",
    "Haskell": ".hs",
    "Scala": ".scala",
    "Prolog": ".pl",
}


@dataclass(frozen=True)
class Task:
    lang: str
    test: str            # "test-4"
    dir: Path            # <repo>/<lang>/test-4
    contract: Path       # file whose content is inserted into the prompt
    target: str          # file name the model writes (overwritten in the work copy)

    @property
    def id(self) -> str:
        return f"{self.lang}/{self.test}"

    @property
    def paradigm(self) -> str:
        return PARADIGMS[self.lang]

    @property
    def spec(self) -> Path:
        return self.dir / f"{self.test}.md"


def _sources(test_dir: Path, lang: str) -> list[Path]:
    ext = EXTENSIONS[lang]
    return sorted(p for p in test_dir.iterdir()
                  if p.suffix == ext and p.name != TEST_FILES[lang])


def _one(paths: list[Path], what: str, test_dir: Path) -> Path:
    if len(paths) != 1:
        names = ", ".join(p.name for p in paths) or "none"
        raise ValueError(f"{test_dir}: expected exactly one {what}, found: {names}")
    return paths[0]


def load_task(lang: str, test: str, repo: Path = REPO) -> Task:
    test_dir = repo / lang / test
    sources = _sources(test_dir, lang)
    if lang == "C":
        contract = _one(sorted(test_dir.glob("*.h")), "header (*.h)", test_dir)
        target = _one(sources, "implementation (*.c)", test_dir)
    elif lang in ("Java", "Smalltalk"):
        impl = _one([p for p in sources if p.stem.endswith("Impl")], "*Impl file", test_dir)
        contract = test_dir / (impl.stem[: -len("Impl")] + impl.suffix)
        if not contract.exists():
            raise ValueError(f"{test_dir}: missing contract {contract.name}")
        target = impl
    else:
        # Haskell, Scala, Prolog, Pascal: one module holding the contract and the stubs.
        contract = target = _one(sources, f"module ({EXTENSIONS[lang]})", test_dir)
    return Task(lang=lang, test=test, dir=test_dir, contract=contract, target=target.name)


# Solutions that were committed in place of stubs, kept only in git history; used to validate
# the evaluator (run.py --baseline) and to calibrate the judge (judge.py --calibrate).
REFERENCE_COMMIT = "a9f0372"
REFERENCE_FILES = {
    ("C", "test-1"): "spatial_logic.c",
    ("C", "test-3"): "palindrome_tree.c",
    ("Pascal", "test-1"): "spatial_logic.pas",
    ("Java", "test-1"): "SpatialLogicImpl.java",
    ("Smalltalk", "test-1"): "SpatialLogicImpl.st",
}
# References known to pass 20/20 (Java 15/20 and Smalltalk 18/20 are known-imperfect).
REFERENCE_EXPECTED_PASS = {("C", "test-1"), ("C", "test-3"), ("Pascal", "test-1")}


def reference_source(task: Task, repo: Path = REPO) -> str | None:
    name = REFERENCE_FILES.get((task.lang, task.test))
    if not name:
        return None
    proc = subprocess.run(["git", "show", f"{REFERENCE_COMMIT}:{task.lang}/{task.test}/{name}"],
                          cwd=repo, capture_output=True, text=True, encoding="utf-8")
    if proc.returncode != 0:
        raise RuntimeError(f"cannot read reference {name} from {REFERENCE_COMMIT}: {proc.stderr}")
    return proc.stdout


def discover(langs: list[str] | None = None, tests: list[int] | None = None,
             repo: Path = REPO) -> list[Task]:
    tasks = []
    for lang in langs or LANGUAGES:
        if lang not in PARADIGMS:
            raise ValueError(f"unknown language {lang!r}; known: {', '.join(LANGUAGES)}")
        numbers = sorted(int(p.name.split("-")[1]) for p in (repo / lang).glob("test-*") if p.is_dir())
        for n in numbers:
            if tests is None or n in tests:
                tasks.append(load_task(lang, f"test-{n}", repo))
    return tasks
