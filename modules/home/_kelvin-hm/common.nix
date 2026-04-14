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

  home = {
    username = username;
    sessionPath = [ "$HOME/bin" ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
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
