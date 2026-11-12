"""Claude API access: API key loading, code generation calls and code extraction."""

from __future__ import annotations

import os
import re
import time
from dataclasses import dataclass
from pathlib import Path

import anthropic

import config

ENV_FILE = Path(__file__).with_name(".env")
PLACEHOLDER_KEY = "sk-ant-PLACEHOLDER"

# Errors that will not go away by retrying later (bad key, bad model id, malformed request).
FATAL_ERRORS = (anthropic.AuthenticationError, anthropic.PermissionDeniedError,
                anthropic.NotFoundError, anthropic.BadRequestError)

_FENCED = re.compile(r"^```[^\n]*\n(.*?)^```[ \t]*$", re.MULTILINE | re.DOTALL)
_FENCE_LINE = re.compile(r"^```", re.MULTILINE)


def load_api_key() -> None:
    """Loads harness/.env into the environment; an exported ANTHROPIC_API_KEY takes precedence."""
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not key or key == PLACEHOLDER_KEY:
        raise SystemExit("ANTHROPIC_API_KEY is not set: put your key in harness/.env "
                         "(template: harness/.env.example) or export it.")


def make_client() -> anthropic.Anthropic:
    return anthropic.Anthropic(max_retries=5)


def estimate_cost(model: str, calls: int, tokens_per_call: tuple[int, int]) -> float | None:
    if model not in config.PRICES:
        return None
    pin, pout = config.PRICES[model]
    return calls * (tokens_per_call[0] * pin + tokens_per_call[1] * pout) / 1e6


def format_cost(usd: float | None) -> str:
    return "? (model missing in config.PRICES)" if usd is None else f"~${usd:.2f}"


def confirm_api_use(summary: list[str], assume_yes: bool = False) -> None:
    """Shows what is about to be spent and, per config.ASK_BEFORE_API_CALLS, asks to continue."""
    print("\n".join(summary), flush=True)
    if assume_yes or not config.ASK_BEFORE_API_CALLS:
        return
    try:
        answer = input("Continue and make these API calls? [y/N] ")
    except EOFError:
        answer = ""
    if answer.strip().lower() not in ("y", "yes", "t", "tak"):
        raise SystemExit("Aborted: no API calls were made.")


def usage_dict(usage) -> dict:
    return {
        "input_tokens": usage.input_tokens or 0,
        "output_tokens": usage.output_tokens or 0,
        "cache_read_input_tokens": usage.cache_read_input_tokens or 0,
        "cache_creation_input_tokens": usage.cache_creation_input_tokens or 0,
    }


def response_text(response) -> str:
    # Responses can start with thinking blocks: read text blocks by type, never by position.
    return "".join(block.text for block in response.content if block.type == "text")


def extract_code(text: str) -> tuple[str, bool]:
    """Returns (code, format_violation). The prompts ask for raw code without Markdown fences."""
    stripped = text.strip()
    if not _FENCE_LINE.search(stripped):
        return (stripped + "\n" if stripped else ""), False
    blocks = _FENCED.findall(stripped)
    if blocks:
        return max(blocks, key=len).strip("\n") + "\n", True
    # Closing fence glued to the last code line, or missing (output cut off): take everything
    # between the first fence line and the last ``` (or the end), dropping prose before it.
    body = stripped[_FENCE_LINE.search(stripped).start():].split("\n", 1)
    body = body[1] if len(body) > 1 else ""
    end = body.rfind("```")
    if end >= 0:
        body = body[:end]
    return body.strip("\n") + "\n", True


@dataclass
class Generation:
    content: list              # raw content blocks, appended unchanged to the conversation
    code: str
    format_violation: bool
    stop_reason: str | None
    usage: dict
    duration_s: float
    raw: dict                  # full response for the record


def generate(client: anthropic.Anthropic, model: str, effort: str, messages: list[dict],
             max_tokens: int) -> Generation:
    start = time.monotonic()
    with client.messages.stream(
        model=model,
        max_tokens=max_tokens,          # thinking counts toward max_tokens
        thinking={"type": "adaptive"},
        output_config={"effort": effort},
        messages=messages,
    ) as stream:
        response = stream.get_final_message()
    code, violation = extract_code(response_text(response))
    return Generation(
        content=response.content,
        code=code,
        format_violation=violation,
        stop_reason=response.stop_reason,
        usage=usage_dict(response.usage),
        duration_s=round(time.monotonic() - start, 1),
        raw=response.model_dump(mode="json"),
    )
