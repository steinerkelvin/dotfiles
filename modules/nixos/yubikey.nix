# Reusable NixOS module: YubiKey hardware support.
#
# Enables the PC/SC smartcard daemon and installs the udev rules so a non-root
# user can reach the key over USB. This is the host-level half that the
# `age-plugin-yubikey` home module depends on (its header notes exactly this);
# it also covers the GPG/PIV smartcard path, since both speak PC/SC.
#
# Scope is deliberately hardware enablement only — identity-free, so it can live
# in public dotfiles. FIDO2/U2F login & sudo (security.pam.u2f) is per-user and
# identity-bearing (it maps registered credentials to accounts) and can lock you
# out if misconfigured, so a host opts into that itself rather than inheriting it
# here.
_: {
  flake.nixosModules.yubikey =
    { pkgs, ... }:
    {
      # Smartcard daemon: GPG, PIV, and age-plugin-yubikey talk to the key
      # through this.
      services.pcscd.enable = true;

      # udev rules granting the seat user access to the YubiKey USB device.
      services.udev.packages = [ pkgs.yubikey-personalization ];

      # pcsc-tools ships `pcsc_scan`, the canonical "is pcscd healthy + can it
      # see the card" probe. Tiny package; goes with the module so every host
      # that enables yubikey gets the diagnostic without a separate opt-in.
      environment.systemPackages = [ pkgs.pcsc-tools ];
    };
}
