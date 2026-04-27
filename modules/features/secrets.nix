_: {
  flake.homeModules.secrets = { pkgs, ... }: {
    home.packages = [
      # age: file encryption used by passage and ad hoc.
      pkgs.age
      # libsecret: desktop secret-service API; unrelated to passage but lives here.
      pkgs.libsecret
    ];
  };
}
