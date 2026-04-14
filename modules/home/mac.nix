{ inputs, overlays, ... }:

{
  flake.homeConfigurations.mac =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
        overlays = [ overlays.darwinDirenv ];
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../../nix/users/kelvin/hm/mac.nix
      ];
    };
}
