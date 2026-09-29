#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = []
# ///
"""Switch Claude Code or Codex accounts without replacing their shared state.

Profiles contain authentication secrets. They are stored outside this repository
under ``${XDG_DATA_HOME:-~/.local/share}/k-ai-auth`` with private permissions.

Typical setup and use::

    k-ai-auth claude save personal
    # Log in to the other account once, close Claude Code, then:
    k-ai-auth claude save work
    k-ai-auth claude use personal

The Claude provider patches only account identity fields. In particular, it
preserves ``mcpOAuth`` entries in ``.credentials.json`` and all project history.
The Codex provider swaps only ``auth.json`` and leaves the rest of ``CODEX_HOME``
alone. Credential profiles are reusable across config directories; active-profile
state is tracked separately for each resolved config directory. Close the
corresponding CLI before saving or switching a profile.

Subscription usage can be read for every profile without switching::

    k-ai-auth usage            # both tools
    k-ai-auth codex usage --json

A profile that is active in some config directory is read from that directory's
live credentials. Providers rotate refresh tokens, so an outside refresh would
log a running CLI out: an expired live token is refreshed only when no CLI is
running against any directory holding that login, and the rotated tokens are
written to the profile and to those directories' credential files (account
fields only, as ``use`` does). A profile that is not active anywhere is
refreshed when its access token has expired and written back to the profile.
"""

from __future__ import annotations

import argparse
import base64
import contextlib
import fcntl
import json
import os
import re
import ssl
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Iterator, Mapping
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from typing import Any, Protocol

JsonObject = dict[str, Any]
PROFILE_VERSION = 1
PROFILE_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*\Z")
HTTP_TIMEOUT = 15
# Refresh a little before expiry so the usage request cannot race it.
EXPIRY_MARGIN = 300
FALLBACK_CA_FILE = Path("/etc/ssl/certs/ca-certificates.crt")


class AiAuthError(Exception):
    """An expected, user-facing k-ai-auth error."""


def read_json(path: Path) -> JsonObject:
    """Read a JSON object without ever including its contents in errors."""
    try:
        if path.is_symlink():
            raise AiAuthError(f"refusing to read symlink: {path}")
        value = json.loads(path.read_text(encoding="utf-8"))
    except AiAuthError:
        raise
    except FileNotFoundError as error:
        raise AiAuthError(f"credential file does not exist: {path}") from error
    except (OSError, json.JSONDecodeError) as error:
        raise AiAuthError(f"could not read valid JSON from {path}: {error}") from error
    if not isinstance(value, dict):
        raise AiAuthError(f"expected a JSON object in {path}")
    return value


def ensure_private_dir(path: Path) -> None:
    """Create a private directory and correct overly broad existing modes."""
    path.mkdir(mode=0o700, parents=True, exist_ok=True)
    if path.is_symlink() or not path.is_dir():
        raise AiAuthError(f"profile path is not a real directory: {path}")
    path.chmod(0o700)


def fsync_dir(path: Path) -> None:
    """Best-effort durability for an atomic rename."""
    try:
        descriptor = os.open(path, os.O_RDONLY)
    except OSError:
        return
    try:
        os.fsync(descriptor)
    except OSError:
        pass
    finally:
        os.close(descriptor)


def atomic_write_text(path: Path, text: str) -> None:
    """Atomically write private text using a temporary file beside the target."""
    path.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    descriptor, temporary_name = tempfile.mkstemp(
        dir=path.parent,
        prefix=f".{path.name}.",
    )
    temporary = Path(temporary_name)
    try:
        os.fchmod(descriptor, 0o600)
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(text)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temporary, path)
        path.chmod(0o600)
        fsync_dir(path.parent)
    except BaseException:
        with contextlib.suppress(OSError):
            os.close(descriptor)
        with contextlib.suppress(FileNotFoundError):
            temporary.unlink()
        raise


def atomic_write_json(path: Path, value: JsonObject) -> None:
    atomic_write_text(path, json.dumps(value, indent=2, sort_keys=True) + "\n")


def patch_json(path: Path, updates: JsonObject, removals: tuple[str, ...] = ()) -> None:
    """Patch named top-level fields while preserving every other field."""
    value = read_json(path)
    value.update(updates)
    for key in removals:
        value.pop(key, None)
    atomic_write_json(path, value)


def jwt_claims(token: str) -> JsonObject | None:
    """Decode a JWT payload without verifying it; used only for display and expiry."""
    try:
        payload = token.split(".")[1]
        payload += "=" * (-len(payload) % 4)
        claims = json.loads(base64.urlsafe_b64decode(payload))
    except (IndexError, ValueError, json.JSONDecodeError):
        return None
    return claims if isinstance(claims, dict) else None


def ssl_context() -> ssl.SSLContext:
    # uv-managed Python does not find the NixOS CA bundle on its own.
    cafile = os.environ.get("SSL_CERT_FILE")
    if not cafile and FALLBACK_CA_FILE.exists():
        cafile = str(FALLBACK_CA_FILE)
    return ssl.create_default_context(cafile=cafile)


