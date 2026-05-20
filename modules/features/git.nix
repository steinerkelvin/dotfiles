_: {
  flake.homeModules.git = { pkgs, lib, config, ... }: {
    programs.git = {
      enable = true;
      # Large file storage
      lfs.enable = true;
      settings = {
        # Push current branch to its upstream tracking branch only
        push.default = "simple";
        # Rebase on pull, preserving merge commits
        pull.rebase = "merges";
        init.defaultBranch = "master";
        color.ui = true;
        # Submodule ergonomics. The parent repo is the source of truth for
        # which submodule commits are checked out; these make that state
        # visible at the moments mistakes usually happen. See
        # steinerkelvin/dotfiles#12 for the matching `git-sub` tooling.
        # Recurse into submodules for checkout/pull/switch/reset (NOT clone --
        # git excludes clone; use `git cloner` or the consumer repo's devshell
        # shellHook for first-time init).
        submodule.recurse = true;
        # status/diff surface submodule state instead of an opaque gitlink line.
        status.submoduleSummary = true;
        diff.submodule = "log";
        # Refuse to push a parent commit that references submodule commits not
        # reachable from a configured remote (the core footgun gate).
        push.recurseSubmodules = "check";
        # Fetch submodule commits on demand when parent pointers move.
        fetch.recurseSubmodules = "on-demand";
        alias = {
          # Explicit difftastic diff shortcut
          difft = "!git -c diff.external=difft diff";
          # Recursive clone (global config can't auto-recurse `clone`).
          cloner = "clone --recurse-submodules";
        };
      };
    };

    # Delta: syntax-highlighting pager for git output
    programs.delta = {
      enable = true;
      enableGitIntegration = false;
    };

    # Difftastic: structural diffs for regular `git diff`
    programs.difftastic = {
      enable = true;
      git.enable = true;
    };

    home.packages = [
      # GitHub CLI
      pkgs.gh
      # Text-mode git browser
      pkgs.tig
      # Terminal UI for git
      pkgs.lazygit
    ];
  };
}
