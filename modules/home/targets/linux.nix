{ inputs, overlays, ... }:

{
  flake.homeConfigurations.linux =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ overlays.unstable ];
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../../../profiles/kelvin/default.nix
        ../../../profiles/kelvin/identity.nix
        ../../../profiles/kelvin/platform/linux.nix
      ];
    };
}
