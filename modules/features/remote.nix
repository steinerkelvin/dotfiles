_: {
  flake.homeModules.remote = { pkgs, ... }: {
    home.packages = [
      # Instant terminal sharing
      pkgs.tmate
    ];
  };
}
