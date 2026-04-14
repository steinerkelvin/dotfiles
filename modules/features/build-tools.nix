_: {
  flake.homeModules.build-tools = { pkgs, ... }: {
    home.packages = [
      pkgs.just
      pkgs.gnumake
      pkgs.pkg-config
      pkgs.openssl
    ];
  };
}
