{ lib, config, pkgs, ... }:

let
  cfg = config.k.modules.radeon;
in
{
  options = {
    k.modules.radeon = {
      enable = lib.mkOption {
        description = "AMD Radeon drivers etc";
        default = false;
        example = true;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules = [ "amdgpu" ];
    services.xserver.videoDrivers = lib.mkIf config.services.xserver.enable [ "amdgpu" ];

    systemd.tmpfiles.rules = [
      "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.hip}"
    ];

    # # TODO: flag
    # hardware.opengl.extraPackages = [
    #   pkgs.rocm-opencl-icd
    #   pkgs.rocm-opencl-runtime
    # ];

    environment.systemPackages = [
      pkgs.radeontop
      pkgs.corectrl
    ];
  };
}
