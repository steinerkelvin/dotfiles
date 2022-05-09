#!/bin/bash
pacman -Sy

pacman -S --needed \
  sudo man vi vim \
  openssh git rsync curl wget \
  networkmanager avahi nss-mdns \
  pulseaudio \
  xdg-user-dirs \
  gnome-keyring libsecret \
  brightnessctl acpi \
  arch-install-scripts

systemctl enable NetworkManager
systemctl start  NetworkManager

# graphical

pacman -S --needed \
  sddm \
  arandr autorandr maim \
  i3-gaps i3status i3blocks dmenu rofi dunst libnotify \
  alacritty kitty \
  xclip \
  nm-connection-editor

systemctl enable sddm

echo "Run:"
echo systemctl start sddm
