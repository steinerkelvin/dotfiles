{ inputs, ... }:

{
  flake.darwinConfigurations.satsuki = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = { inherit inputs; };
    modules = [
      ({ ... }: {
        # Nix is managed by Determinate Nix
        nix.enable = false;
        system.stateVersion = 6;
      })
    ];
  };
}
