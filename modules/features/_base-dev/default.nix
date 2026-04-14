{ ... }:

{
  imports = [
    ./options.nix
    ./packages.nix
    ./env-var.nix
    ./direnv.nix
    ./zsh.nix
    ./git.nix
    ./difftastic.nix
    ./rust.nix
    ./npm.nix
    ./python.nix
  ];

  programs.home-manager.enable = true;
}
