#!/bin/sh
# Bootstrap or apply the nix-darwin configuration for this machine.
#
# On first run, uses `nix run nix-darwin` to bootstrap.
# On subsequent runs, uses `darwin-rebuild` directly.
set -eu

repo_dir=$(
  CDPATH='' cd -- "$(dirname -- "$0")"
  pwd
)

if ! command -v nix >/dev/null 2>&1; then
  echo "Error: nix is not installed. Run ./bootstrap-home-manager.sh first." >&2
  exit 1
fi

cd "$repo_dir"

if command -v darwin-rebuild >/dev/null 2>&1; then
  echo "Applying nix-darwin configuration..."
  darwin-rebuild switch --flake .
else
  echo "Bootstrapping nix-darwin..."
  nix run nix-darwin -- switch --flake .
fi
