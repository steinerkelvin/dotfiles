{ inputs, ... }:

{
  flake.darwinConfigurations.satsuki = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.determinate.darwinModules.default
      ./_satsuki/builders.nix
      ({ ... }: {
        determinateNix.enable = true;
        system.stateVersion = 6;
      })
    ];
  };
}
