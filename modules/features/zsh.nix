_: {
  flake.homeModules.zsh = _: {
    programs.zsh = {
      enable = true;
      # oh-my-zsh's default compinit path calls `compinit -i` and runs
      # a synchronous compaudit on every interactive shell start (~40ms
      # in profile, plus a slower compinit body that re-scans fpath
      # rather than trusting the cached dump). Setting
      # ZSH_DISABLE_COMPFIX=true switches omz to `compinit -u`, which
      # skips the security audit entirely. Trade-off: we lose omz's
      # warning about world-writable directories in $fpath. On a
      # single-user macOS where $fpath only contains nix-store and
      # home-manager paths, that warning has no signal -- the audit
      # has never fired in practice.
      sessionVariables = {
        ZSH_DISABLE_COMPFIX = "true";
      };

      # Shared aliases live in home.shellAliases (modules/features/shell.nix)
      # so they apply identically to zsh and bash.

      initContent = ''
        ${builtins.readFile ./shell-common.sh}

        # just completions
        if command -v just &>/dev/null; then
          source <(just --completions zsh)
        fi
      '';

      oh-my-zsh = {
        enable = true;
        plugins = [
          "sudo"
          "git"
          # zoxide/fzf moved to their own home-manager modules 2026-09-01
          # (modules/features/zoxide.nix, modules/features/fzf.nix) so bash
          # gets the same integration instead of only zsh via oh-my-zsh.
          # Dropped 2026-05-13 after atuin-history audit:
          # - rust (cargo×55, rustup×3 -- cargo ships its own zsh
          #   completion in nixpkgs)
          # - pip (pip×9 -- rare; tab-complete works without)
          # - httpie (http/https/httpie×0 -- never used)
        ];
      };
    };
  };
}
