# Reusable NixOS module: Tailscale VPN.
#
#   features.tailscale = {
#     operator = "alice";        # null = leave tailscaled's stored pref alone
#     advertiseExitNode = true;  # default false
#   };
#
# Both knobs go through `services.tailscale.extraSetFlags`, whose oneshot
# (`tailscaled-set`) runs on every boot unconditionally. `extraUpFlags` would
# not do: the upstream module only wires that up when `authKeyFile` is set, so
# key-authed hosts never get it.
#
# These settings otherwise live only in /var/lib/tailscale/tailscaled.state as
# imperative state -- set once by hand, silently lost to `tailscale up --reset`
# or a rebuild that wipes /var/lib/tailscale. Declaring them here means a
# reinstalled host comes back with the same prefs.
_: {
  flake.nixosModules.tailscale =
    { config, lib, ... }:
    let
      cfg = config.features.tailscale;
    in
    {
      options.features.tailscale = {
        operator = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "alice";
          description = ''
            Unix user allowed to run `tailscale` without sudo. This is a local
            per-machine pref, not a tailnet role. `null` leaves whatever is
            already in tailscaled's state file untouched.
          '';
        };

        advertiseExitNode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Advertise this host as an exit node. Unlike `operator`, this is
            asserted in both directions -- `false` actively withdraws the
            advertisement rather than leaving a stale one in place. Still needs
            one-time route approval in the admin console.
          '';
        };
      };

      config = {
        services.tailscale.enable = true;

        services.tailscale.extraSetFlags =
          lib.optional (cfg.operator != null) "--operator=${cfg.operator}"
          ++ [ "--advertise-exit-node=${lib.boolToString cfg.advertiseExitNode}" ];
      };
    };
}
