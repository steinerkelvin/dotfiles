#!/usr/bin/env -S uv run --quiet
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Migrate a `pass` (GPG) password store to `passage` (age).

Idempotent-ish: re-running re-encrypts entries that were already migrated, which
will succeed but doubles touch prompts. Pass --skip-existing to leave already-
migrated entries alone.

Assumes:
  - `pass` works (gpg-agent + pinentry-mac configured)
  - `passage` works (~/.passage/store initialised, .age-recipients populated,
    age-plugin-se identity in ~/.config/passage/identities/)
  - PASSAGE_DIR defaults to ~/.passage; PASSWORD_STORE_DIR to ~/.password-store

Usage:
    uv run scripts/pass-to-passage.py --source ~/.password-store --verify
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
from collections.abc import Iterator
from pathlib import Path


def find_entries(source: Path) -> Iterator[str]:
    """Yield pass entry names (relative paths without `.gpg`)."""
    for path in sorted(source.rglob("*.gpg")):
        rel = path.relative_to(source).with_suffix("")
        # Skip the GPG identity file pass uses for the store itself.
        if str(rel).startswith("."):
            continue
        yield str(rel)


def pass_show(name: str) -> str:
    result = subprocess.run(
        ["pass", "show", name],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"pass show {name!r} failed: {result.stderr.strip()}")
    return result.stdout


def passage_show(name: str) -> str:
    env = os.environ.copy()
    result = subprocess.run(
        ["passage", "show", name],
        capture_output=True,
        text=True,
        check=False,
        env=env,
    )
    if result.returncode != 0:
        raise RuntimeError(f"passage show {name!r} failed: {result.stderr.strip()}")
    return result.stdout


def passage_insert(name: str, content: str) -> None:
    """Insert via `passage insert -m -f` to overwrite without prompting."""
    result = subprocess.run(
        ["passage", "insert", "-m", "-f", name],
        input=content,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise RuntimeError(f"passage insert {name!r} failed: {result.stderr.strip()}")


def passage_has(name: str, store: Path) -> bool:
    return (store / f"{name}.age").exists()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        "--source",
        type=Path,
        default=Path.home() / ".password-store",
        help="pass store root (default: ~/.password-store)",
    )
    parser.add_argument(
        "--passage-store",
        type=Path,
        default=Path.home() / ".passage" / "store",
        help="passage store root (default: ~/.passage/store)",
    )
    parser.add_argument(
        "--verify",
        action="store_true",
        help="re-decrypt with passage and diff against pass plaintext",
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="skip entries that already exist in the passage store",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print what would happen, do not encrypt",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="stop after N entries (useful for smoke tests)",
    )
    args = parser.parse_args()

    if shutil.which("pass") is None:
        print("error: pass not on PATH", file=sys.stderr)
        return 2
    if shutil.which("passage") is None:
        print("error: passage not on PATH", file=sys.stderr)
        return 2
    if not args.source.is_dir():
        print(f"error: source {args.source} not a directory", file=sys.stderr)
        return 2
    if not args.passage_store.is_dir():
        print(f"error: passage store {args.passage_store} not initialised", file=sys.stderr)
        return 2

    entries = list(find_entries(args.source))
    if args.limit is not None:
        entries = entries[: args.limit]

    print(f"found {len(entries)} entries in {args.source}")

    migrated = 0
    skipped = 0
    mismatches: list[str] = []
    failures: list[tuple[str, str]] = []

    for i, name in enumerate(entries, 1):
        print(f"[{i}/{len(entries)}] {name}", flush=True)

        if args.skip_existing and passage_has(name, args.passage_store):
            print("  skip (exists in passage store)")
            skipped += 1
            continue

        try:
            plaintext = pass_show(name)
        except RuntimeError as exc:
            print(f"  FAIL pass: {exc}", file=sys.stderr)
            failures.append((name, str(exc)))
            continue

        if args.dry_run:
            print(f"  dry-run: would encrypt {len(plaintext)} bytes")
            continue

        try:
            passage_insert(name, plaintext)
        except RuntimeError as exc:
            print(f"  FAIL passage: {exc}", file=sys.stderr)
            failures.append((name, str(exc)))
            continue

        if args.verify:
            try:
                roundtrip = passage_show(name)
            except RuntimeError as exc:
                print(f"  FAIL verify: {exc}", file=sys.stderr)
                failures.append((name, str(exc)))
                continue
            if roundtrip != plaintext:
                print("  MISMATCH after re-decrypt", file=sys.stderr)
                mismatches.append(name)
                continue
            print("  ok (verified)")
        else:
            print("  ok")

        migrated += 1

    print()
    print(f"migrated: {migrated}")
    print(f"skipped:  {skipped}")
    print(f"failed:   {len(failures)}")
    if args.verify:
        print(f"mismatch: {len(mismatches)}")

    if failures:
        print("\nfailures:")
        for name, reason in failures:
            print(f"  {name}: {reason}")
    if mismatches:
        print("\nmismatches:")
        for name in mismatches:
            print(f"  {name}")

    if failures or mismatches:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
