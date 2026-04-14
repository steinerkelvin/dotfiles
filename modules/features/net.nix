_: {
  flake.homeModules.net = { pkgs, ... }: {
    home.packages = [
      pkgs.mosh
      pkgs.inetutils
      pkgs.nmap
      pkgs.dig
    ];
  };
}
