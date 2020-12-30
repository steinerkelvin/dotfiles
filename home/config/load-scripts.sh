#!/bin/bash

find -L "${SCRIPTS_FOLDER}" -type f -name "*.sh" -print0 | \
    while IFS= read -r -d '' FILE; do
        printf "\n# ==== %s ====\n\n" "${FILE}"
        cat "${FILE}"
        echo
    done | \
    source "/dev/stdin"
