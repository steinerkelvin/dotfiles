{ ... }:

{
  # Git
  programs.git = {
    enable = true;
    # diff-so-fancy.enable = true;
    difftastic.enable = true;
    extraConfig = {
      user.name = "Kelvin Steiner";
      user.email = "me@steinerkelvin.dev";
      push.default = "simple";
      pull.rebase = "merges";
      # pull.ff = "only";
      init.defaultBranch = "master";
      color.ui = true;
    };
    ignores = [
      "~*"
      "*~"
    ];
  };
}
