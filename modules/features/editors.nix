_: {
  flake.homeModules.editors = { pkgs, ... }: {
    home.packages = [
      pkgs.vim
      pkgs.nano
    ];
  };
}
