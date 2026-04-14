# Transitional module for the dendritic migration.
#
# Every flake output currently lives here, wrapped in flake-parts shape
# but otherwise identical to what the monolithic flake.nix used to
# produce. Subsequent commits peel individual outputs out into their
# own auto-loaded module files, shrinking this file until it's empty
# and can be deleted.
#
# The leading `_` in the filename makes vic/import-tree skip it during
# auto-loading; it's imported explicitly from flake.nix instead.

{ inputs, config, ... }:

let
  supportedPlatforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
  nixpkgs = inputs.nixpkgs;
  nix-darwin = inputs.nix-darwin;

  darwinDirenvWorkaround = final: prev: {
    direnv = prev.direnv.overrideAttrs (_: {
      # Temporary workaround for Darwin test-fish failures:
      # https://github.com/NixOS/nixpkgs/issues/507531
      doCheck = false;
    });
  };
in
{
  systems = supportedPlatforms;

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
          overlays = [ darwinDirenvWorkaround ];
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
    devShells.default =
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      pkgs.mkShell {
        packages = [
          pkgs.just
          pkgs.nixd
          pkgs.nixpkgs-fmt
          pkgs.shellcheck
          pkgs.home-manager
          pkgs.act
          pkgs.ruff
        ];
      };

    checks =
      let
        inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
      in
      mapAttrs (_name: user: user.activationPackage)
        (filterAttrs (_name: user: user.pkgs.system == system) config.flake.homeConfigurations);
  };
}
