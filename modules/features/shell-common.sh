# Shared interactive-shell content, sourced by both zsh (modules/features/zsh.nix)
# and bash (modules/features/bash.nix). Plain POSIX -- no zsh-isms allowed here.

# Utility Shell Functions
function nxr { nix-shell -p $1 --command $1; }
function dusort { du -h $@ | sort -h; }

# Unalias commands
unalias gk 2>/dev/null || true
unalias gke 2>/dev/null || true
