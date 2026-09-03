_: {
  flake.homeModules.nix = { pkgs, ... }: {
    home.sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    home.packages = [
      # Language server
      pkgs.nil
      # Linters
      # pkgs.statix # broken test suite (empty_list_concat) on nixpkgs-26.05 aarch64-darwin as of 2026-09-02
      pkgs.deadnix
      # Formatters
      # RFC-166 nixfmt, not nixfmt-classic: classic is unmaintained AND ships
      # its binary as `nixfmt`, so having it here shadowed the 1.x nixfmt that
      # downstream `nix fmt` / lefthook expect.
      pkgs.nixfmt
      pkgs.nixpkgs-fmt
      # Explorers / tools
      pkgs.nix-index
      pkgs.nix-tree
      pkgs.nh
    ];
  };
}