def http_json(
    method: str,
    url: str,
    headers: dict[str, str],
    body: JsonObject | None = None,
) -> JsonObject:
    """Send a JSON request; errors never include request headers or tokens."""
    data = None
    headers = {"User-Agent": "k-ai-auth", "Accept": "application/json", **headers}
    if body is not None:
        data = json.dumps(body).encode()
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(
            request, timeout=HTTP_TIMEOUT, context=ssl_context()
        ) as response:
            value = json.loads(response.read())
    except urllib.error.HTTPError as error:
        raise AiAuthError(f"HTTP {error.code} from {urllib.parse.urlsplit(url).netloc}") from error
    except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as error:
        raise AiAuthError(
            f"request to {urllib.parse.urlsplit(url).netloc} failed: {error}"
        ) from error
    except ValueError:
        # http.client rejects malformed header values with a message that quotes
        # the header, i.e. the bearer token; drop it and the chained traceback.
        raise AiAuthError("invalid request header (malformed token?)") from None
    if not isinstance(value, dict):
        raise AiAuthError(f"unexpected response shape from {url}")
    return value


def format_reset(when: datetime | None) -> str:
    if when is None:
        return ""
    local = when.astimezone()
    now = datetime.now().astimezone()
    if local.date() == now.date():
        return f"{local:%H:%M}"
    return f"{local:%a %H:%M}"


def environment_root(variable: str, default: str, env: Mapping[str, str]) -> Path | None:
    """Resolve a CLI config root from an environment the way the CLI does.

    Shared by the provider (our own environment) and the running-process guard
    (another process's environment) so the two cannot drift. Returns None when
    the environment lacks the HOME needed to resolve it.
    """
    raw = env.get(variable)
    home = env.get("HOME")
    if raw:
        if raw == "~" or raw.startswith("~/"):
            return Path(home, raw[2:]) if home else None
        return Path(raw)
    return Path(home, default) if home else None


def own_environment() -> dict[str, str]:
    return {"HOME": str(Path.home()), **os.environ}


def data_root() -> Path:
    raw = os.environ.get("XDG_DATA_HOME")
    base = Path(raw).expanduser() if raw else Path.home() / ".local" / "share"
    return base / "k-ai-auth"


def validate_profile_name(name: str) -> str:
    if not PROFILE_RE.fullmatch(name) or name.startswith("."):
        raise AiAuthError(
            "profile names must start with a letter or digit and contain only "
            "letters, digits, dots, underscores, or hyphens"
        )
    return name


def process_environment(process_dir: Path) -> dict[str, str]:
    raw = (process_dir / "environ").read_bytes()
    env = {}
    for entry in raw.split(b"\0"):
        key, separator, value = os.fsdecode(entry).partition("=")
        if separator:
            env[key] = value
    return env


def process_root(provider: Provider, process_dir: Path) -> Path | None:
    """The config root a running CLI uses, or None when it cannot be determined."""
    try:
        root = provider.root_from_env(process_environment(process_dir))
        if root is not None and not root.is_absolute():
            root = Path(os.readlink(process_dir / "cwd")) / root
    except (OSError, ValueError):
        return None
    return root


def running_processes(provider: Provider, root: Path) -> list[int]:
    """Return PIDs of the provider's CLI that use ``root``, via Linux procfs.

    Fails closed: a process whose environment cannot be read counts as a match.
    """
    tool = provider.name
    proc = Path("/proc")
    if not proc.is_dir():
        return []
    target = root.resolve(strict=False)
    current_pid = os.getpid()
    matches: list[int] = []
    for process_dir in proc.iterdir():
        if not process_dir.name.isdigit():
            continue
        pid = int(process_dir.name)
        if pid == current_pid:
            continue
        try:
            command = (process_dir / "comm").read_text(encoding="utf-8").strip()
        except (FileNotFoundError, PermissionError, ProcessLookupError, OSError):
            continue
        matched = command == tool or command.startswith(f"{tool}-")
        argv: list[bytes] | None = None
        try:
            argv = (process_dir / "cmdline").read_bytes().split(b"\0")
            if not matched:
                executable = Path(os.fsdecode(argv[0])).name
                matched = executable == tool or executable.startswith(f"{tool}-")
        except (FileNotFoundError, PermissionError, ProcessLookupError, OSError):
            pass
        if not matched:
            continue
        # The Claude in Chrome native host is a stdio-to-socket relay for the
        # browser extension. Claude Code dispatches it before loading config or
        # credentials, and it never reads or refreshes OAuth tokens, so it cannot
        # clobber a switch even though it runs without CLAUDE_CONFIG_DIR.
        if tool == "claude" and argv is not None and b"--chrome-native-host" in argv[1:]:
            continue
        process_config = process_root(provider, process_dir)
        if process_config is None or process_config.resolve(strict=False) == target:
            matches.append(pid)
    return sorted(matches)


def describe_process(pid: int, width: int = 100) -> str:
    """A process's command line, shortened, for telling the user what to close."""
    try:
        argv = (Path("/proc") / str(pid) / "cmdline").read_bytes().split(b"\0")
    except OSError:
        return "(exited or unreadable)"
    command = " ".join(os.fsdecode(arg) for arg in argv if arg)
    return command if len(command) <= width else command[: width - 1] + "…"


