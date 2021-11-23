# eval "$(/opt/homebrew/bin/brew shellenv)"
. "$HOME/config/env.sh"
. "$HOME/config/profile.sh"
test -e "/opt/homebrew/bin/brew" && eval "$(/opt/homebrew/bin/brew shellenv)"
