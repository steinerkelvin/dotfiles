{ pkgs, heavy ? false, ... }:

let username = "kelvin";
in {

  imports = [ ./homeshick.nix ./packages.nix ./zsh.nix ./git.nix ]
    ++ (if heavy then [ ./nvim.nix ] else [ ]);

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
    EDITOR = "nvim";
    VISUAL = "nvim";
    # NPM global installations
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  ## Path / $PATH
  home.sessionPath =
    [ "$HOME/bin" "$HOME/opt/bin" "$HOME/.cargo/bin" "$HOME/.npm-global/bin" "$HOME/node_modules/.bin" "$HOME/.local/bin" ];

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
