{ pkgs }:

let
  callPackage = pkgs.callPackage;
in

{
  noise-suppression-for-voice = callPackage ./noise-suppression-for-voice { };
}