def refuse_running_process(provider: Provider) -> None:
    root = provider.root.resolve(strict=False)
    matches = running_processes(provider, root)
    if not matches:
        return
    processes = "\n".join(f"  {pid:>8}  {describe_process(pid)}" for pid in matches)
    raise AiAuthError(
        f"refusing while {provider.name} is running against {root}; close these first so "
        f"they cannot overwrite the switched credentials:\n{processes}"
    )


def refuse_active_elsewhere(store: ProfileStore, name: str) -> None:
    """Refuse to put one saved login into a second config directory.

    Refresh tokens are single-use: when either directory renews, the other is left
    holding a retired token and gets logged out (a reused retired token may even
    revoke the login everywhere).
    """
    roots = [root for root, active in store.active_state()["roots"].items() if active == name]
    others = [root for root in roots if root != store.root_key]
    if others:
        raise AiAuthError(
            f"profile {name} is already active in {', '.join(others)}; two directories "
            "sharing one login log each other out when either renews its token. Switch "
            "that directory to another profile first, or log in separately here and save "
            "it under a new name"
        )


class Provider(Protocol):
    name: str

    @property
    def root(self) -> Path: ...

    def capture(self) -> JsonObject: ...

    def validate_snapshot(self, snapshot: JsonObject) -> None: ...

    def apply(self, snapshot: JsonObject) -> None: ...

    def write_tokens(self, snapshot: JsonObject) -> None:
        """Store refreshed tokens in this root's live credentials, touching nothing else."""
        ...

    def whoami(self) -> str | None: ...

    def refresh_expiry(self, snapshot: JsonObject) -> float | None: ...

    def root_from_env(self, env: Mapping[str, str]) -> Path | None: ...

    def at(self, root: str) -> Provider:
        """The same provider bound to an explicit config directory."""
        ...

    def access_expiry(self, snapshot: JsonObject) -> float | None: ...

    def refresh_token(self, snapshot: JsonObject) -> str | None: ...

    def refresh(self, snapshot: JsonObject) -> JsonObject:
        """Return a new snapshot with rotated tokens; the input is not modified."""
        ...

    def fetch_usage(self, snapshot: JsonObject) -> JsonObject: ...

    def format_usage(self, usage: JsonObject) -> UsageCells: ...


@dataclass(frozen=True)
class Window:
    """One rate-limit window: percent used and when it resets."""

    percent: float
    reset: datetime | None


# Table cells keyed by column: a window label ("5h", "week", ...) or "note".
UsageCells = dict[str, "Window | str"]


def usage_window(percent: object, reset: datetime | None) -> Window | None:
    if not isinstance(percent, int | float):
        return None
    return Window(float(percent), reset)


def parse_iso(raw: object) -> datetime | None:
    if not isinstance(raw, str):
        return None
    try:
        return datetime.fromisoformat(raw)
    except ValueError:
        return None


CLAUDE_CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e"
CLAUDE_TOKEN_URL = "https://platform.claude.com/v1/oauth/token"
CLAUDE_USAGE_URL = "https://api.anthropic.com/api/oauth/usage"
CODEX_CLIENT_ID = "app_EMoamEEZ73f0CkXaXp7hrann"
CODEX_TOKEN_URL = "https://auth.openai.com/oauth/token"
CODEX_USAGE_URL = "https://chatgpt.com/backend-api/wham/usage"


@dataclass(frozen=True)
class ClaudeProvider:
    name: str = "claude"
    root_override: Path | None = field(default=None, compare=False)

    @property
    def root(self) -> Path:
        if self.root_override is not None:
            return self.root_override
        root = self.root_from_env(own_environment())
        assert root is not None
        return root

    def root_from_env(self, env: Mapping[str, str]) -> Path | None:
        return environment_root("CLAUDE_CONFIG_DIR", ".claude", env)

    def at(self, root: str) -> ClaudeProvider:
        return ClaudeProvider(root_override=Path(root))

    @property
    def credentials_path(self) -> Path:
        return self.root / ".credentials.json"

    @property
    def config_path(self) -> Path:
        # Stock Claude splits state between ~/.claude/ and ~/.claude.json.
        # CLAUDE_CONFIG_DIR relocates both into the override directory.
        if self.root_override is not None:
            stock = (Path.home() / ".claude").resolve(strict=False)
            if self.root_override.resolve(strict=False) == stock:
                return Path.home() / ".claude.json"
            return self.root_override / ".claude.json"
        if os.environ.get("CLAUDE_CONFIG_DIR"):
            return self.root / ".claude.json"
        return Path.home() / ".claude.json"

    def capture(self) -> JsonObject:
        credentials = read_json(self.credentials_path)
        config = read_json(self.config_path)
        oauth = credentials.get("claudeAiOauth")
        if not isinstance(oauth, dict):
            raise AiAuthError(
                f"missing claudeAiOauth object in {self.credentials_path}; log in first"
            )
        account = config.get("oauthAccount")
        if account is not None and not isinstance(account, dict):
            raise AiAuthError(f"invalid oauthAccount in {self.config_path}")
        return {
            "oauth": oauth,
            "userID": config.get("userID"),
            "account": account,
        }

    def validate_snapshot(self, snapshot: JsonObject) -> None:
        if set(snapshot) != {"oauth", "userID", "account"}:
            raise AiAuthError("Claude profile has an unexpected shape")
        if not isinstance(snapshot["oauth"], dict):
            raise AiAuthError("Claude profile has invalid OAuth data")
        if snapshot["userID"] is not None and not isinstance(snapshot["userID"], str):
            raise AiAuthError("Claude profile has an invalid user ID")
        if snapshot["account"] is not None and not isinstance(snapshot["account"], dict):
            raise AiAuthError("Claude profile has invalid account data")

    def apply(self, snapshot: JsonObject) -> None:
        self.validate_snapshot(snapshot)
        # Account and organization caches must not leak across identities. Claude
        # repopulates these from its bootstrap response on the next launch.
        patch_json(
            self.config_path,
            {
                "userID": snapshot["userID"],
                "oauthAccount": snapshot["account"],
            },
            removals=("orgModelDefaultCache", "penguinModeOrgEnabled"),
        )
        # Patch this file last and only touch claudeAiOauth. mcpOAuth belongs to
        # the shared config directory, not to the Anthropic account.
        patch_json(self.credentials_path, {"claudeAiOauth": snapshot["oauth"]})

    def write_tokens(self, snapshot: JsonObject) -> None:
        self.validate_snapshot(snapshot)
        patch_json(self.credentials_path, {"claudeAiOauth": snapshot["oauth"]})

    def whoami(self) -> str | None:
        account = read_json(self.config_path).get("oauthAccount")
        if not isinstance(account, dict):
            return None
        email = account.get("emailAddress")
        return email if isinstance(email, str) else None

    def refresh_expiry(self, snapshot: JsonObject) -> float | None:
        oauth = snapshot.get("oauth")
        if not isinstance(oauth, dict):
            return None
        raw = oauth.get("refreshTokenExpiresAt")
        if not isinstance(raw, int | float):
            return None
        expiry = float(raw)
        return expiry / 1000 if expiry > 10_000_000_000 else expiry

    def refresh_token(self, snapshot: JsonObject) -> str | None:
        oauth = snapshot.get("oauth")
        token = oauth.get("refreshToken") if isinstance(oauth, dict) else None
        return token if isinstance(token, str) else None

    def access_expiry(self, snapshot: JsonObject) -> float | None:
        oauth = snapshot.get("oauth")
        raw = oauth.get("expiresAt") if isinstance(oauth, dict) else None
        return float(raw) / 1000 if isinstance(raw, int | float) else None

    def refresh(self, snapshot: JsonObject) -> JsonObject:
        oauth = dict(snapshot.get("oauth") or {})
        token = oauth.get("refreshToken")
        if not isinstance(token, str):
            raise AiAuthError("profile has no refresh token")
        response = http_json(
            "POST",
            CLAUDE_TOKEN_URL,
            {},
            {"grant_type": "refresh_token", "refresh_token": token, "client_id": CLAUDE_CLIENT_ID},
        )
        access = response.get("access_token")
        lifetime = response.get("expires_in")
        if not isinstance(access, str) or not isinstance(lifetime, int | float):
            raise AiAuthError("token refresh returned an unexpected shape")
        now_ms = int(time.time() * 1000)
        oauth["accessToken"] = access
        oauth["expiresAt"] = now_ms + int(lifetime * 1000)
        if isinstance(response.get("refresh_token"), str):
            oauth["refreshToken"] = response["refresh_token"]
        if isinstance(response.get("refresh_token_expires_in"), int | float):
            oauth["refreshTokenExpiresAt"] = now_ms + int(
                response["refresh_token_expires_in"] * 1000
            )
        if isinstance(response.get("scope"), str):
            oauth["scopes"] = response["scope"].split()
        return {**snapshot, "oauth": oauth}

    def fetch_usage(self, snapshot: JsonObject) -> JsonObject:
        oauth = snapshot.get("oauth")
        token = oauth.get("accessToken") if isinstance(oauth, dict) else None
        if not isinstance(token, str):
            raise AiAuthError("profile has no access token")
        return http_json(
            "GET",
            CLAUDE_USAGE_URL,
            {
                "Authorization": f"Bearer {token}",
                "anthropic-beta": "oauth-2025-04-20",
            },
        )

    def format_usage(self, usage: JsonObject) -> UsageCells:
        cells: UsageCells = {}
        for key, label in (
            ("five_hour", "5h"),
            ("seven_day", "week"),
            ("seven_day_opus", "opus week"),
            ("seven_day_sonnet", "sonnet week"),
        ):
            window = usage.get(key)
            if isinstance(window, dict):
                text = usage_window(window.get("utilization"), parse_iso(window.get("resets_at")))
                if text:
                    cells[label] = text
        extra = usage.get("extra_usage")
        if isinstance(extra, dict) and extra.get("spend_limit_reached"):
            cells["note"] = "extra usage exhausted"
        return cells


