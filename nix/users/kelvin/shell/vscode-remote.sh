#!/bin/bash

rcode() {
  set -e
  host=$1
  shift 1
  folder=$1
  shift 1
  # shellcheck disable=SC2029
  abs_path=$(ssh "$host" "realpath $folder" | tr -d '\n')
  uri="vscode-remote://ssh-remote+$host$abs_path"
  echo >&2 "URI: $uri"
  code --folder-uri="$uri"
}

# -> ZSH autocompletion for `rcode`
# First parameter should complete to SSH host
# Second parameter should complete to folder inside host

#compdef rcode

_rcode() {
  # Complete SSH hosts for the first argument
  if [[ $CURRENT -eq 2 ]]; then
    _ssh_hosts
    return
  fi

  # Complete folders on the remote host for the second argument
  if [[ $CURRENT -eq 3 ]]; then
    # local host
    # host=${words[2]}

    # Fetch directory listing from the remote host
    local -a dirs
    dirs=(\~/code)

    _describe 'remote directories' dirs
    return
  fi
}

# Load the zsh completion system and register the completion function
#autoload -U compinit && compinit
compdef _rcode rcode
