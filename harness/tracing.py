"""Tracing: one record per API call, so every answer and every judge score can be followed back to
the exact request, the model's (summarized) reasoning, the response and Anthropic's request id.

    results/<run_id>/traces.jsonl                 index, one line per call (append-only)
    results/<run_id>/traces/<kind>/<label>-<time>.json   full record of that call

Turn it off with config.TRACE_ENABLED. The request id ("req_...") is what Anthropic support asks for
when you report a problem with a specific call.
"""

from __future__ import annotations

import json
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

import config

_lock = threading.Lock()


def _jsonable(obj):
    if hasattr(obj, "model_dump"):          # SDK content blocks inside a replayed conversation
        return obj.model_dump(mode="json")
    return str(obj)


def thinking_text(response) -> str:
    """The summarized reasoning of a response (empty when config.THINKING_DISPLAY is "omitted")."""
    return "\n\n".join(b.thinking for b in response.content
                       if b.type == "thinking" and getattr(b, "thinking", ""))


def record(run_dir: Path, kind: str, label: str, request: dict, response, duration_s: float,
           request_id: str | None, error: BaseException | None = None) -> Path | None:
    """Writes the full record of one API call and appends a summary line to traces.jsonl."""
    if not config.TRACE_ENABLED:
        return None
    now = datetime.now(timezone.utc)
    path = run_dir / "traces" / kind / f"{label}-{now.strftime('%Y%m%dT%H%M%S')}-{time.monotonic_ns() % 10**6:06d}.json"
    raw = response.model_dump(mode="json") if response is not None else None
    usage = (raw or {}).get("usage") or {}
    full = {
        "time": now.isoformat(timespec="seconds"),
        "kind": kind,
        "label": label,
        "request_id": request_id,
        "duration_s": round(duration_s, 1),
        "error": f"{type(error).__name__}: {error}" if error else None,
        "reasoning": thinking_text(response) if response is not None else "",
        "request": request,
        "response": raw,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(full, indent=2, ensure_ascii=False, default=_jsonable) + "\n",
                    encoding="utf-8", newline="\n")
    index = {
        "time": full["time"], "kind": kind, "label": label, "request_id": request_id,
        "model": (raw or {}).get("model", request.get("model")), "duration_s": full["duration_s"],
        "stop_reason": (raw or {}).get("stop_reason"),
        "input_tokens": usage.get("input_tokens"), "output_tokens": usage.get("output_tokens"),
        "error": full["error"], "file": path.relative_to(run_dir).as_posix(),
    }
    with _lock, (run_dir / "traces.jsonl").open("a", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(index, ensure_ascii=False) + "\n")
    return path


def stream_message(open_stream, request: dict, trace_ctx: tuple[Path, str, str] | None):
    """Runs one streamed request and traces it, failures included.

    open_stream: client.messages.stream or client.beta.messages.stream; request: its keyword arguments.
    trace_ctx: (run_dir, kind, label) or None to skip tracing.
    Returns (final message, request id, duration in seconds).
    """
    start = time.monotonic()
    request_id = None
    try:
        with open_stream(**request) as stream:
            request_id = getattr(stream, "request_id", None)
            response = stream.get_final_message()
    except BaseException as exc:
        if trace_ctx:
            record(*trace_ctx, request, None, time.monotonic() - start, request_id, error=exc)
        raise
    duration = round(time.monotonic() - start, 1)
    request_id = request_id or getattr(response, "_request_id", None)
    if trace_ctx:
        record(*trace_ctx, request, response, duration, request_id)
    return response, request_id, duration
