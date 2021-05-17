#!/bin/bash

(
set -e

if grep -q -i microsoft /proc/version; then

    echo 1>&2 "You are running on WSL..."

    socket_base="${HOME}/dtach"

    name="syncthing"
    cmd=(syncthing -gui-address="0.0.0.0:8385")

    sok="${socket_base}/${name}"
    if [ ! -e "$sok" ]; then
        echo 1>&2 "starting '${name}' at '${sok}'..."
        dtach -n "$sok" ${cmd[@]}
    fi

fi

)

