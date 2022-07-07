#!/bin/sh
# ^ this is for shellcheck

check_command () { command -v "$1" >/dev/null }

. "${HOME}/config/antigen.zsh"

# Load the oh-my-zsh's library.
antigen use oh-my-zsh
# antigen use ohmyzsh/ohmyzsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle fzf
antigen bundle git
antigen bundle pip
antigen bundle yarn
antigen bundle command-not-found

# # Codex completion
# antigen bundle tom-doerr/zsh_codex

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
# antigen theme robbyrussell
if check_command starship; then
  eval "$(starship init zsh)"
else
  export AGKOZAK_LEFT_PROMPT_ONLY=1
  export AGKOZAK_BLANK_LINES=1
  antigen theme agkozak/agkozak-zsh-prompt
fi

# Tell Antigen that you're done.
antigen apply

if check_command zoxide; then
  eval "$(zoxide init zsh)"
fi

# # Bind codex completion
# bindkey '^X' create_completion

# move to ~/config ?
file="${HOME}/.homesick/repos/homeshick/homeshick.sh"
if [ -f "$file" ]; then
    . "$file" 
fi

# move to ~/config ?
file="$HOME/.cargo/env" 
if [ -f "$file" ]; then
    . "$file" 
fi

. "$HOME/config/shrc.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && . "${HOME}/.iterm2_shell_integration.zsh"

# Vim mode
bindkey -v
