{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    arion.url = "github:hercules-ci/arion";
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      supportedPlatforms = [ "aarch64-linux" "x86_64-linux" ];
      forAllPlatforms = nixpkgs.lib.genAttrs supportedPlatforms;

      nixosModules = import ./nix/modules;
      userModules = import ./nix/users;

      allNixosModules = builtins.attrValues nixosModules;
      allUserModules = builtins.attrValues userModules;

      mkSystem = args@{ hostPlatform ? "x86_64-linux", pkgs ? nixpkgs
        , extraModules ? [ ], ... }:
        nixpkgs.lib.nixosSystem (args // {
          modules = [ inputs.home-manager.nixosModules.home-manager ]
            ++ allNixosModules ++ allUserModules ++ extraModules;
          specialArgs = { inherit inputs; };
        });

      lib = import ./nix/lib { inherit inputs; };
    in
    rec {
      inherit nixosModules;

      # Export custom packages
      packages = forAllPlatforms (system:
        lib.filterSupportedPkgs system
          (import ./nix/pkgs {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ ];
              config.allowUnfree = true;
            };
          })
      );

      nixosConfigurations = {
        nixia = mkSystem { extraModules = [ ./nix/hosts/nixia ]; };
        kazuma = mkSystem { extraModules = [ ./nix/hosts/kazuma ]; };
      };

      # TODO: home / profile configurarions

      checks = forAllPlatforms (platform:
        let
          inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
          # checkPackages = packages.${platform};
          checkHosts = mapAttrs (_name: host: host.config.system.build.toplevel)
            (filterAttrs (_name: host: host.pkgs.hostPlatform == platform)
              nixosConfigurations);
          # checkUsers = mapAttrs (_name: user: user.activationPackage)
          #   (filterAttrs (_name: user: user.pkgs.system == system) homeConfigurations);
        in { }
        # // checkPackages
        // checkHosts
        # // checkUsers
      );

    };
}
