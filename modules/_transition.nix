# Transitional module for the dendritic migration.
#
# Holds the outputs that have not yet been peeled out into dedicated
# auto-loaded module files. Shrinks with each subsequent commit.
#
# The leading `_` in the filename makes vic/import-tree skip it; it's
# imported explicitly from flake.nix.

{ inputs, config, overlays, ... }:

let
  nixpkgs = inputs.nixpkgs;
  nix-darwin = inputs.nix-darwin;
in
{
  flake.darwinConfigurations.satsuki = nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    modules = [ ../nix/hosts/satsuki ];
    specialArgs = { inherit inputs; };
  };

  flake.homeConfigurations = {
    "kelvin" =
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ../nix/users/kelvin/hm/common.nix
          ../nix/users/kelvin/hm/linux.nix
          ({ ... }: { home.stateVersion = "23.05"; })
        ];
      };
    mac =
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config.allowUnfree = true;
          overlays = [ overlays.darwinDirenv ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ../nix/users/kelvin/hm/mac.nix ];
      };
    dev =
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          ../nix/profiles/dev
          ({ ... }: {
            home.username = "dev";
            home.homeDirectory = "/home/dev";
            home.stateVersion = "25.05";
          })
        ];
      };
  };

  perSystem = { system, ... }: {
    checks =
      let
        inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
      in
      mapAttrs (_name: user: user.activationPackage)
        (filterAttrs (_name: user: user.pkgs.system == system) config.flake.homeConfigurations);
  };
}
