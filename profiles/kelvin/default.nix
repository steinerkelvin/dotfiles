{ inputs, ... }:

{
  imports = [
    inputs.self.homeModules.base-dev
    inputs.self.homeModules.ai-skills
    inputs.self.homeModules.claude-hooks
    inputs.self.homeModules.email
    inputs.self.homeModules.homeshick
    ./apps
    ./packages.nix
    ./zsh.nix
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
}
