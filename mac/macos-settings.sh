#!/bin/bash
set -e

show_and_run() {
  echo "$" "$@"
  "$@"
}

# Enable "Use F1, F2, etc. keys as standard function keys" setting

# Why: This allows the function keys to be used as standard function keys
# without needing to hold the 'Fn' key, which is useful for users who
# frequently use these keys for shortcuts or other applications.

show_and_run defaults write -g com.apple.keyboard.fnState -bool true

#

# Disable "Press and hold keys"

# Why: By default, pressing and holding a key will result in a menu of
# accented characters. This can be annoying for users who frequently use
# these keys for shortcuts or prefer them to repeat the character.

show_and_run defaults write -g ApplePressAndHoldEnabled -bool false

#

# Disable Auto Save, Versions and Resume

show_and_run defaults write -g ApplePersistence -bool no

#

# Enable 'Group windows by application' setting

# Why: For some reason, mission control doesn’t like that AeroSpace puts a lot
# of windows in the bottom right corner of the screen. Mission control shows
# windows too small even there is enough space to show them bigger.

show_and_run defaults write com.apple.dock expose-group-apps -bool true && killall Dock

#

# Disable 'Displays have separate Spaces'

# Why: People report all sorts of weird issues related to focus and performance
# when this setting is enabled.
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces

show_and_run defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

#

# Move windows by dragging any part of the window, by holding ctrl + cmd

# @disabled
# show_and_run defaults write -g NSWindowShouldDragOnGesture -bool true

#

# Enable 'Close windows when quitting an app' setting

# Why: Apps start fresh without restoring previous windows. This provides
# cleaner startups, reduces initial memory usage, more predictable app behavior
# and prevents restoration of problematic window states.

show_and_run defaults write -g NSQuitAlwaysCloseWindows -bool true

#

# == Power Management ==

# Set display turn off to 2 minutes on battery
show_and_run sudo pmset -b displaysleep 2

# Set system sleep to 10 minutes on battery
show_and_run sudo pmset -b sleep 10

# Set display turn off to 10 minutes on charger
show_and_run sudo pmset -c displaysleep 10

# Set system sleep to never on charger
show_and_run sudo pmset -c sleep 0

# == Hostname ==

# Check and set the "computer name" and hostname

# Why: By default, the computer name contains the user name. This is to avoid
# the name leaking to the network etc, as well as

show_names() {
  echo "Hostname: $(hostname)"
  echo "Local hostname: $(scutil --get LocalHostName)"
  echo "Computer name: $(scutil --get ComputerName)"
}

echo
show_names

# If on interactive mode, ask for confirmation
if [ -t 0 ]; then
  read -r -p "Are the hot names correct? [y/N] " correct
  if [ "$correct" != "y" ]; then
    read -r -p "Enter new hostname: " new_hostname
    show_and_run scutil --set HostName "$new_hostname"
    show_and_run scutil --set LocalHostName "$new_hostname"
    show_and_run scutil --set ComputerName "$new_hostname"
    show_names
  elif [[ "$correct" == "y" ]]; then
    echo "Not changing hostname"
  fi
else
  echo "Not on interactive mode, not asking for confirmation"
  echo "You can set the hostname manually with:"
  echo "sudo scutil --set LocalHostName 'new-hostname'"
  echo "sudo scutil --set ComputerName 'new-hostname'"
fi

# == Security ==

# Disable Gatekeeper, allowing to run applications from anywhere

# Why: Apps from Homebrew, GitHub, etc. are blocked by Gatekeeper by default.
# Disabling Gatekeeper allows to run these apps without needing to confirm.
# Note: It my need to be confirmed in System Settings > Security & Privacy.

echo
if ! [[ "$(spctl --status)" = *"disabled"* ]]; then
  show_and_run sudo spctl --master-disable
else
  echo "Gatekeeper is already disabled"
fi

#

# Allow accessories to connect automatically without confirmation

# Apparently there's no simple way to do this through the CLI, so we'll just
# instruct the user to do it manually.

echo
echo "To allow accessories to connect automatically, please go to:"
echo "System Preferences > Security & Privacy > Allow accessories to connect"
echo "Set it to 'Automatically When Unlocked'"

#

echo
