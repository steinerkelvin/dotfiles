{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    # unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    arion.url = "github:hercules-ci/arion";

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    duckdns-script = {
      url = "github:steinerkelvin/duckdns-script";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      supportedPlatforms = [ "aarch64-linux" "x86_64-linux" ];
      forAllPlatforms = nixpkgs.lib.genAttrs supportedPlatforms;

      nixosModules = import ./nix/modules;
      nixosUserModules = builtins.mapAttrs (_: value: value.nixos) (import ./nix/users);

      allNixosModules = builtins.attrValues nixosModules;
      allNixosUserModules = builtins.attrValues nixosUserModules;

      mkSystem = args@{ hostPlatform ? "x86_64-linux", extraModules ? [ ], ... }:
        nixpkgs.lib.nixosSystem (args // {
          modules = 
            [
              inputs.home-manager.nixosModules.home-manager
              inputs.agenix.nixosModules.default
            ]
            ++ allNixosModules ++ allNixosUserModules ++ extraModules;
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
        ryuko = mkSystem { extraModules = [ ./nix/hosts/ryuko ]; };
      };

      homeConfigurations = {
        "kelvin@megumin.local" =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./nix/users/kelvin/hm/mac.nix ];
          };
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
        in
        { }
        # // checkPackages
        // checkHosts
        # // checkUsers
      );

    };
}
