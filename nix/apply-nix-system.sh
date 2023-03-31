#!/usr/bin/env bash

basedir=$(dirname "$0")

if [ -z "$1" ]; then
  echo "Missing first parameter: nix-rebuild command" >&2
  exit 1
else
  command="$1"
  shift 1
fi

(
  cd "${basedir}" || exit 1
  sudo nixos-rebuild -I "nixos-config=./system/configuration.nix" "${command}" 
)
