#!/usr/bin/env python3
"""CwdChanged hook: auto-activate direnv for the new working directory.

Reads the CwdChanged JSON payload from stdin. If the new cwd (or an
ancestor) has an .envrc and direnv is available, runs `direnv export json`
and appends bash-style export/unset statements to $CLAUDE_ENV_FILE so the
delta applies to subsequent Bash tool calls in the session.

Exits 0 on success AND on recoverable errors (direnv missing, .envrc not
allowed, direnv exited nonzero, CLAUDE_ENV_FILE unset) — the hook never
blocks the session. A best-effort systemReminder is emitted when something
is worth telling the model (e.g. .envrc needs `direnv allow`).

Protocol reference: https://code.claude.com/docs/en/hooks#cwdchanged
"""

from __future__ import annotations

import json
import os
import shlex
import shutil
import subprocess
import sys
from pathlib import Path


HOOK_TAG = "cwd-direnv"
DIRENV_TIMEOUT_S = 10
# Valid POSIX shell identifier per IEEE Std 1003.1: letter/underscore then
# alphanumerics/underscores. Anything else gets skipped to keep the emitted
# file sourceable.
_SAFE_KEY = __import__("re").compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def log(msg: str) -> None:
    print(f"[{HOOK_TAG}] {msg}", file=sys.stderr)


def emit_system_reminder(text: str) -> None:
    json.dump(
        {"systemReminder": text, "suppressOutput": True},
        sys.stdout,
    )


def load_payload() -> dict:
    raw = sys.stdin.read()
    if not raw.strip():
        return {}
    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        log(f"invalid stdin payload: {e}")
        return {}
    return data if isinstance(data, dict) else {}


def has_envrc(cwd: Path) -> bool:
    for p in [cwd, *cwd.parents]:
        if (p / ".envrc").is_file():
            return True
    return False


def run_direnv_export(cwd: Path) -> tuple[dict | None, str]:
    """Return (delta, stderr). delta is None on failure."""
    try:
        result = subprocess.run(
            ["direnv", "export", "json"],
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=DIRENV_TIMEOUT_S,
            check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired) as e:
        return None, str(e)

    if result.returncode != 0:
        return None, result.stderr.strip()

    body = result.stdout.strip()
    if not body:
        return {}, ""
    try:
        parsed = json.loads(body)
    except json.JSONDecodeError as e:
        return None, f"non-JSON output from direnv export: {e}"
    return parsed if isinstance(parsed, dict) else {}, ""


def write_exports(env_file: Path, delta: dict) -> tuple[int, int]:
    added = 0
    removed = 0
    lines: list[str] = []
    for key, value in sorted(delta.items()):
        if not _SAFE_KEY.match(key):
            continue
        if value is None:
            lines.append(f"unset {key}")
            removed += 1
        else:
            lines.append(f"export {key}={shlex.quote(str(value))}")
            added += 1
    if lines:
        env_file.parent.mkdir(parents=True, exist_ok=True)
        with env_file.open("a", encoding="utf-8") as f:
            f.write("\n".join(lines) + "\n")
    return added, removed


def main() -> int:
    payload = load_payload()
    cwd_str = payload.get("cwd")
    if not cwd_str:
        return 0

    cwd = Path(cwd_str)
    if not cwd.is_dir():
        log(f"cwd does not exist: {cwd}")
        return 0

    if not has_envrc(cwd):
        return 0

    if shutil.which("direnv") is None:
        log("direnv not installed; skipping")
        return 0

    delta, stderr = run_direnv_export(cwd)
    if delta is None:
        log(f"direnv export failed in {cwd}: {stderr or '<no stderr>'}")
        # Most common cause is an un-allowed .envrc. Tell the model so it
        # can suggest `direnv allow` rather than silently missing tools.
        emit_system_reminder(
            f"[{HOOK_TAG}] direnv refused to load .envrc under {cwd}. "
            "Run `direnv allow` from a trusted shell to apply that "
            "environment here."
        )
        return 0
    if not delta:
        return 0

    env_file_str = os.environ.get("CLAUDE_ENV_FILE")
    if not env_file_str:
        keys = sorted(k for k, v in delta.items() if v is not None)
        if keys:
            emit_system_reminder(
                f"[{HOOK_TAG}] .envrc under {cwd} would set: "
                f"{', '.join(keys)} (CLAUDE_ENV_FILE unset — environment "
                "will not auto-apply)."
            )
        return 0

    try:
        added, removed = write_exports(Path(env_file_str), delta)
    except OSError as e:
        log(f"failed writing to CLAUDE_ENV_FILE={env_file_str}: {e}")
        return 0

    if added or removed:
        emit_system_reminder(
            f"[{HOOK_TAG}] Loaded .envrc for {cwd} "
            f"(+{added} var(s), -{removed} var(s))."
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
