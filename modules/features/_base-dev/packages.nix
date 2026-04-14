{ pkgs, config, ... }:

let
  heavyPkgs = [
    # Image utilities
    pkgs.imagemagick
    # Terminal file explorer
    pkgs.yazi
  ];
in
{
  home.packages =
    (if config.k.heavy then heavyPkgs else [ ]) ++
    [
      # Essential
      pkgs.curl
      pkgs.wget
      pkgs.rsync
      pkgs.openssh
      pkgs.moreutils

      # Shell tools
      pkgs.stow
      pkgs.shellcheck
      pkgs.tmate
      pkgs.abduco

      # File utilities
      pkgs.file
      pkgs.tree
      pkgs.dua
      pkgs.unzip
      pkgs.croc

      # Misc
      pkgs.yq
      pkgs.envsubst

      # Utilities
      pkgs.tldr
    ];
}
