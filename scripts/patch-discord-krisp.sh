#!/usr/bin/env nix-shell
#!nix-shell -i bash -p rizin

# from: https://github.com/NixOS/nixpkgs/issues/195512#issuecomment-1546794291

set -e

discord_version="0.0.27"
file="${HOME}/.config/discord/${discord_version}/modules/discord_krisp/discord_krisp.node"

addr=$(rz-find -x '4889dfe8........4889dfe8' "${file}" | head -n1)
rizin -q -w -c "s $addr + 0x12 ; wao nop" "${file}"
