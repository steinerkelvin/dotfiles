{ ... }:

{
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1"; # move to nix.nix
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
