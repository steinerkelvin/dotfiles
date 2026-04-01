{ pkgs, config, ... }:

let username = "kelvin";
in {

  imports = [
    ../../../profiles/base-dev
    ./homeshick.nix
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./nvim.nix
  ];

  home.username = username;

  # Environment
  home.sessionVariables = {
    # Default editors
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Secrets
  programs.gpg.enable = true;
}
