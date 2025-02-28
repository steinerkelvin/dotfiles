# try-echo - Run a command and print an error message if it fails
function try-echo() {
  if [ $# -lt 2 ]; then
    echo "Usage: try-echo \"error message\" command [args...]"
    return 1
  fi
  
  local msg="$1"
  shift
  "$@" || echo "$msg"
}

# Completion for try-echo
function _try-echo() {
  local cur prev words cword
  _init_completion || return
  
  # First argument is a message string
  if [ $cword -eq 1 ]; then
    COMPREPLY=()
    return 0
  fi
  
  # After the message, complete like a normal command
  _command_offset 2
}

# Register the completion
complete -F _try-echo try-echo