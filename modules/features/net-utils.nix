_: {
  flake.homeModules.net-utils = { pkgs, ... }: {
    home.packages = [
      pkgs.openssh
      pkgs.curl
      pkgs.wget
      pkgs.rsync
      # Encrypted file transfer
      pkgs.croc
    ];
  };
}
