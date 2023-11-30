{ lib, ... }:

let
  shellScripts = import ../shell { };
in
{
  # Zsh

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory.truncate_to_repo = false;
    };
  };

  programs.zsh = {
    # vim mode?
    enable = true;
    shellAliases = {
      # Shell aliases
      rmr = "rm -r";
      dusm = "du -hs";
      # Nix aliases
      nxs = "nix-shell --command zsh";
      nxrb = "nixos-rebuild --flake $(realpath ~/dotfiles)";
      sunxrb = "sudo nixos-rebuild --flake $(realpath ~/dotfiles)";
      # Exa aliases
      ll = "exa -l";
      la = "exa -l -a";
      # Git aliases
      glogh = "git log --oneline --decorate --graph HEAD";
      tigh = "tig -a HEAD";
      # Kitty aliases
      sshk = "kitty +kitten ssh";
      icatk = "kitty +icat";
      # Homesick/Homeshick aliases
      dtcd = "homeshick cd dotfiles; cd home;";
      # Editor aliases
      h = "hx .";
    };

    initExtra =
      ''
        # Homeshick
        source "$HOME/.homesick/repos/homeshick/homeshick.sh"

        PATH="$HOME/bin:$PATH"

        # Utility Shell Functions
        function nxr { nix-shell -p $1 --command $1 }
        function dusort { du -h $@ | sort -h }
      ''
      + lib.strings.concatStrings (lib.attrValues shellScripts)
    ;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        "command-not-found"
        "zoxide"
        "git"
        "fzf"
        "rust"
        "pip"
        "yarn"
        "httpie"
      ];
      # TODO:
      # - zsh-users/zsh-autosuggestions
      # - zsh-users/zsh-syntax-highlighting
    };
  };
}
