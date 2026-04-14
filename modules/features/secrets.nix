{ ... }: {
  flake.homeModules.secrets = { pkgs, lib, config, ... }: {
    home.packages = [
      pkgs.gnupg
      pkgs.age
      pkgs.libsecret
    ] ++ lib.optionals config.k.heavy [
      pkgs.pass
    ];
  };
}
