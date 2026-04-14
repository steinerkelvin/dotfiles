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
  };
}
