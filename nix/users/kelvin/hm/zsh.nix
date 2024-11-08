{ lib, ... }:

let
  shell_scripts = import ../shell { };
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
      nxd = "nix develop --command zsh";
      nxu = "nix flake update";
      nxrb = "sudo nixos-rebuild --flake $(realpath ~/dotfiles)";
      # Exa aliases
      ll = "exa -l";
      la = "exa -l -a";
      # Git aliases
      gff = "git merge --ff-only";
      glogh = "git log --oneline --decorate --graph HEAD";
      tigh = "tig -a HEAD";
      # Kitty aliases
      sshk = "kitty +kitten ssh";
      icatk = "kitty +icat";
      # Homesick/Homeshick aliases
      dtcd = "homeshick cd dotfiles; cd home;";
      # Editor aliases
      h = "hx .";
      # Docker aliases
      dk = "sudo docker";
      docker = "sudo docker";
      dkr = "sudo docker run --rm -it";
      # Cargo aliases
      cgr = "cargo run --";
      # Copilot
      "'??'" = "gh copilot explain";
      # Utils
      "qrprint" = "qrencode -t utf8";
      # Dev
      "pr" = "pnpm run";
      "px" = "pnpm exec";
    };

    initExtra =
      ''
        # Homeshick
        source "$HOME/.homesick/repos/homeshick/homeshick.sh"

        # Utility Shell Functions
        function nxr { nix-shell -p $1 --command $1 }
        function dusort { du -h $@ | sort -h }
      ''
      + lib.strings.concatStrings (lib.attrValues shell_scripts)
    ;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        # "command-not-found"
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
