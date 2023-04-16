{ config, pkgs, lib, ... }:

let
  machines = (import ../machines) {};
in
{
  imports =
    [ # Include the results of the hardware scan.
      # <home-manager/nixos>
      ../modules
      ../users
      machines.nixia
    ];
}
