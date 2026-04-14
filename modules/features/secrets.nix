_: {
  flake.homeModules.secrets = { pkgs, ... }: {
    home.packages = [
      pkgs.gnupg
      pkgs.age
      pkgs.libsecret
      pkgs.pass
    ];
  };
}
