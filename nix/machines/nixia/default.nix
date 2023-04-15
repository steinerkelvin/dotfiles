{ lib, config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];
}
