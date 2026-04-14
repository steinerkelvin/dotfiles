{ ... }: {
  flake.homeModules.scripting = { pkgs, ... }: {
    home.packages = [
      # Shell script linter
      pkgs.shellcheck
    ];
  };
}
