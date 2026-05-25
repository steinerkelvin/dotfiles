# Reusable NixOS module: microVM host bridge — systemd-networkd bridge netdev,
# tap matching (vm-*), and NAT to the internet. The per-VM addresses live in the
# private host config; this module owns only the generic bridge plumbing.
#
#   features.microvm-bridge = {
#     enable = true;
#     hostAddr = "10.0.0.1/24";   # host-side address on the bridge
#   };
_: {
  flake.nixosModules.microvm-bridge =
    { config, lib, ... }:
    let
      cfg = config.features.microvm-bridge;
    in
    {
      options.features.microvm-bridge = {
        enable = lib.mkEnableOption "microVM host bridge (netdev + tap + NAT)";

        bridge = lib.mkOption {
          type = lib.types.str;
          default = "microvm";
          description = "Bridge interface name.";
        };

        hostAddr = lib.mkOption {
          type = lib.types.str;
          example = "10.0.0.1/24";
          description = "Host-side address on the bridge, in CIDR notation.";
        };
      };

      config = lib.mkIf cfg.enable {
        systemd.network = {
          netdevs."10-microvm".netdevConfig = {
            Kind = "bridge";
            Name = cfg.bridge;
          };

          networks = {
            "10-microvm" = {
              matchConfig.Name = cfg.bridge;
              networkConfig.Address = [ cfg.hostAddr ];
              networkConfig.DHCPServer = false;
            };
            "11-microvm-tap" = {
              matchConfig.Name = "vm-*";
              networkConfig.Bridge = cfg.bridge;
            };
          };
        };

        # NAT from the microvm bridge to the internet (any outbound interface)
        networking.nat = {
          enable = true;
          internalInterfaces = [ cfg.bridge ];
        };
      };
    };
}
