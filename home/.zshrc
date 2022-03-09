#!/bin/zsh
source "${HOME}/config/antigen.zsh"

AGKOZAK_LEFT_PROMPT_ONLY=1
AGKOZAK_BLANK_LINES=1

# Load the oh-my-zsh's library.
antigen use oh-my-zsh
# antigen use ohmyzsh/ohmyzsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle fzf
antigen bundle git
antigen bundle pip
antigen bundle command-not-found

# # Codex completion
# antigen bundle tom-doerr/zsh_codex

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
#antigen theme robbyrussell
antigen theme agkozak/agkozak-zsh-prompt

# Tell Antigen that you're done.
antigen apply

# # Bind codex completion
# bindkey '^X' create_completion


# move to ~/config ?
file="${HOME}/.homesick/repos/homeshick/homeshick.sh"
if [ -f "$file" ]; then
    . "$file" 
fi

file="$HOME/.cargo/env" 
if [ -f "$file" ]; then
    . "$file" 
fi

. "$HOME/config/shrc.sh"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
