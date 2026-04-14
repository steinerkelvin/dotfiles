{ pkgs }:

let
  callPackage = pkgs.callPackage;
in

{
  discord-krisp-patch = callPackage ./discord-krisp-patch { };
}
