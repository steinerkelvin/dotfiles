{ pkgs, config, ... }:

{
  home.packages = if config.k.heavy then [
    pkgs.imagemagick
    pkgs.yazi
  ] else [ ];
}
