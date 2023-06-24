{ inputs, pkgs, lib, config, ... }:

let
  machineKind = config.k.host.kind;
  isPC = lib.elem machineKind [ "pc" ];
in
{
  config = {

    # Bootloader
    boot.loader = if !isPC then {
      systemd-boot.enable = true;
    } else {
      grub = {
        enable = true;
        default = "saved";
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      timeout = 7;
    };

  };
}
