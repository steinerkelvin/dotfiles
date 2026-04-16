{ lib, ... }:

{
  programs.zsh = {
    shellAliases = {
      # Personal aliases
      nxrb = "sudo nixos-rebuild --flake $(realpath ~/dotfiles)";
      # Utils
      "qrprint" = "qrencode -t utf8 --";
      # Copilot
      "'??'" = "gh copilot explain";
    };

    initContent = builtins.readFile ./vscode-remote.sh;
  };
}
