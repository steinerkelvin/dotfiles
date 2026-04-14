{ ... }: {
  flake.homeModules.shell = { pkgs, ... }: {
    home.packages = [
      pkgs.zoxide
      pkgs.fzf
      pkgs.ripgrep
      pkgs.bat
      pkgs.fd
      pkgs.eza
    ];
  };
}
