#!/bin/sh

# enable 'Group windows by application' setting

# Why: For some reason, mission control doesn’t like that AeroSpace puts a lot
# of windows in the bottom right corner of the screen. Mission control shows
# windows too small even there is enough space to show them bigger.

defaults write com.apple.dock expose-group-apps -bool true && killall Dock

# disable 'Displays have separate Spaces'

# Why: People report all sorts of weird issues related to focus and performance
# when this setting is enabled.
# https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces

defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer
