{ ... }: {
  flake.homeModules.difftastic = { ... }: {
    programs.difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
