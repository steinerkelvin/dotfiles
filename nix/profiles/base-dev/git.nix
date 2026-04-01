{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      push.default = "simple";
      pull.rebase = "merges";
      init.defaultBranch = "master";
      color.ui = true;
    };
    ignores = [
      "~*"
      "*~"
    ];
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
