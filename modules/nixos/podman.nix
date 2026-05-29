# Reusable NixOS module: Podman container runtime with Docker compatibility.
_: {
  flake.nixosModules.podman = { pkgs, ... }: {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true; # /run/podman/docker.sock for testcontainers etc.
      defaultNetwork.settings.dns_enabled = true;
    };
    # docker-compose v2 (Go binary). Use `docker-compose up -d` -- the
    # `docker compose` subcommand form requires the binary to live at a
    # CLI-plugin path; podman's docker shim doesn't honour that lookup.
    # `podman compose` also works (podman 5+ bundles it).
    environment.systemPackages = [ pkgs.docker-compose ];
  };
}
