{ config, lib, pkgs, ... }:

{
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  home.packages = [
    pkgs.firefox
  ];
}
