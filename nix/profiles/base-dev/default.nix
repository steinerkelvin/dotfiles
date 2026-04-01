{ ... }:

{
  imports = [
    ../../users/kelvin/hm/options.nix
    ./packages.nix
    ./zsh.nix
    ./git.nix
  ];

  # Homemanager
  programs.home-manager.enable = true;

  # Environment
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  ## Path / $PATH
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/opt/bin"
    "$HOME/.cargo/bin"
    "$HOME/.npm-global/bin"
    "$HOME/node_modules/.bin"
    "$HOME/.local/bin"
  ];

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Atuin - command history tool
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 20;
      invert = true;
    };
  };
}
