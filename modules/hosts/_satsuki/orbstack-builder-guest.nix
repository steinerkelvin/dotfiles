# NixOS module for OrbStack builder VM (guest-side config).
# The @BUILDER_PUBKEY@ placeholder is replaced by setup-orbstack-builder.sh
# with the contents of /etc/nix/builder_ed25519.pub from the host.
{ lib, ... }:

{
  services.openssh.enable = lib.mkForce true;

  users.users.builder = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "@BUILDER_PUBKEY@"
    ];
  };

  nix.settings.trusted-users = [ "root" "builder" ];
}
