_: {
  flake.homeModules.atuin = _: {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        style = "compact";
        inline_height = 20;
        invert = true;
      };
    };
  };
}
