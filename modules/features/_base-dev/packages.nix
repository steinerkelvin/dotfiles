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
      pkgs.tmux
      pkgs.tmate
      pkgs.abduco

      # File utilities
      pkgs.file
      pkgs.tree
      pkgs.dua
      pkgs.unzip
      pkgs.croc

      # Misc
      pkgs.jq
      pkgs.yq
      pkgs.envsubst

      # Editors
      pkgs.vim

      # Utilities
      pkgs.tldr
    ];
}
