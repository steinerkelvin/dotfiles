{ inputs, ... }:

{
  imports = [
    inputs.self.homeModules.base-dev
    inputs.self.homeModules.ai-skills
    inputs.self.homeModules.homeshick
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./nvim.nix
  ];

  home = {
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
