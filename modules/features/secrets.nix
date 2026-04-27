_: {
  flake.homeModules.secrets = { pkgs, lib, ... }: {
    home.packages = [
      pkgs.gnupg
      pkgs.age
      pkgs.libsecret
      pkgs.pass
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      # Pinentry binary for the gpg-agent on macOS (GUI prompt).
      # Required for `pass` / GPG decrypts until we finish migrating to passage.
      pkgs.pinentry_mac
    ];

    # gpg-agent: Darwin-only for now. Linux home-manager hosts (linux, dev)
    # don't currently use GPG; revisit when they do.
    #
    # 8h cache TTL = one prompt per workday. Tunable.
    services.gpg-agent = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      pinentry.package = pkgs.pinentry_mac;
      defaultCacheTtl = 28800;
      maxCacheTtl = 28800;
    };
  };
}
