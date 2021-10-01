#!/bin/bash
pacman -Sy \
  sudo man vi vim \
  openssh git rsync curl wget \
  networkmanager avahi nss-mdns \
  pulseaudio \
  xdg-user-dirs \
  gnome-keyring libsecret \
  brightnessctl acpi \
  arch-install-scripts

systemclt enable NetworkManager
systemclt start  NetworkManager
