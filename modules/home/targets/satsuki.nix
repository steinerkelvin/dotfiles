{ inputs, overlays, ... }:

{
  flake.homeConfigurations.satsuki =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [ overlays.darwinDirenv ];
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../../../profiles/kelvin/default.nix
        ../../../profiles/kelvin/identity.nix
        ../../../profiles/kelvin/platform/mac.nix
      ];
    };
}
