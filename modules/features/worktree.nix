_: {
  # worktrunk (`wt`): git worktree manager built for parallel agent workflows.
  # https://worktrunk.dev -- switch/list/remove/merge with a local-CI merge gate
  # (pre-merge hooks block the merge), an fzf picker, and `copy-ignored` to seed
  # a fresh worktree with the main tree's gitignored build caches / deps.
  #
  # Packaged from nixpkgs-unstable via the `unstable` overlay (not in stable
  # 25.11). See modules/overlays.nix and the nixpkgs-unstable flake input.
  flake.homeModules.worktree = { pkgs, ... }: {
    home.packages = [ pkgs.worktrunk ];

    # Shell integration. `wt` prints a zsh `wt()` wrapper that intercepts
    # switch/merge to cd the *parent* shell via a temp directive file; without
    # it those commands cannot change the caller's directory. Also registers
    # completions (needs compinit, which oh-my-zsh runs before this block).
    programs.zsh.initContent = ''
      if command -v wt >/dev/null 2>&1; then
        eval "$(${pkgs.worktrunk}/bin/wt config shell init zsh)"
      fi
    '';

    # User config, managed declaratively. Runtime state is unaffected by the
    # read-only symlink: approvals go to approvals.toml, internal data/cache to
    # `wt config state` / `.git/wt/logs/`, none to config.toml. The tradeoff
    # (by design): `wt config create`/`update` and first-run prompt-persistence
    # (skip-*-prompt) can't write through the symlink -- manage this file via
    # Nix instead, or set WORKTRUNK_CONFIG_PATH for a writable location. The
    # shell-integration prompt never fires (initContent already installs it).
    # Global worktree layout stays at the worktrunk default -- sibling
    # `<repo>.<branch>`.
    #
    # kspace overrides to an in-repo `.worktrees/<branch>` layout: agent
    # sessions run under a sandbox whose write-allowlist is the repo cwd, so a
    # sibling worktree (outside cwd) gets write-blocked. `.worktrees/` is a
    # built-in copy-ignored exclude, so it never bloats a `wt step copy-ignored`.
    xdg.configFile."worktrunk/config.toml".text = ''
      [projects."github.com/steinerkelvin/kspace"]
      worktree-path = "{{ repo_path }}/.worktrees/{{ branch | sanitize }}"
    '';
  };
}
