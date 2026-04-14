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
        ../../nix/users/kelvin/hm/common.nix
        ../../nix/users/kelvin/hm/linux.nix
        ({ ... }: { home.stateVersion = "23.05"; })
      ];
    };
}
