{ lib, config, pkgs, ... }:

{
  imports = [ ../common.nix ./hardware-configuration.nix ];

  config = {
    k.name = "nixia";
    k.kind = "pc";

    system.stateVersion = "22.11";

    modules.graphical.enable = true;

    modules.services.syncthing.enable = true;
    # modules.services.n8n.enable = true;

    # Hardware
    modules.radeon.enable = true;

    # Bootloader
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
  };
}
