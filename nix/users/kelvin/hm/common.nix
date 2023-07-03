{ pkgs, ... }:

let
  username = "kelvin";
in
{

  imports = [
    ./zsh.nix
    ./git.nix
    ./vim.nix
    ./homeshick.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

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

  # Helix

  programs.helix = {
    enable = true;
    settings = {
      editor.auto-pairs = false;
      editor.file-picker.hidden = false;
    };
  };

}
