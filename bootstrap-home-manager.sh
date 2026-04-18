#!/bin/sh
# Bootstrap or apply the home-manager configuration for this machine.
set -eu

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
"${repo_dir}/result/activate"
