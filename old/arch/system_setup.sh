#!/bin/bash

user="kelvin"

# Update Pacman Index
pacman -Sy

# Base packages
pacman -S --needed \
  sudo man vi vim \
  openssh git rsync curl wget \
  arch-install-scripts

useradd -m -G wheel "${user}"
passwd "${user}"

# =====

# Hardware packages
pacman -S --needed \
  networkmanager avahi nss-mdns \
  brightnessctl acpi \
  pulseaudio

# Gui Packages
pacman -S --needed \
  sddm \
  arandr autorandr maim \
  i3-gaps i3status i3blocks dmenu rofi dunst libnotify \
  alacritty kitty \
  xclip \
  nm-connection-editor \
  gnome-keyring libsecret

# =====

# Enable NetworkManager
systemctl enable NetworkManager
systemctl start  NetworkManager

# Enable display manager (login thing)
systemctl enable sddm

echo "Run: systemctl start sddm"