@dataclass(frozen=True)
class CodexProvider:
    name: str = "codex"
    root_override: Path | None = field(default=None, compare=False)

    @property
    def root(self) -> Path:
        if self.root_override is not None:
            return self.root_override
        root = self.root_from_env(own_environment())
        assert root is not None
        return root

    def root_from_env(self, env: Mapping[str, str]) -> Path | None:
        return environment_root("CODEX_HOME", ".codex", env)

    def at(self, root: str) -> CodexProvider:
        return CodexProvider(root_override=Path(root))

    @property
    def auth_path(self) -> Path:
        return self.root / "auth.json"

    def capture(self) -> JsonObject:
        auth = read_json(self.auth_path)
        try:
            self.validate_snapshot(auth)
        except AiAuthError as error:
            raise AiAuthError(f"{error} in {self.auth_path}; log in first") from error
        return auth

    def validate_snapshot(self, snapshot: JsonObject) -> None:
        if "auth_mode" not in snapshot:
            raise AiAuthError("Codex profile has an unexpected shape")

    def apply(self, snapshot: JsonObject) -> None:
        self.validate_snapshot(snapshot)
        atomic_write_json(self.auth_path, snapshot)

    def write_tokens(self, snapshot: JsonObject) -> None:
        self.validate_snapshot(snapshot)
        patch_json(
            self.auth_path,
            {key: snapshot[key] for key in ("tokens", "last_refresh") if key in snapshot},
        )

    def whoami(self) -> str | None:
        auth = read_json(self.auth_path)
        tokens = auth.get("tokens")
        if not isinstance(tokens, dict):
            return None
        token = tokens.get("id_token")
        if not isinstance(token, str):
            return None
        claims = jwt_claims(token)
        email = claims.get("email") if claims else None
        return email if isinstance(email, str) else None

    def refresh_expiry(self, snapshot: JsonObject) -> float | None:
        del snapshot
        return None

    def refresh_token(self, snapshot: JsonObject) -> str | None:
        tokens = snapshot.get("tokens")
        token = tokens.get("refresh_token") if isinstance(tokens, dict) else None
        return token if isinstance(token, str) else None

    def access_expiry(self, snapshot: JsonObject) -> float | None:
        tokens = snapshot.get("tokens")
        token = tokens.get("access_token") if isinstance(tokens, dict) else None
        claims = jwt_claims(token) if isinstance(token, str) else None
        expiry = claims.get("exp") if claims else None
        return float(expiry) if isinstance(expiry, int | float) else None

    def refresh(self, snapshot: JsonObject) -> JsonObject:
        tokens = dict(snapshot.get("tokens") or {})
        token = tokens.get("refresh_token")
        if not isinstance(token, str):
            raise AiAuthError("profile has no refresh token")
        response = http_json(
            "POST",
            CODEX_TOKEN_URL,
            {},
            {
                "client_id": CODEX_CLIENT_ID,
                "grant_type": "refresh_token",
                "refresh_token": token,
                "scope": "openid profile email",
            },
        )
        if not isinstance(response.get("access_token"), str):
            raise AiAuthError("token refresh returned an unexpected shape")
        for key in ("id_token", "access_token", "refresh_token"):
            if isinstance(response.get(key), str):
                tokens[key] = response[key]
        last_refresh = datetime.now(UTC).isoformat().replace("+00:00", "Z")
        return {**snapshot, "tokens": tokens, "last_refresh": last_refresh}

    def fetch_usage(self, snapshot: JsonObject) -> JsonObject:
        tokens = snapshot.get("tokens") or {}
        if not isinstance(tokens.get("access_token"), str):
            raise AiAuthError("profile has no access token")
        headers = {"Authorization": f"Bearer {tokens['access_token']}"}
        if isinstance(tokens.get("account_id"), str):
            headers["ChatGPT-Account-Id"] = tokens["account_id"]
        return http_json("GET", CODEX_USAGE_URL, headers)

    def format_usage(self, usage: JsonObject) -> UsageCells:
        cells: UsageCells = {}
        notes = []
        limits = usage.get("rate_limit")
        if isinstance(limits, dict):
            for key in ("primary_window", "secondary_window"):
                window = limits.get(key)
                if not isinstance(window, dict):
                    continue
                seconds = window.get("limit_window_seconds")
                label = {18000: "5h", 604800: "week"}.get(
                    seconds, f"{seconds / 3600:.0f}h" if isinstance(seconds, int | float) else "?"
                )
                reset_at = window.get("reset_at")
                reset = (
                    datetime.fromtimestamp(reset_at, UTC)
                    if isinstance(reset_at, int | float)
                    else None
                )
                text = usage_window(window.get("used_percent"), reset)
                if text:
                    cells[label] = text
            if limits.get("limit_reached"):
                notes.append("LIMIT REACHED")
        if isinstance(usage.get("plan_type"), str):
            notes.append(usage["plan_type"])
        if notes:
            cells["note"] = ", ".join(notes)
        return cells


PROVIDERS: dict[str, Provider] = {
    "claude": ClaudeProvider(),
    "codex": CodexProvider(),
}


