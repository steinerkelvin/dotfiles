{ pkgs, ... }:

let username = "kelvin";
in {

  imports = [ ./homeshick.nix ./packages.nix ./zsh.nix ./git.nix ./nvim.nix ];

  home.username = username;
  # home.homeDirectory = "/home/${username}";

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;

  # Homemanager
  programs.home-manager.enable = true;

  # Enviroment
  home.sessionVariables = {
    # Nix
    NIXPKGS_ALLOW_UNFREE = "1";
    # Default editors
    EDITOR = "vi -e";
    VISUAL = "nvim";
    # NPM global installations
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  ## Path / $PATH
  home.sessionPath =
    [ "$HOME/bin" "$HOME/opt/bin" "$HOME/.mix/escripts" "$HOME/.cargo/bin" "$HOME/.npm-global/bin" ];

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Secrets
  programs.gpg.enable = true;

  # services.keybase.enable = true;
  # services.kbfs.enable = true;

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
