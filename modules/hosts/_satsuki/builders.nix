{ lib, ... }:

{
  determinateNix.customSettings = {
    trusted-users = [ "root" "kelvin" ];
    builders = "@/etc/nix/machines";
    builders-use-substitutes = true;
  };

  environment.etc."nix/machines".text = lib.concatStringsSep "\n" [
    # OrbStack NixOS builder (aarch64-linux)
    "ssh-ng://builder@nixos-builder.orb.local aarch64-linux /etc/nix/builder_ed25519 4 1 kvm,benchmark,big-parallel -"
    # momo (x86_64-linux)
    "ssh-ng://kelvin@momo x86_64-linux /var/root/.ssh/id_momo 12 1 kvm,big-parallel -"
  ];

  environment.etc."ssh/ssh_config.d/100-nix-builders.conf".text = ''
    Host nixos-builder.orb.local
      StrictHostKeyChecking accept-new
  '';
}
