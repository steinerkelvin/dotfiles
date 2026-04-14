_: {
  flake.homeModules.nix = { pkgs, ... }: {
    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    home.packages = [
      # Language server
      pkgs.nil
      # Linters
      pkgs.statix
      pkgs.deadnix
      # Formatters
      pkgs.nixfmt-classic
      pkgs.nixpkgs-fmt
      # Explorers / tools
      pkgs.nix-index
      pkgs.nix-tree
    ];
  };
}
