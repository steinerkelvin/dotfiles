_: {
  flake.homeModules.rust = { pkgs, ... }: {
    home.packages = [ pkgs.rustup ];
    home.sessionPath = [ "$HOME/.cargo/bin" ];
  };
}
