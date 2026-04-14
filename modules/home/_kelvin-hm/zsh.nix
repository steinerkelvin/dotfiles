{ lib, ... }:

let
  shell_scripts = import ../_kelvin-shell { };
in
{
  programs.zsh = {
    shellAliases = {
      # Personal aliases
      nxrb = "sudo nixos-rebuild --flake $(realpath ~/dotfiles)";
      # Homesick/Homeshick aliases
      dtcd = "homeshick cd dotfiles; cd home;";
      # Utils
      "qrprint" = "qrencode -t utf8 --";
      # Copilot
      "'??'" = "gh copilot explain";
    };

    initContent =
      ''
        # Homeshick
        source "$HOME/.homesick/repos/homeshick/homeshick.sh"
      ''
      + (shell_scripts.dt or "")
    ;
  };
}