@dataclass(frozen=True)
class ProfileStore:
    provider: Provider

    @property
    def root(self) -> Path:
        return data_root() / self.provider.name

    @property
    def active_state_path(self) -> Path:
        return self.root / ".active.json"

    @property
    def root_key(self) -> str:
        """Canonical live config root used for per-directory active state."""
        return str(self.provider.root.resolve(strict=False))

    def prepare(self) -> None:
        ensure_private_dir(data_root())
        ensure_private_dir(self.root)

    def profile_path(self, name: str) -> Path:
        return self.root / f"{validate_profile_name(name)}.json"

    def active_state(self) -> JsonObject:
        try:
            state = read_json(self.active_state_path)
        except AiAuthError as error:
            if not self.active_state_path.exists() and not self.active_state_path.is_symlink():
                return {"version": PROFILE_VERSION, "roots": {}}
            raise error
        if state.get("version") != PROFILE_VERSION:
            raise AiAuthError("unsupported active-state version")
        roots = state.get("roots")
        if not isinstance(roots, dict):
            raise AiAuthError("active state has an invalid roots mapping")
        for root, name in roots.items():
            if not isinstance(root, str) or not isinstance(name, str):
                raise AiAuthError("active state has an invalid root entry")
            validate_profile_name(name)
        return state

    def active(self) -> str | None:
        roots = self.active_state()["roots"]
        assert isinstance(roots, dict)
        name = roots.get(self.root_key)
        return validate_profile_name(name) if isinstance(name, str) else None

    def set_active(self, name: str) -> None:
        state = self.active_state()
        roots = state["roots"]
        assert isinstance(roots, dict)
        roots[self.root_key] = validate_profile_name(name)
        atomic_write_json(self.active_state_path, state)

    def names(self) -> list[str]:
        if not self.root.exists():
            return []
        names = []
        for path in self.root.glob("*.json"):
            with contextlib.suppress(AiAuthError):
                names.append(validate_profile_name(path.stem))
        return sorted(names)

    def save(self, name: str, snapshot: JsonObject) -> None:
        profile = {
            "version": PROFILE_VERSION,
            "tool": self.provider.name,
            "identity": snapshot,
        }
        atomic_write_json(self.profile_path(name), profile)

    def load(self, name: str) -> JsonObject:
        profile = read_json(self.profile_path(name))
        if profile.get("version") != PROFILE_VERSION:
            raise AiAuthError(f"unsupported profile version for {name}")
        if profile.get("tool") != self.provider.name:
            raise AiAuthError(f"profile {name} belongs to another tool")
        identity = profile.get("identity")
        if not isinstance(identity, dict):
            raise AiAuthError(f"profile {name} has invalid identity data")
        return identity

    @contextlib.contextmanager
    def locked(self) -> Iterator[None]:
        self.prepare()
        lock_path = self.root / ".lock"
        descriptor = os.open(lock_path, os.O_CREAT | os.O_RDWR, 0o600)
        os.fchmod(descriptor, 0o600)
        try:
            fcntl.flock(descriptor, fcntl.LOCK_EX)
            yield
        finally:
            fcntl.flock(descriptor, fcntl.LOCK_UN)
            os.close(descriptor)


def save_profile(provider: Provider, name: str) -> None:
    refuse_running_process(provider)
    store = ProfileStore(provider)
    with store.locked():
        # Re-check: a CLI may have started while we waited for the lock.
        refuse_running_process(provider)
        refuse_active_elsewhere(store, name)
        snapshot = provider.capture()
        store.save(name, snapshot)
        store.set_active(name)
    print(f"saved {provider.name} profile {name} and marked it active")


def use_profile(provider: Provider, name: str) -> None:
    refuse_running_process(provider)
    store = ProfileStore(provider)
    with store.locked():
        # Re-check: a CLI may have started while we waited for the lock.
        refuse_running_process(provider)
        refuse_active_elsewhere(store, name)
        # Validate the target before updating the outgoing profile.
        target = store.load(name)
        provider.validate_snapshot(target)
        before = provider.capture()
        active = store.active()
        if active is not None:
            # A dangling marker is treated as corruption rather than silently
            # discarding the live identity.
            store.load(active)
            store.save(active, before)
        if active == name:
            store.set_active(name)
            print(f"{provider.name} profile {name} was already active; refreshed its snapshot")
            return
        try:
            provider.apply(target)
            store.set_active(name)
        except BaseException as error:
            try:
                provider.apply(before)
            except BaseException as rollback_error:
                raise AiAuthError(
                    "switch failed and rollback also failed; inspect the live credential "
                    f"files before launching {provider.name}: {rollback_error}"
                ) from error
            raise
    print(f"switched {provider.name} from {active or '(untracked)'} to {name}")


def list_profiles(provider: Provider) -> None:
    store = ProfileStore(provider)
    active = store.active()
    names = store.names()
    if not names:
        print("(no profiles)")
        return
    for name in names:
        marker = "*" if name == active else " "
        print(f"{marker} {name}")
    if active is not None and active not in names:
        print(f"! active marker points to missing profile {active}", file=sys.stderr)


