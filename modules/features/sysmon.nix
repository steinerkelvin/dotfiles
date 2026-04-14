_: {
  flake.homeModules.sysmon = { pkgs, lib, ... }: {
    home.packages = [
      pkgs.killall
      pkgs.htop
      pkgs.btop
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
