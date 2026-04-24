#!/bin/sh
# Bootstrap or apply the home-manager configuration for this machine.
set -eu

# Translate `--backup <ext>` (or `--backup=<ext>`) into the env var the
# generated activation script actually reads. `./result/activate` is not
# the home-manager CLI wrapper, so it doesn't parse `-b` / `--backup`
# itself — only HOME_MANAGER_BACKUP_EXT. Everything after `--` is passed
# through verbatim for activate.
while [ $# -gt 0 ]; do
  case "$1" in
    --backup)
      if [ $# -lt 2 ]; then
        echo "Error: --backup requires an argument" >&2
        exit 2
      fi
      export HOME_MANAGER_BACKUP_EXT="$2"
      shift 2
      ;;
    --backup=*)
      export HOME_MANAGER_BACKUP_EXT="${1#--backup=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      echo "Usage: $0 [--backup <ext>] [-- <activate-args>...]" >&2
      exit 2
      ;;
  esac
done

repo_dir=$(
  CDPATH='' cd -- "$(dirname -- "$0")"
  pwd
)

# Ensure Nix is installed.
# shellcheck source=bootstrap-nix.sh
. "$repo_dir/bootstrap-nix.sh"

case "$(uname -s)" in
  Darwin)
    target="satsuki"
    ;;
  Linux)
    target="linux"
    ;;
  *)
    echo "Error: unsupported operating system: $(uname -s)"
    exit 1
    ;;
esac

echo "Activating home-manager profile ${target} from ${repo_dir}"
cd "${repo_dir}"
nix build "path:${repo_dir}#homeConfigurations.${target}.activationPackage"
# `${1+"$@"}` — don't expand `"$@"` at all when there are zero positional
# args, because bash-in-POSIX-mode (/bin/sh on macOS) tries to read `$@`
# and trips `set -u` with "@: unbound variable" on the bracketed form.
"${repo_dir}/result/activate" ${1+"$@"}
