# Reusable NixOS module: Tailscale VPN.
_: {
  flake.nixosModules.tailscale = {
    services.tailscale.enable = true;
  };
}
