#!/bin/sh
set -x # print commands

# enable 'Use F1, F2, etc. keys as standard function keys' setting

# Why: This allows the function keys to be used as standard function keys
# without needing to hold the 'Fn' key, which is useful for users who
# frequently use these keys for shortcuts or other applications.

defaults write -g com.apple.keyboard.fnState -bool true

#

# enable 'Group windows by application' setting

# Why: For some reason, mission control doesn’t like that AeroSpace puts a lot
# of windows in the bottom right corner of the screen. Mission control shows
# windows too small even there is enough space to show them bigger.

defaults write com.apple.dock expose-group-apps -bool true && killall Dock

#

# disable 'Displays have separate Spaces'

# Why: People report all sorts of weird issues related to focus and performance
# when this setting is enabled.
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces

defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer

#

# Move windows by dragging any part of the window, by holding ctrl + cmd

defaults write -g NSWindowShouldDragOnGesture -bool true

#

# enable 'Close windows when quitting an app' setting

# Why: Apps start fresh without restoring previous windows. This provides
# cleaner startups, reduces initial memory usage, more predictable app behavior
# and prevents restoration of problematic window states.

defaults write -g NSQuitAlwaysCloseWindows -bool true

#

# == Power Management ==

# Set display turn off to 2 minutes on battery
sudo pmset -b displaysleep 2

# Set system sleep to 10 minutes on battery
sudo pmset -b sleep 10

# Set display turn off to 10 minutes on charger
sudo pmset -c displaysleep 10

# Set system sleep to never on charger
sudo pmset -c sleep 0
