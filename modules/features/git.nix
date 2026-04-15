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
        alias = {
          # Explicit difftastic diff shortcut
          difft = "!git -c diff.external=difft diff";
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
