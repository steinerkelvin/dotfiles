{ inputs, ... }:

{
  flake.homeConfigurations.linux =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../../../profiles/kelvin/common.nix
        ../../../profiles/kelvin/linux.nix
        (_: { home.stateVersion = "23.05"; })
      ];
    };
}
