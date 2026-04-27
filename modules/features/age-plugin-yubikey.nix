# age-plugin-yubikey: hardware-backed age identities on a YubiKey 5+.
#
# Cross-platform. macOS provides PC/SC natively; on NixOS hosts (future), the
# host-level config will need:
#
#     services.pcscd.enable = true;
#     services.udev.packages = [ pkgs.yubikey-personalization ];
#
# Not relevant for the current `linux` / `dev` home-manager-only targets.
#
# Provisioning (run once per YubiKey, by hand):
#
#     age-plugin-yubikey            # interactive: pick slot, set PIN/touch policy
#     # capture the printed `age1yubikey1...` recipient line
#
# The identity file lives at ~/.config/passage/identities/yubikey-<serial>.txt
# and is just a pointer to the slot; the key material stays on hardware.
_: {
  flake.homeModules.age-plugin-yubikey = { pkgs, ... }: {
    home.packages = [
      pkgs.age-plugin-yubikey
    ];
  };
}
