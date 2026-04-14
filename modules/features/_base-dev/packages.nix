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
      # Network essentials
      pkgs.openssh
      pkgs.curl
      pkgs.wget
      pkgs.rsync

      # File utilities
      pkgs.unzip
      pkgs.dua
      pkgs.croc
    ];
}
