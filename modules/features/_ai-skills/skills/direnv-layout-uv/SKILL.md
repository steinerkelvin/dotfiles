---
name: direnv-layout-uv
description: Use a custom direnv `layout_uv()` helper for uv workspaces instead of `source .venv/bin/activate`
---

# direnv `layout_uv` for uv Workspaces

Use this pattern when a repo uses `direnv` plus `uv` and needs a project-local
virtualenv without shell activation scripts.

## Rule

Do not use:

```bash
source .venv/bin/activate
```

For `direnv`, prefer a custom `layout_uv()` function in
`~/.config/direnv/direnvrc`, then use `layout uv` from the project `.envrc`.

## Why

- `source activate` mutates shell state in ways direnv does not track cleanly
- `PATH_add` plus explicit exports is lighter and reversible
- `watch_file` lets direnv reload when `pyproject.toml` or `uv.lock` changes
- `UV_PROJECT_ENVIRONMENT` keeps `uv sync` and `uv run` pointed at the same
  `.venv`

## Global direnv helper

Add this to `~/.config/direnv/direnvrc`:

```bash
layout_uv() {
    VIRTUAL_ENV="$PWD/.venv"

    if [[ ! -d "$VIRTUAL_ENV" ]]; then
        log_status "creating venv at $VIRTUAL_ENV"
        uv venv "$VIRTUAL_ENV"
    fi

    export VIRTUAL_ENV
    export UV_PROJECT_ENVIRONMENT="$VIRTUAL_ENV"
    PATH_add "$VIRTUAL_ENV/bin"

    if [[ -f pyproject.toml ]]; then
        watch_file pyproject.toml
        watch_file uv.lock
        uv sync --quiet 2>/dev/null || log_error "uv sync failed"
    fi
}
```

## Project `.envrc`

```bash
use flake
layout uv
```

If the environment does not come from Nix, make sure `uv` is already on `PATH`
before `layout uv` runs.
