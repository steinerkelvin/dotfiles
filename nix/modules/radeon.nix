{ lib, config, pkgs, ... }:

let
  cfg = config.modules.radeon;
in
{
  options = {
    modules.radeon = {
      enable = lib.mkOption {
        description = "AMD Radeon drivers etc";
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf cfg.enable { boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    ];

    hardware.opengl.extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];

    environment.systemPackages = with pkgs; [
      radeontop
      # corectl # TODO: write derivation for `corectl`
    ];
  };
}
