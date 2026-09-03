_: {
  flake.homeModules.shell = { pkgs, ... }: {
    # Shell-agnostic aliases -- home-manager applies these to zsh, bash, and
    # fish uniformly. Moved out of programs.zsh.shellAliases 2026-09-01 so
    # bash gets them too without duplication.
    home.shellAliases = {
      # Shell aliases
      rmr = "rm -r";
      dusm = "du -hs";
      bath = "bat --style=header-filename,grid --decorations=always";
      colon2line = "tr ':' '\n'";
      # Nix aliases
      nxs = "nix-shell --command zsh";
      nxd = "nix develop --command zsh";
      nxu = "nix flake update";
      # Git aliases. The oh-my-zsh git plugin (modules/features/zsh.nix)
      # defines ~250 of these but only for zsh, so bash got none of them.
      # Ported 2026-09-03 from an atuin usage audit -- the same method that
      # trimmed the plugin list on 2026-05-13. Definitions match oh-my-zsh
      # verbatim, so it doesn't matter which one wins under zsh.
      g = "git";
      gst = "git status";
      ga = "git add";
      gno = "git add --intent-to-add";
      gnoa = "git add --intent-to-add .";
      gc = "git commit --verbose";
      "gc!" = "git commit --verbose --amend";
      gd = "git diff";
      gdca = "git diff --cached";
      gl = "git pull";
      glff = "git pull --ff-only";
      gf = "git fetch";
      gp = "git push";
      gpd = "git push --dry-run";
      gb = "git branch";
      gbd = "git branch --delete";
      gco = "git checkout";
      gsw = "git switch";
      grs = "git restore";
      grb = "git rebase";
      gff = "git merge --ff-only";
      gmff = "git merge --ff-only";
      glog = "git log --oneline --decorate --graph";
      glogh = "git log --oneline --decorate --graph HEAD";
      gsts = "git stash show --patch";
      gclean = "git clean --interactive -d";
      gpristine = "git reset --hard && git clean --force -dfx";
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
      # Claude shortcuts
      cl = "claude";
      clc = "claude --continue";
      clm = "claude --model";
    };

    home.packages = [
      # Fuzzy finder
      pkgs.fzf
      # Modern ls replacement
      pkgs.eza
      # Fast grep replacement
      pkgs.ripgrep
      # Smart cd
      pkgs.zoxide
      # Better cat
      pkgs.bat
      # Fast find
      pkgs.fd
      # JSON processor
      pkgs.jq
      # YAML processor
      pkgs.yq
      # Terminal multiplexer
      pkgs.tmux
      # Directory tree viewer
      pkgs.tree
      # Community man pages
      pkgs.tlrc
      # Pager (used by git, man, etc; missing in minimal containers like k-sandbox)
      pkgs.less
    ];
  };
}
