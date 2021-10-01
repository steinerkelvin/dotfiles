#!/bin/bash
pacman -Sy

pacman -S \
  sudo man vi vim \
  openssh git rsync curl wget \
  networkmanager avahi nss-mdns \
  pulseaudio \
  xdg-user-dirs \
  gnome-keyring libsecret \
  brightnessctl acpi \
  arch-install-scripts

pacman -S \
  sddm \
  arandr autorandr maim \
  i3-gaps i3blocks dunst 

systemclt enable NetworkManager
systemclt start  NetworkManager
