{ inputs, ... }:

{
  flake.homeConfigurations.kelvin =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./_kelvin-hm/common.nix
        ./_kelvin-hm/linux.nix
        (_: { home.stateVersion = "23.05"; })
      ];
    };
}
