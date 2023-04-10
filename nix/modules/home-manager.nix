{ config, pkgs, ... }:

let
  basePkgs = import <nixpkgs> {};
  baseFetchFromGitHub = basePkgs.fetchFromGitHub;

  # The desired commit hash of the home-manager channel
  homeManagerCommit = "440faf5ae472657ef2d8cc7756d77b6ab0ace68d";

  # Fetch the home-manager channel source
  homeManagerSrc = baseFetchFromGitHub {
    owner = "nix-community";
    repo = "home-manager";
    rev = homeManagerCommit;
    sha256 = "2vgxK4j42y73S3XB2cThz1dSEyK9J9tfu4mhuEfAw68=";
  };
in
{
  imports =
    let
      # Import the home-manager module
      homeManagerNixos = import "${homeManagerSrc.outPath}/nixos";
    in [
      homeManagerNixos
    ];
}
