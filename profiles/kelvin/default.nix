{ inputs, lib, ... }:

{
  imports = [
    inputs.self.homeModules.base-dev
    inputs.self.homeModules.identity
    inputs.self.homeModules.ai-skills
    inputs.self.homeModules.nixvim
    inputs.self.homeModules.kitty
    inputs.self.homeModules.claude-hooks
    inputs.self.homeModules.email
    inputs.self.homeModules.homeshick
    ./apps
    ./packages.nix
    ./zsh.nix
  ];

  home = {
    # Home-manager bootstrap for the dotfiles targets (was in the old
    # identity.nix, which conflated git identity with home identity). Kept here,
    # not in homeModules.identity, so external consumers (castle) that set their
    # own username/stateVersion aren't forced onto these.
    username = lib.mkDefault "kelvin";
    stateVersion = lib.mkDefault "23.05";
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