def status(provider: Provider) -> None:
    store = ProfileStore(provider)
    active = store.active()
    live = provider.capture()
    print(f"root: {store.root_key}")
    print(f"active: {active or '(untracked)'}")
    print(f"live: {provider.whoami() or '(email unavailable)'}")
    if active is None:
        print("profile: untracked; save the live identity before switching")
    else:
        try:
            saved = store.load(active)
        except AiAuthError as error:
            print(f"profile: {error}")
        else:
            state = "in sync" if saved == live else "changed since last save"
            print(f"profile: {state}")
    expiry = provider.refresh_expiry(live)
    if expiry is not None and expiry <= time.time():
        print("warning: the live refresh token has expired")


def display_path(path: str) -> str:
    home = str(Path.home())
    return "~" + path[len(home) :] if path == home or path.startswith(home + "/") else path


def live_snapshots(provider: Provider, roots: list[str]) -> dict[str, JsonObject | None]:
    """Live credentials per active root; None for a root that cannot be read."""
    snapshots: dict[str, JsonObject | None] = {}
    for root in roots:
        try:
            snapshots[root] = provider.at(root).capture()
        except AiAuthError:
            snapshots[root] = None
    return snapshots


def account_usage(
    provider: Provider,
    store: ProfileStore,
    name: str,
    roots: list[str],
    live: dict[str, JsonObject | None],
    *,
    force_refresh: bool,
) -> JsonObject:
    source = "saved"
    try:
        snapshot = None
        if roots:
            candidates = [(root, value) for root in roots if (value := live.get(root)) is not None]
            if not candidates:
                raise AiAuthError(
                    f"cannot read live credentials in {', '.join(map(display_path, roots))}"
                )
        else:
            snapshot = store.load(name)
            # A profile saved twice under different names shares its refresh
            # token with whichever copy is active; treat it as open too.
            token = provider.refresh_token(snapshot)
            candidates = [
                (root, value)
                for root, value in live.items()
                if value is not None
                and token is not None
                and provider.refresh_token(value) == token
            ]
        if candidates:
            root, snapshot = max(candidates, key=lambda item: provider.access_expiry(item[1]) or 0)
            source = display_path(root) if roots else f"{display_path(root)} (same login)"
            expiry = provider.access_expiry(snapshot)
            if expiry is not None and expiry - EXPIRY_MARGIN <= time.time():
                token = provider.refresh_token(snapshot)
                holders = [
                    holder
                    for holder, value in live.items()
                    if value is not None
                    and token is not None
                    and provider.refresh_token(value) == token
                ]
                # Rotation would log out any CLI still holding the old token, and
                # an unreadable root might be holding it without us knowing.
                unknown = any(value is None for value in live.values())
                busy = [holder for holder in holders if running_processes(provider, Path(holder))]
                if token is None or busy or unknown:
                    if expiry <= time.time():
                        return {"source": source, "error": "stale (that CLI refreshes it)"}
                else:
                    try:
                        snapshot = provider.refresh(snapshot)
                    except AiAuthError as error:
                        return {"source": source, "error": f"needs login ({error})"}
                    # The private profile first: if a live write then fails, the
                    # rotated tokens still survive somewhere.
                    if name in store.names():
                        store.save(name, snapshot)
                    failed = []
                    for holder in holders:
                        try:
                            provider.at(holder).write_tokens(snapshot)
                        except (AiAuthError, OSError):
                            failed.append(display_path(holder))
                        else:
                            live[holder] = snapshot
                    source += " (refreshed)"
                    if failed:
                        return {
                            "source": source,
                            "error": f"refreshed, but could not write {', '.join(failed)}; "
                            "the new tokens are only in the saved profile, so log in again there",
                        }
        else:
            assert snapshot is not None
            expiry = provider.access_expiry(snapshot)
            if force_refresh or expiry is None or expiry - EXPIRY_MARGIN <= time.time():
                try:
                    snapshot = provider.refresh(snapshot)
                except AiAuthError as error:
                    return {"source": source, "error": f"needs login ({error})"}
                store.save(name, snapshot)
                source = "saved (refreshed)"
        return {"source": source, "usage": provider.fetch_usage(snapshot)}
    except AiAuthError as error:
        return {"source": source, "error": str(error)}
    except OSError as error:
        return {"source": source, "error": f"could not write credentials: {error.strerror}"}
    except (AttributeError, KeyError, TypeError, ValueError):
        return {"source": source, "error": "malformed credentials"}


def usage_report(provider: Provider, *, force_refresh: bool) -> dict[str, JsonObject]:
    store = ProfileStore(provider)
    # Hold the lock throughout so a concurrent `use` cannot activate a profile
    # between the active-state read and a refresh of its saved copy.
    with store.locked():
        open_roots: dict[str, list[str]] = {}
        for root, name in sorted(store.active_state()["roots"].items()):
            open_roots.setdefault(name, []).append(root)
        live = live_snapshots(provider, [root for roots in open_roots.values() for root in roots])
        names = store.names()
        names += sorted(set(open_roots) - set(names))
        return {
            name: account_usage(
                provider,
                store,
                name,
                open_roots.get(name, []),
                live,
                force_refresh=force_refresh,
            )
            for name in names
        }


