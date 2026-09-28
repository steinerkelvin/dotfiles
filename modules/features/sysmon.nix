_: {
  flake.homeModules.sysmon = { pkgs, lib, ... }: {
    home.packages = [
      pkgs.killall
      pkgs.htop
      # cudaSupport only adds /run/opengl-driver/lib to the runpath so btop can
      # dlopen NVML (libnvidia-ml) for the GPU box; no CUDA toolkit pulled in.
      (if pkgs.stdenv.isLinux then pkgs.btop.override { cudaSupport = true; } else pkgs.btop)
      pkgs.lsof
      pkgs.pstree
      pkgs.bottom
      pkgs.watch
    ] ++ lib.optionals pkgs.stdenv.isLinux [
      pkgs.lshw
      pkgs.usbutils
      pkgs.iotop
      pkgs.ncdu
    ];
  };
}
