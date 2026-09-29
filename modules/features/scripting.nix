_: {
  flake.homeModules.scripting = { pkgs, ... }: {
    home.packages = [
      # Shell script linter
      pkgs.shellcheck
      # sponge, ts (timestamp lines), chronic, vidir, ifne
      pkgs.moreutils
    ];
  };
}
