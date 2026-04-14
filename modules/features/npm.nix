_: {
  flake.homeModules.npm = { pkgs, ... }: {
    home.packages = [
      pkgs.nodejs
      pkgs.bun
    ];
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
