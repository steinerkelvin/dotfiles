#!/bin/sh
# Ensure Nix is installed, using the Determinate installer if needed.
#
# Intended to be sourced by other bootstrap scripts.
# After sourcing, `nix` is guaranteed to be on PATH (or the script exits).
set -eu

install_nix() {
  echo "Nix is not installed. Would you like to install it using the Determinate installer? [y/N]"
  read -r response
  case "$response" in
    [yY]|[yY][eE][sS])
      echo "Installing Nix via Determinate installer..."
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

      if [ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # Make `nix` available in the current shell when possible.
        # shellcheck source=/dev/null
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      if ! command -v nix >/dev/null 2>&1; then
        echo ""
        echo "Nix installed successfully."
        echo "Please restart your shell or run:"
        echo "  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        echo "Then re-run this script."
        exit 0
      fi
      ;;
    *)
      echo "Nix installation cancelled. Please install Nix first."
      exit 1
      ;;
  esac
}

if ! command -v nix >/dev/null 2>&1; then
  install_nix
fi
