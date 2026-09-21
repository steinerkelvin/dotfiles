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
alone. Close the corresponding CLI before saving or switching a profile.
"""

from __future__ import annotations

import argparse
import base64
import contextlib
import fcntl
import json
import os
import re
import sys
import tempfile
import time
from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Protocol

JsonObject = dict[str, Any]
PROFILE_VERSION = 1
PROFILE_RE = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*\Z")


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


def environment_root(variable: str, default: str) -> Path:
    raw = os.environ.get(variable)
    return Path(raw).expanduser() if raw else Path.home() / default


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


def running_processes(tool: str) -> list[int]:
    """Return matching CLI PIDs using Linux procfs."""
    proc = Path("/proc")
    if not proc.is_dir():
        return []
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
        if not matched:
            try:
                argv0 = (process_dir / "cmdline").read_bytes().split(b"\0", 1)[0]
                executable = Path(os.fsdecode(argv0)).name
                matched = executable == tool or executable.startswith(f"{tool}-")
            except (FileNotFoundError, PermissionError, ProcessLookupError, OSError):
                pass
        if matched:
            matches.append(pid)
    return sorted(matches)


def refuse_running_process(tool: str) -> None:
    matches = running_processes(tool)
    if not matches:
        return
    pids = ", ".join(str(pid) for pid in matches)
    raise AiAuthError(
        f"refusing while {tool} is running (PID {pids}); close it first so it "
        "cannot overwrite the switched credentials"
    )


class Provider(Protocol):
    name: str

    def capture(self) -> JsonObject: ...

    def validate_snapshot(self, snapshot: JsonObject) -> None: ...

    def apply(self, snapshot: JsonObject) -> None: ...

    def whoami(self) -> str | None: ...

    def refresh_expiry(self, snapshot: JsonObject) -> float | None: ...


@dataclass(frozen=True)
class ClaudeProvider:
    name: str = "claude"

    @property
    def root(self) -> Path:
        return environment_root("CLAUDE_CONFIG_DIR", ".claude")

    @property
    def credentials_path(self) -> Path:
        return self.root / ".credentials.json"

    @property
    def config_path(self) -> Path:
        return self.root / ".claude.json"

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


@dataclass(frozen=True)
class CodexProvider:
    name: str = "codex"

    @property
    def root(self) -> Path:
        return environment_root("CODEX_HOME", ".codex")

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

    def whoami(self) -> str | None:
        auth = read_json(self.auth_path)
        tokens = auth.get("tokens")
        if not isinstance(tokens, dict):
            return None
        token = tokens.get("id_token")
        if not isinstance(token, str):
            return None
        try:
            payload = token.split(".")[1]
            payload += "=" * (-len(payload) % 4)
            claims = json.loads(base64.urlsafe_b64decode(payload))
        except (IndexError, ValueError, json.JSONDecodeError):
            return None
        email = claims.get("email") if isinstance(claims, dict) else None
        return email if isinstance(email, str) else None

    def refresh_expiry(self, snapshot: JsonObject) -> float | None:
        del snapshot
        return None


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
    def active_path(self) -> Path:
        return self.root / ".active"

    def prepare(self) -> None:
        ensure_private_dir(data_root())
        ensure_private_dir(self.root)

    def profile_path(self, name: str) -> Path:
        return self.root / f"{validate_profile_name(name)}.json"

    def active(self) -> str | None:
        try:
            if self.active_path.is_symlink():
                raise AiAuthError(f"refusing to read symlink: {self.active_path}")
            name = self.active_path.read_text(encoding="utf-8").strip()
        except AiAuthError:
            raise
        except FileNotFoundError:
            return None
        except OSError as error:
            raise AiAuthError(f"could not read active profile marker: {error}") from error
        return validate_profile_name(name)

    def set_active(self, name: str) -> None:
        atomic_write_text(self.active_path, validate_profile_name(name) + "\n")

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
    refuse_running_process(provider.name)
    store = ProfileStore(provider)
    with store.locked():
        snapshot = provider.capture()
        store.save(name, snapshot)
        store.set_active(name)
    print(f"saved {provider.name} profile {name} and marked it active")


def use_profile(provider: Provider, name: str) -> None:
    refuse_running_process(provider.name)
    store = ProfileStore(provider)
    with store.locked():
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


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Switch AI CLI accounts while preserving shared local state.",
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
    return parser


def main() -> int:
    args = build_parser().parse_args()
    provider = PROVIDERS[args.tool]
    if args.command == "save":
        save_profile(provider, args.name)
    elif args.command == "use":
        use_profile(provider, args.name)
    elif args.command == "list":
        list_profiles(provider)
    elif args.command == "status":
        status(provider)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AiAuthError as error:
        print(f"k-ai-auth: {error}", file=sys.stderr)
        raise SystemExit(1) from error
