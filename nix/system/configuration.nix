{ config, pkgs, lib, ... }:

let
  machines = (import ../machines) {};
in
{
  imports =
    [
      ../modules
      ../users
      machines.nixia
    ];
}
