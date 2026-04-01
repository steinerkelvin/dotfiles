{ pkgs, ... }:

{
  home.packages = [
    # Personal utilities
    pkgs.todoist
    pkgs.qrencode
    pkgs.stc-cli # Syncthing CLI (`stc` command)
    pkgs.pciutils
    pkgs.nixos-option
  ];
}
