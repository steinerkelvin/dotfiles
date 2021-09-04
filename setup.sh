#!/bin/bash
set -e

username="$USER"
castle_name="dotfiles"
castle_repo="git@github.com:quleuber/${castle_name}.git"

homeshick_path="$HOME/.homesick/repos/homeshick"
homeshick_repo="https://github.com/andsens/homeshick.git"

pkgs=(man)
pkgs+=(vim git stow openssh unzip)
pkgs+=(zsh fzf tmux)
pkgs+=(neovim exa)
pkgs+=(ansible ansible-lint)

# This is a general-purpose function to ask Yes/No questions in Bash, either
# with or without a default answer. It keeps repeating the question until it
# gets a valid answer.
ask() {
    # https://djm.me/ask
    local prompt default reply

    if [ "${2:-}" = "Y" ]; then
        prompt="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        prompt="y/N"
        default=N
    else
        prompt="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$1 [$prompt] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

function ask_to_run() {
    local cmd="$1"
    local flag="$2"
    echo
    if ask "run '${cmd}' ?" "${flag}"; then
        ${cmd}
        return 0
    fi
    return 1
}

ask_to_run "sudo pacman -S --needed ${pkgs[*]}" "Y"

# Installs homeshick
if [ ! -d "$homeshick_path" ] ; then
    git clone "$homeshick_repo" "$homeshick_path"
    printf '\nsource "%s/homeshick.sh"' "${homeshick_path}" >> $HOME/.bashrc
fi

# Loads homeshick
source "${homeshick_path}/homeshick.sh"
# Checks for updates (in case it was already installed)
homeshick check

ask_to_run "homeshick clone $castle_repo" "Y"
ask_to_run "systemctl --user enable ssh-agent" "Y"

