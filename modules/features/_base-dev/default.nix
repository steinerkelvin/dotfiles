{ ... }:

{
  imports = [
    ./options.nix
    ./packages.nix
    ./env-var.nix
    ./direnv.nix
    ./zsh.nix
    ./git.nix
  ];

  programs.home-manager.enable = true;
}
