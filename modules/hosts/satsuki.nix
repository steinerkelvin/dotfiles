{ inputs, ... }:

{
  flake.darwinConfigurations.satsuki = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [ ../../nix/hosts/satsuki ];
    specialArgs = { inherit inputs; };
  };
}
