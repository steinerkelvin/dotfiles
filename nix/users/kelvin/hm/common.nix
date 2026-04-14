{ pkgs, config, ... }:

let username = "kelvin";
in {

  imports = [
    ../../../home/base-dev
    ../../../home/dev/ai-skills.nix
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

  # Claude Code
  programs.claude-code = {
    enable = true;
    enableStructuralSearch = true;
    enableCodeStats = true;
  };
}
