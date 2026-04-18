#!/bin/sh
# Bootstrap or apply the nix-darwin configuration for this machine.
#
# Uses the flake-locked darwin-rebuild to avoid version skew
# between the flake.lock and whatever is on PATH.
set -eu

repo_dir=$(
  CDPATH='' cd -- "$(dirname -- "$0")"
  pwd
)

# Ensure Nix is installed.
# shellcheck source=bootstrap-nix.sh
. "$repo_dir/bootstrap-nix.sh"

cd "$repo_dir"

echo "Applying nix-darwin configuration..."
nix run "path:$repo_dir#darwin-rebuild" -- switch --flake "$repo_dir"
