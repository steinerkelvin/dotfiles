{ ... }:

{
  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1"; # move to nix.nix
  };

  home.sessionPath = [
    "$HOME/bin" # move to kelvin-specific
    "$HOME/.local/bin" # not sure what to do with this
  ];
}
