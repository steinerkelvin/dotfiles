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

  # GPG kept for commit signing (and any ad-hoc GPG decrypt of legacy material).
  # Pass is gone -- see modules/features/passage.nix.
  programs.gpg.enable = true;
}
