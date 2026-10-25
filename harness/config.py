"""All settings of the evaluation harness in one place.

Edit the values below. Command-line flags of run.py / judge.py override them for a single run.
The API key does not belong here: put it in harness/.env (git-ignored).
"""

# ----------------------------------------------------------------------------- run

# Results go to results/<RUN_ID>/. Keep it while adding languages/tests or the judge to a run:
# finished tasks are skipped. Use a new RUN_ID when you change GENERATOR_MODEL, GENERATOR_EFFORT,
# GENERATOR_MAX_TOKENS or MAX_REPAIRS: an existing run refuses to continue with different ones.
RUN_ID = "haiku-v1"

LANGUAGES = None        # None = all 7, or a subset, e.g. ["C", "Haskell"]
TESTS = None            # None = all, or test numbers, e.g. [4, 5]
SAMPLES = 1             # independent attempts per task (more = statistics, pass@k)
MAX_REPAIRS = 3         # follow-up rounds after a failed evaluation (0 = one-shot only)
WORKERS = 4             # tasks processed in parallel (Docker containers at the same time)
TIMEOUT_S = 300         # limit for one Docker test run, in seconds

# Ask for confirmation (showing the maximum number of API calls and a cost estimate)
# before the first paid request. Skip once with --yes.
ASK_BEFORE_API_CALLS = True

# ----------------------------------------------------------------------------- code generation

# Claude 5.x models (adaptive thinking + effort), e.g. "claude-haiku-5-5", "claude-sonnet-5-5",
# "claude-opus-5-5". Older models such as "claude-haiku-4-5" use a different thinking API.
GENERATOR_MODEL = "claude-haiku-5-5"
GENERATOR_EFFORT = "medium"         # low | medium | high | xhigh | max
GENERATOR_MAX_TOKENS = 32000        # per response; thinking counts toward it

# ----------------------------------------------------------------------------- judge

JUDGE_ENABLED = True                # score idiomaticity automatically after the run
JUDGE_MODEL = "claude-sonnet-5-5"   # don't change it once a run has judge results: they would mix
JUDGE_EFFORT = "high"
JUDGE_MAX_TOKENS = 16000
JUDGE_WHICH = "final"               # which attempt to judge: "final", "first" or "both"
JUDGE_FALLBACK = True               # retry a refused request on Anthropic's fallback model
                                    # (ignored for Haiku models, which do not support it)
CALIBRATION_REPEAT = 2              # judge.py --calibrate: judgements per solution
CALIBRATION_SAMPLES = 3             # judge.py --calibrate: run solutions included

# ----------------------------------------------------------------------------- report

REPORT_ENABLED = True               # write results/<RUN_ID>/report.md after the run

# USD per 1M tokens (input, output), used for the report and the cost estimate.
PRICES = {
    "claude-haiku-5-5": (0.10, 0.50),
    "claude-sonnet-5-5": (2.00, 10.00),
    "claude-opus-5-5": (4.00, 20.00),
}

# Assumed tokens per call (input, output) for the pre-run cost estimate: a deliberately
# pessimistic guess, real usage is in the report.
ESTIMATE_TOKENS_GENERATION = (10_000, 10_000)
ESTIMATE_TOKENS_JUDGE = (6_000, 3_000)
