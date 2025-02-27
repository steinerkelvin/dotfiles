#!/bin/bash
# homeshick dotfiles shortcut

function dt {
  if [ -z "$1" ]; then
    echo "Usage: dt COMMAND [ARGS...]"
    echo "Runs homeshick COMMAND on the dotfiles castle"
    echo "Examples:"
    echo "  dt check     # Check for updates"
    echo "  dt pull      # Pull updates"
    echo "  dt link      # Relink dotfiles (symlink aliases)"
    echo "  dt track FILE...   # Add files to dotfiles (paths relative to ~)"
    echo "  dt cd        # Change to dotfiles directory"
    echo "  dt refresh   # Refresh dotfiles (check after specified days)"
    return 1
  fi
  local cmd="$1"
  shift
  homeshick "$cmd" dotfiles "$@"
}

# completion for dt command
function _dt_completion {
  local -a dt_commands
  dt_commands=(
    "check:Check dotfiles for updates"
    "pull:Pull dotfiles updates"
    "link:Relink dotfiles (symlink aliases)"
    "track:Add files to dotfiles (paths relative to ~)"
    "cd:Change to dotfiles directory"
    "refresh:Refresh dotfiles (check after specified days)"
  )
  
  if (( CURRENT == 2 )); then
    _describe -t commands "dt commands" dt_commands
  elif (( CURRENT > 2 )) && [[ "${words[2]}" == "track" ]]; then
    _files
  fi
}
compdef _dt_completion dt