_: {
  flake.homeModules.secrets = { pkgs, lib, ... }: {
    home.packages = [
      pkgs.gnupg
      pkgs.age
      pkgs.libsecret
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      # Pinentry for gpg-agent prompts (signed commits, GPG decrypts).
      pkgs.pinentry_mac
    ];

    # gpg-agent: Darwin-only for now. Linux home-manager hosts (linux, dev)
    # don't currently use GPG; revisit when they do.
    #
    # Cache TTL is generous so signed commits don't prompt every time.
    services.gpg-agent = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      pinentry.package = pkgs.pinentry_mac;
      defaultCacheTtl = 28800;
      maxCacheTtl = 28800;
    };
  };
}
