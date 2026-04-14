{ ... }: {
  flake.homeModules.atuin = { ... }: {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
        invert = true;
      };
    };
  };
}
