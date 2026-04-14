{ ... }: {
  flake.homeModules.git = { pkgs, lib, config, ... }: {
    programs.git = {
      enable = true;
      settings = {
        push.default = "simple";
        pull.rebase = "merges";
        init.defaultBranch = "master";
        color.ui = true;
      };
    };

    home.packages = lib.optionals config.k.heavy [
      pkgs.lazygit
      pkgs.diff-so-fancy
    ];
  };
}
