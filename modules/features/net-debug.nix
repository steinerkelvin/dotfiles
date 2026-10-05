_: {
  flake.homeModules.net-debug = { pkgs, ... }: {
    home.packages = [
      pkgs.inetutils
      pkgs.nmap
      pkgs.dig
      pkgs.tcpdump
    ];
  };
}
