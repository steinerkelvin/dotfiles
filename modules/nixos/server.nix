# Reusable NixOS module: server profile — sudo timeout, server CLI tooling.
_: {
  flake.nixosModules.server =
    { pkgs, ... }:
    {
      # Extend sudo credential cache — reduces re-prompting during deploys
      security.sudo.extraConfig = "Defaults timestamp_timeout=60";

      environment.systemPackages = [
        pkgs.mosh
        pkgs.iperf3
        pkgs.bubblewrap # sandboxing
        pkgs.socat # socket relay
      ];
    };
}
