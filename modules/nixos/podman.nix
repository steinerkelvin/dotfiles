# Reusable NixOS module: Podman container runtime with Docker compatibility.
_: {
  flake.nixosModules.podman = {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
