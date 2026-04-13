{ ... }:

let
  shellScripts = {
    try-echo = builtins.readFile ./shell/try-echo.sh;
    vscode-remote = builtins.readFile ./shell/vscode-remote.sh;
  };
in
{
  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      directory.truncate_to_repo = false;

      # Explicit format -- only these modules render
      format = "$directory$git_branch$git_status$python$cmd_duration$line_break$jobs$character";

      # Git branch: not bold
      git_branch.style = "purple";

      # Git status: no brackets, not bold, yellow
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "yellow";
      };

      # Python: venv only, no version, not bold
      python = {
        format = "[($virtualenv)]($style) ";
        style = "cyan";
      };
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      # Shell aliases
      rmr = "rm -r";
      dusm = "du -hs";
      bath = "bat --style=header-filename,grid --decorations=always";
      colon2line = "tr ':' '\n'";
      # Nix aliases
      nxs = "nix-shell --command zsh";
      nxd = "nix develop --command zsh";
      nxu = "nix flake update";
      # Git aliases
      gff = "git merge --ff-only";
      glff = "git pull --ff-only";
      glogh = "git log --oneline --decorate --graph HEAD";
      tigh = "tig -a HEAD";
      # Dev aliases
      j = "just";
      jl = "just --list";
      # Editor aliases
      c = "code .";
      h = "hx .";
      zd = "zeditor .";
      ## Cargo aliases
      cgr = "cargo run --";
      ## Pnpm
      p = "pnpm";
      pr = "pnpm run";
      px = "pnpm exec";
      ## Bun
      b = "bun";
      br = "bun run";
      bx = "bun x";
      ## Docker aliases
      dk = "sudo docker";
      dkr = "sudo docker run --rm -it";
      dokrun = "sudo docker run --rm -it";
      # Eza aliases
      ll = "eza -l --group-directories-first";
      la = "eza -l -a --group-directories-first";
      # Kitty aliases
      sshk = "kitty +kitten ssh";
      icatk = "kitty +icat";
      # Claude
      cc = "claude";
      ccc = "claude --continue";
      ccmo = "claude --model";
    };

    initContent =
      ''
        # Utility Shell Functions
        function nxr { nix-shell -p $1 --command $1 }
        function dusort { du -h $@ | sort -h }

        # Unalias commands
        unalias gk 2>/dev/null || true
        unalias gke 2>/dev/null || true
      ''
      + builtins.concatStringsSep "" (builtins.attrValues shellScripts)
    ;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "sudo"
        "zoxide"
        "git"
        "fzf"
        "rust"
        "pip"
        "httpie"
      ];
    };
  };
}
