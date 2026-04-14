{ lib, ... }:

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
      + builtins.readFile ./dt.sh
      + builtins.readFile ./vscode-remote.sh
    ;
  };
}
