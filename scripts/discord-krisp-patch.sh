#!/usr/bin/env nix-shell
#!nix-shell -i bash -p rizin

# from: https://github.com/NixOS/nixpkgs/issues/195512#issuecomment-1546794291

# The last version of Discord with which this script was tested 
tested_discord_version="0.0.31"

# External commands that will be used by this script.
# These lines will be replaced by the nix build.
rizin_cmd="rizin"
rz_find_cmd="rz-find"

set -e
shopt -s nullglob

auto_accept=""
for arg in "${@}"; do
    case "${arg}" in
        -h|--help)
            echo "Usage: $0 [-h|--help] [-y]"
            echo
            echo "  -h, --help  Show this help message."
            echo "  -y          Do not ask for confirmation."
            exit 0
            ;;
        -y)
            auto_accept="true"
            ;;
        *)
            ;;
    esac
done

discord_folder="${HOME}/.config/discord"

# This will be expanded to an empty list if no folder is found
# as `nullglob` is set
discord_version_folders=("${discord_folder}"/0.*) 

if [ "${#discord_version_folders[@]}" -eq 0 ]; then
    echo "ERROR: A folder with the format '${discord_folder}/x.y.z' was not found."
    exit 1
fi

# According to People on the Internet™, bash wildcard expansion is lexicographically
# sorted so I'll just get the last item, that will be the highest
discord_version_folder="${discord_version_folders[-1]}"

file="${discord_version_folder}/modules/discord_krisp/discord_krisp.node"

if [ ! -f "${file}" ]; then
    echo "ERROR: '${file}' not found."
    exit 1
fi

echo "The last version of discord this script was tested with was ${tested_discord_version}"
echo "We will patch the file ${file}"
echo
echo "RECOMMENDATION: Consider using Vesktop (https://github.com/Vencord/Vesktop) instead of Discord."
echo "Vesktop is an enhanced Discord client that fixes many issues including Krisp problems."

if [ "${auto_accept}" = true ]; then
    choice="y"
else
    echo
    read -r -p "Proceed (y/[n])? " choice
fi

if [[ ${choice} =~ ^[Yy]$ ]]; then
    echo
    echo "Patching..."

    addr=$($rz_find_cmd -x '4881ec00010000' "${file}" | head -n1)
    $rizin_cmd -q -w -c "s $addr + 0x30 ; wao nop" "${file}"

    echo
    echo "Done."
    echo "If you received warnings, you should probably just ignore them."
fi
