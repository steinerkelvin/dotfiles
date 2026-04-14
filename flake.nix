{
  description = "Kelvin's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }:
    let
      supportedPlatforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
      forAllPlatforms = nixpkgs.lib.genAttrs supportedPlatforms;
      darwinDirenvWorkaround = final: prev: {
        direnv = prev.direnv.overrideAttrs (_: {
          # Temporary workaround for Darwin test-fish failures:
          # https://github.com/NixOS/nixpkgs/issues/507531
          doCheck = false;
        });
      };
    in
    rec {
      devShells = forAllPlatforms (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          default = pkgs.mkShell {
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
        }
      );

      darwinConfigurations = {
        satsuki = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [ ./nix/hosts/satsuki ];
          specialArgs = { inherit inputs; };
        };
      };

      homeConfigurations = {
        "kelvin" =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./nix/users/kelvin/hm/common.nix
              ./nix/users/kelvin/hm/linux.nix
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
            modules = [ ./nix/users/kelvin/hm/mac.nix ];
          };
        dev =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
            modules = [
              ./nix/profiles/dev
              ({ ... }: {
                home.username = "dev";
                home.homeDirectory = "/home/dev";
                home.stateVersion = "25.05";
              })
            ];
          };
      };

      checks = forAllPlatforms (system:
        let
          inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
        in
        mapAttrs (_name: user: user.activationPackage)
          (filterAttrs (_name: user: user.pkgs.system == system) homeConfigurations)
      );
    };
}
