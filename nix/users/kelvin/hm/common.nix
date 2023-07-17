{ pkgs, ... }:

let
  username = "kelvin";
in
{

  imports = [
    ./homeshick.nix
    ./packages.nix
    ./zsh.nix
    ./git.nix
    ./vim.nix
  ];

  home.username = username;
  # home.homeDirectory = "/home/${username}";

  # Nixpkgs
  nixpkgs.config.allowUnfree = true;

  # Homemanager
  programs.home-manager.enable = true;

  # Enviroment
  home.sessionVariables = {
    EDITOR = "vi -e";
    VISUAL = "hx";
  };

  ## Path / $PATH
  home.sessionPath = [
    "$HOME/.mix/escripts"
  ];

  # Direnv
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  # Secrets
  programs.gpg.enable = true;

  # services.keybase.enable = true;
  # services.kbfs.enable = true;

  # Helix

  programs.helix = {
    enable = true;
    settings = {
      editor.auto-pairs = false;
      editor.file-picker.hidden = false;
    };
  };

}