def use_color() -> bool:
    return (
        sys.stdout.isatty() and not os.environ.get("NO_COLOR") and os.environ.get("TERM") != "dumb"
    )


def paint(text: str, style: str, enabled: bool) -> str:
    return f"\x1b[{style}m{text}\x1b[0m" if enabled and text.strip() else text


def percent_style(percent: float) -> str:
    if percent >= 95:
        return "1;31"
    if percent >= 80:
        return "31"
    if percent >= 50:
        return "33"
    return "32"


def print_usage(tools: list[str], *, as_json: bool, force_refresh: bool) -> None:
    reports = {tool: usage_report(PROVIDERS[tool], force_refresh=force_refresh) for tool in tools}
    if as_json:
        print(json.dumps(reports, indent=2, sort_keys=True))
        return
    color = use_color()
    dim, bold = "2", "1"

    # Cells are (plain, painted) pairs so widths ignore escape codes.
    Cell = tuple[str, str]

    def cell(text: str, style: str = "") -> Cell:
        return text, paint(text, style, color) if style else text

    def window_cell(window: Window) -> Cell:
        percent = f"{window.percent:3.0f}%"
        reset = format_reset(window.reset)
        plain = f"{percent}  {reset}".rstrip()
        painted = paint(percent, percent_style(window.percent), color)
        if reset:
            painted += "  " + paint(reset, dim, color)
        return plain, painted

    parsed = {
        tool: {
            name: PROVIDERS[tool].format_usage(result["usage"]) if "usage" in result else None
            for name, result in report.items()
        }
        for tool, report in reports.items()
    }
    columns = ["5h", "week"]
    for rows in parsed.values():
        for cells in rows.values():
            columns += [key for key in cells or {} if key not in columns and key != "note"]

    # Each body row: name, where, one cell per window column, trailing text.
    table: list[tuple[str | None, list[Cell], Cell]] = []
    for tool, report in reports.items():
        table.append((tool, [], cell("")))
        if not report:
            table.append((None, [cell("(no profiles)", dim)], cell("")))
        for name, result in report.items():
            where = result["source"]
            prefix = [cell(name), cell(where, "" if where.startswith("~") else dim)]
            cells = parsed[tool][name]
            if cells is None:
                table.append((None, prefix, cell(result["error"], "33")))
                continue
            windows = [
                window_cell(value) if isinstance(value := cells.get(column), Window) else cell("")
                for column in columns
            ]
            note = cells.get("note")
            table.append((None, prefix + windows, cell(note if isinstance(note, str) else "", dim)))

    header = [cell(""), cell("WHERE", dim), *(cell(column.upper(), dim) for column in columns)]
    body = [cells for tool, cells, _ in table if tool is None]
    widths = [
        max(len(row[index][0]) for row in [header, *body] if index < len(row))
        for index in range(len(header))
    ]

    def render(cells: list[Cell], trailing: Cell) -> str:
        parts = [
            painted + " " * (width - len(plain))
            for (plain, painted), width in zip(cells, widths, strict=False)
        ]
        if trailing[0]:
            # Error text starts where the window columns would.
            parts.append(trailing[1])
        return ("  " + "   ".join(parts)).rstrip()

    print(render(header, cell("")))
    for tool, cells, trailing in table:
        if tool is not None:
            print(paint(tool, bold, color))
        else:
            print(render(cells, trailing))


def add_usage_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--json", action="store_true", help="print raw usage responses")
    parser.add_argument(
        "--refresh",
        action="store_true",
        help="refresh saved tokens of inactive profiles even if unexpired",
    )


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Switch AI CLI accounts while preserving shared local state, "
        "and report their subscription usage.",
    )
    tools = parser.add_subparsers(dest="tool", required=True)
    for tool in PROVIDERS:
        tool_parser = tools.add_parser(tool)
        commands = tool_parser.add_subparsers(dest="command", required=True)
        for command in ("save", "use"):
            command_parser = commands.add_parser(command)
            command_parser.add_argument("name", type=validate_profile_name)
        commands.add_parser("list")
        commands.add_parser("status")
        add_usage_arguments(commands.add_parser("usage"))
    add_usage_arguments(tools.add_parser("usage", help="usage for every profile of both tools"))
    return parser


def main() -> int:
    args = build_parser().parse_args()
    if args.tool == "usage":
        print_usage(list(PROVIDERS), as_json=args.json, force_refresh=args.refresh)
        return 0
    provider = PROVIDERS[args.tool]
    if args.command == "save":
        save_profile(provider, args.name)
    elif args.command == "use":
        use_profile(provider, args.name)
    elif args.command == "list":
        list_profiles(provider)
    elif args.command == "status":
        status(provider)
    elif args.command == "usage":
        print_usage([provider.name], as_json=args.json, force_refresh=args.refresh)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AiAuthError as error:
        print(f"k-ai-auth: {error}", file=sys.stderr)
        raise SystemExit(1) from error
