#!/bin/bash

export SCRIPTS_FOLDER="${HOME}/config/profile.d"

# . "${HOME}/config/load-scripts.sh"

output_file="${SCRIPTS_FOLDER}.output"
${HOME}/config/merge-scripts.sh > "${output_file}"
. "${output_file}"

unset output_file
unset SCRIPTS_FOLDER
