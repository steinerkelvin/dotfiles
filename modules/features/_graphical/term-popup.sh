#!/usr/bin/env bash

# Run an interactive command in a temporary desktop terminal.
# Usage: term-popup [--] COMMAND [ARG...]
#
# Future work: optionally host commands in a tmux popup when invoked from tmux.
# Always use a desktop window for now, regardless of the caller's terminal.

set -euo pipefail

if [[ ${1-} == --help || ${1-} == -h ]]; then
    printf 'Usage: term-popup [--] COMMAND [ARG...]\n'
    exit 0
fi
if [[ ${1-} == -- ]]; then
    shift
fi
if (( $# == 0 )); then
    printf 'Usage: term-popup [--] COMMAND [ARG...]\n' >&2
    exit 2
fi

# Nix supplies Kitty's path; reuse the Bash interpreter selected by the shebang.
# Neither changes the child's PATH.
# Pass argv directly: shell expressions require an explicit `sh -c` command.
# shellcheck disable=SC2016 # The inner shell expands these variables.
exec @kitty@ --class term-popup --directory "$PWD" "$BASH" -c '
    "$@"
    status=$?
    if (( status != 0 && status != 130 )); then
        printf "\nCommand exited with status %s. Press Enter to close.\n" "$status" >&2
        IFS= read -r </dev/tty || true
    fi
    exit "$status"
' term-popup "$@"
