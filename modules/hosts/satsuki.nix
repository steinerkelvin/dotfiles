{ inputs, ... }:

{
  flake.darwinConfigurations.satsuki = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [ ./_satsuki ];
    specialArgs = { inherit inputs; };
  };
}
