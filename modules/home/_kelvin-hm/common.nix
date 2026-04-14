{ pkgs, config, inputs, ... }:

let username = "kelvin";
in {

  imports = [
    inputs.self.homeModules.base-dev
    inputs.self.homeModules.ai-skills
    ./homeshick.nix
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./nvim.nix
  ];

  home.username = username;
  home.sessionPath = [ "$HOME/bin" ];

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
