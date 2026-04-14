{ ... }: {
  flake.homeModules.file-utils = { pkgs, ... }: {
    home.packages = [
      pkgs.unzip
      # Disk usage analyzer
      pkgs.dua
    ];
  };
}
