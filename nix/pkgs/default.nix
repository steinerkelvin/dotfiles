{ pkgs }:

let
  callPackage = pkgs.callPackage;
in

{
  discord-krisp-patch = callPackage ./discord-krisp-patch { };
  noise-suppression-for-voice = callPackage ./noise-suppression-for-voice { };
}
