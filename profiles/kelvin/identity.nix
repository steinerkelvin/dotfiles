{ lib, pkgs, ... }:

let
  username = "kelvin";
  homeRoot = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  home = {
    username = lib.mkDefault username;
    homeDirectory = lib.mkDefault "${homeRoot}/${username}";
    stateVersion = lib.mkDefault "23.05";
  };
}
