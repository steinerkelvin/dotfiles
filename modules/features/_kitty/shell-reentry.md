# `K_SHELL_REENTRY` — Shell Wrapper Re-entry for kitty

A small convention that lets any shell wrapper (docker run, ssh, nix develop,
tmux attach, ...) advertise a command that kitty's "new tab / new window /
new OS window" keybinds should run instead of a fresh host shell, so the new
window lands inside the same wrapped context as the source window.

This document is the contract. Other projects can implement against it
without reading the helper's source.

## Terminology

- **Source window.** The kitty window that was focused when the user hit a
  new-tab/window keybind.
- **Wrapper.** A process that transforms a host shell into a wrapped shell
  (e.g. `docker run` producing a container shell, `ssh` producing a remote
  shell, `nix develop` producing a dev-shell).
- **Re-entry command.** A shell-quoted argv vector that, when execed on
  the host, produces a fresh sibling shell inside the same wrapped context
  as the source window. See "Value format" below -- it is not an arbitrary
  shell command line.

## The contract

A wrapper that wishes to participate does two things:

1. **Set an env var** `K_SHELL_REENTRY` inside the wrapped shell, holding
   the re-entry command. This is informational: used by nested wrappers
   and for manual inspection. Not strictly required for kitty to work.
2. **Publish a kitty user variable** `k_shell_reentry` on the source
   window, holding the same command. kitty's shell-reentry kitten reads
   this variable when a new-window keybind fires.

The user variable is what kitty actually consumes. The env var is the
wire format that makes the convention self-describing.

### How to publish the user variable

From a process that is itself running inside the kitty window (typically
the wrapper script on the host, before it execs into docker / ssh):

```sh
kitten @ --to "$KITTY_LISTEN_ON" set-user-vars --match state:self \
    k_shell_reentry="$REENTRY_COMMAND"
```

This requires:

- `allow_remote_control` in `kitty.conf` to be at least `socket-only`.
- `listen_on` configured so `$KITTY_LISTEN_ON` is populated in the window's
  env.

Both are already the case in this dotfiles setup.

The provided helper script does the same thing with a friendlier interface:

```sh
k-shell-helper publish "$REENTRY_COMMAND"
```

### Clearing

When the wrapper exits, the re-entry command becomes stale (the container
is gone, the ssh session is closed). The wrapper should clear the variable
on exit:

```sh
k-shell-helper clear
# or: kitten @ --to "$KITTY_LISTEN_ON" set-user-vars --match state:self k_shell_reentry=
```

An empty value is treated as "not set" by the kitten.

## Value format

The re-entry value is a **shell-quoted argv vector**, not an arbitrary
shell command. The consumer (kitty's kitten, `k-shell-helper enter`) runs
the value through `shlex.split` and execs the resulting argv directly --
no shell is spawned in between. This means:

- No shell syntax: pipes (`|`), redirects (`>`, `<`), chaining (`&&`,
  `;`), command substitution (`$(...)`), or backgrounding (`&`) will not
  work. They will be passed as literal arguments to the first token.
- No env-prefix form: `FOO=bar zsh` does not set an env var; `FOO=bar`
  becomes argv[0] and exec fails.
- No `cd` prefix, no alias expansion, no login-shell side effects.

Quoting follows POSIX shell rules as implemented by Python's `shlex`.
The chosen semantics are "argv vector, predictable" rather than "shell
command, powerful": wrappers that genuinely need shell features should
quote that themselves by publishing e.g. `sh -lc 'cd /x && zsh'`, making
the shell invocation explicit in the value.

## Handles vs raw argv

Callers can:

- Publish a raw argv:
  `k-shell-helper publish "docker exec -it X zsh -l"`. The value is
  re-parsed with `shlex.split` when the kitten fires.
- Publish a structured handle that the helper knows how to dispatch:
  `k-shell-helper publish-handle docker:X`. The stored value becomes
  `k-shell-helper enter docker:X`, which in turn execs
  `docker exec -it X zsh -l` when run.

Handles keep the stored string short and survive renames of the helper's
internal transport logic. Raw argv is the escape hatch for anything the
helper doesn't natively know.

Known handle schemes:

| Scheme | Body format | Dispatches to |
|---|---|---|
| `docker` | `<container>[#<shell>]` | `docker exec -it <container> <shell> -l` |
| `ssh` | `<target>[#<shell>]` | `ssh -t <target> [<shell> -l]` |
| `nix-develop` | `<abs-path>[#<shell>]` | `nix develop <path> -c <shell>` |
| `nix-shell` | `<abs-path>[#<shell>]` | `nix-shell <path> --run <shell>` |
| `cmd` | shell-quoted argv | executed via `shlex.split` |

Default shell is `zsh`.

## Nested wrappers

Each wrapper publishes its own re-entry command when it takes over the
window. Nested contexts (e.g. `docker exec` inside an `ssh` session)
should publish a composed command that recreates a sibling shell at the
innermost level as seen from the host, e.g.:

```
ssh -t host -- docker exec -it my-sandbox zsh -l
```

"Last wrapper wins" as far as the user variable is concerned; the onus is
on wrappers to publish something that composes through any outer wrappers
they know they are running under. A wrapper can read the current value
(`k-shell-helper show`) before overwriting if it needs to compose.

## End-to-end example (docker)

Host-side wrapper script using the built-in `wrap` subcommand, which
publishes the handle, runs the wrapped command, and always clears the
user variable on exit (including on signal):

```sh
#!/usr/bin/env bash
set -e

container=my-sandbox
image=my-sandbox:latest

exec k-shell-helper wrap "docker:${container}" -- \
    docker run --rm -it \
        --name "${container}" \
        -e "K_SHELL_REENTRY=k-shell-helper enter docker:${container}" \
        "${image}"
```

Now cmd+t from that kitty window runs `docker exec -it my-sandbox zsh -l`,
and the stale user variable is cleared automatically when the container
exits.

> Don't combine `publish-handle` with `trap ... EXIT` and `exec docker run`:
> `exec` replaces the shell, so the trap never fires and the stale re-entry
> command sticks around until the next publish. Use `wrap`, or drop the
> `exec` and call `docker run` normally so the trap can run.

## Fallback behaviour

If the source window has no `k_shell_reentry` user variable (or it is
empty), the kitten behaves exactly like stock kitty:
`launch --cwd=current --type=<tab|window|os-window>`.

## kitty-only today, generalisable tomorrow

The user-variable mechanism is kitty-specific. The `K_SHELL_REENTRY` env
var is terminal-agnostic and is the hook other terminals (wezterm, iTerm2)
could later read via their own extensibility mechanisms. For now the
reference implementation only wires kitty.
