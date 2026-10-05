_: {
  flake.homeModules.remote = { pkgs, ... }: {
    home.packages = [
      pkgs.openssh
      pkgs.mosh
      # Instant terminal sharing
      pkgs.tmate
    ];
  };
}
