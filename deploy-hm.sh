#!/bin/sh
set -e

OS=$(uname -s)

install_nix() {
  echo "Nix is not installed. Would you like to install it using the Determinate installer? [y/N]"
  read -r response
  case "$response" in
    [yY]|[yY][eE][sS])
      echo "Installing Nix via Determinate installer..."
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
      echo ""
      echo "Nix installed successfully!"
      echo "Please restart your shell or run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
      echo "Then re-run this script."
      exit 0
      ;;
    *)
      echo "Nix installation cancelled. Please install Nix first."
      exit 1
      ;;
  esac
}

# Check if Nix is installed
if ! command -v nix >/dev/null 2>&1; then
  install_nix
fi

if [ "$OS" = "Darwin" ]; then
  echo "Detected macOS - building configuration for Mac"
  nix run github:nix-community/home-manager -- --flake .#mac switch
elif [ "$OS" = "Linux" ]; then
  echo "Detected Linux - building configuration for kelvin"
  nix run github:nix-community/home-manager -- --flake .#kelvin switch
else
  echo "Error: Unsupported operating system: $OS"
  exit 1
fi
