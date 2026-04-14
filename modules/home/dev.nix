{ inputs, ... }:

{
  flake.homeConfigurations.dev =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        ../../nix/home/dev
        ({ ... }: {
          home.username = "dev";
          home.homeDirectory = "/home/dev";
          home.stateVersion = "25.05";
        })
      ];
    };
}
