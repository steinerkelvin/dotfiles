{ pkgs, ... }:

let
  username = "kelvin";
in
{
  imports = [
    ./common.nix
  ];

  home.username = username;
  home.homeDirectory = "/Users/${username}";

  home.stateVersion = "23.05";

  nixpkgs.config.allowUnfree = true;

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
