#!/bin/sh
set -e

OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
  echo "Detected macOS - building configuration for Mac"
  nix run github:nix-community/home-manager -- --flake .#mac switch
else
  echo "Error: This script only supports macOS currently"
  echo "For Linux, use a host-specific configuration"
  exit 1
fi
