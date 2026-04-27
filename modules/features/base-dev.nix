# Reusable home-manager meta-module: base developer kernel.
# Composes all tool features plus a minimal env baseline.
# Team-neutral by design -- personal layers (AI tooling etc.) live in
# sibling features (see ai-skills.nix).
#
# External consumers can pull individual tools:
#   inputs.kelvin-dotfiles.homeModules.direnv
#   inputs.kelvin-dotfiles.homeModules.zsh
# or take the full kernel:
#   inputs.kelvin-dotfiles.homeModules.base-dev

{ config, ... }: {
  flake.homeModules.base-dev = {
    imports = [
      config.flake.homeModules.nix
      config.flake.homeModules.secrets
      config.flake.homeModules.passage
      config.flake.homeModules.age-plugin-se
      config.flake.homeModules.age-plugin-yubikey
      config.flake.homeModules.sysmon
      config.flake.homeModules.build-tools
      config.flake.homeModules.net
      config.flake.homeModules.shell
      config.flake.homeModules.editors
      config.flake.homeModules.scripting
      config.flake.homeModules.remote
      config.flake.homeModules.net-utils
      config.flake.homeModules.file-utils
      config.flake.homeModules.direnv
      config.flake.homeModules.atuin
      config.flake.homeModules.starship
      config.flake.homeModules.zsh
      config.flake.homeModules.git
      config.flake.homeModules.rust
      config.flake.homeModules.npm
      config.flake.homeModules.python
    ];
    home.sessionPath = [ "$HOME/.local/bin" ];
    programs.home-manager.enable = true;
  };
}
