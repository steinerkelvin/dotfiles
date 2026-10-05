_: {
  flake.homeModules.net-transfer = { pkgs, ... }: {
    home.packages = [
      pkgs.curl
      pkgs.wget
      pkgs.rsync
      # Encrypted file transfer
      pkgs.croc
    ];
  };
}
