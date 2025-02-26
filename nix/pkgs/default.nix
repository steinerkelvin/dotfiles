{ pkgs }:

let
  callPackage = pkgs.callPackage;
in

{
  discord-krisp-patch = callPackage ./discord-krisp-patch { };
  # Disabled due to ALSA dependencies not available on macOS
  # noise-suppression-for-voice = callPackage ./noise-suppression-for-voice { };
}
