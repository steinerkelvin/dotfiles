"""
shell_reentry.py - kitty custom kitten.

When bound to a "new tab / new window / new OS window" keybind, this kitten
reads the source window's ``k_shell_reentry`` user variable. If set, the
new window is launched with that command instead of a default shell. If
absent, falls back to a plain ``launch --cwd=current`` so behaviour matches
stock kitty.

Invocation from kitty.conf::

    map cmd+t kitten shell_reentry.py tab
    map cmd+enter kitten shell_reentry.py window
    map cmd+n kitten shell_reentry.py os-window

The first argument selects the launch ``--type=``. Extra arguments are
appended to the underlying ``launch`` call, so you can still pass things
like ``--tab-title foo``.

Protocol: a shell wrapper (docker run, ssh, ...) publishes a user variable
named ``k_shell_reentry`` on its kitty window, typically via the
``k-shell-helper`` script on the host side. See ``shell-reentry.md`` next
to this file for the full protocol description.
"""

from __future__ import annotations

import shlex
from typing import Sequence

from kitty.boss import Boss
from kittens.tui.handler import result_handler


USER_VAR = "k_shell_reentry"


def main(args: list[str]) -> str:
    # No UI. Everything happens in handle_result with access to Boss.
    return ""


def _source_window(boss: Boss, target_window_id: int):
    """Return the window the keybind fired from."""
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        return w
    return boss.active_window


def _reentry_command(window) -> str | None:
    """Read the re-entry command from the source window, or None."""
    if window is None:
        return None
    uvars = getattr(window, "user_vars", None)
    if not uvars:
        return None
    value = uvars.get(USER_VAR)
    if not value:
        return None
    if isinstance(value, bytes):
        value = value.decode("utf-8", "replace")
    value = value.strip()
    return value or None


@result_handler(no_ui=True)
def handle_result(
    args: Sequence[str],
    answer: str,
    target_window_id: int,
    boss: Boss,
) -> None:
    # kitty passes the kitten script path as args[0], then user-supplied
    # arguments from args[1:]. Contrary to a naive reading of the custom-
    # kitten docs, args[0] is NOT the first real argument.
    # https://sw.kovidgoyal.net/kitty/kittens/custom/
    extra = list(args[1:])
    launch_type = "tab"
    if extra and not extra[0].startswith("-"):
        launch_type = extra.pop(0)

    source = _source_window(boss, target_window_id)
    command = _reentry_command(source)

    rc: list[str] = [
        "launch",
        f"--type={launch_type}",
        "--cwd=current",
        *extra,
    ]

    if command:
        # Split with shell-like rules so quoted args survive. Prepend `--`
        # to stop kitty from interpreting command tokens as launch flags.
        try:
            command_argv = shlex.split(command)
        except ValueError:
            command_argv = []
        if command_argv:
            rc.append("--")
            rc.extend(command_argv)

    boss.call_remote_control(source, tuple(rc))
