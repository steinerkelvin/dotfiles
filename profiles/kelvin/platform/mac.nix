{ config, lib, pkgs, ... }:

{
  imports = [
    ./mac-launch-path.nix
  ];

  home.homeDirectory = lib.mkDefault "/Users/${config.home.username}";

  programs.zsh.initContent = ''
    test -e "/opt/homebrew/bin/brew" && eval "$(/opt/homebrew/bin/brew shellenv)"
  '';

  home.packages = [
    pkgs.coreutils
    pkgs.findutils
    pkgs.gnused
    pkgs.gnugrep
    pkgs.gawk
  ];
}
