{
  description = "Kelvin's personal flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # agenix.url = "github:ryantm/agenix";
    # agenix.inputs.nixpkgs.follows = "nixpkgs";
    # agenix.inputs.home-manager.follows = "home-manager";

    # arion.url = "github:hercules-ci/arion";
    # arion.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    k-ddns.url = "github:steinerkelvin/k-ddns";
    k-ddns.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }:
    let
      supportedPlatforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" ];
      forAllPlatforms = nixpkgs.lib.genAttrs supportedPlatforms;

      inputNixosModules = [
        # inputs.agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        # inputs.arion.nixosModules.arion
        inputs.k-ddns.nixosModules.k-ddns
      ];

      localNixosUserModules = builtins.mapAttrs (_: value: value.hosts) (import ./nix/users);
      kelvinNixosModules = localNixosUserModules.kelvin;

      localNixosModules = import ./nix/modules;
      allNixosModules = inputNixosModules ++ builtins.attrValues localNixosModules;

      lib = import ./nix/lib { inherit inputs; };

      shared = import ./nix/shared.nix;

      mkSystem = args@{ hostPlatform ? "x86_64-linux", extraModules ? [ ], ... }:
        nixpkgs.lib.nixosSystem (args // {
          modules = allNixosModules ++ extraModules;
          specialArgs = { inherit inputs; k-shared = shared; };
        });
    in
    rec {
      nixosModules = localNixosModules;

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
              pkgs.nil
              pkgs.nixpkgs-fmt
              pkgs.shellcheck
              pkgs.home-manager
              pkgs.act
              pkgs.ruff
            ];
          };
        }
      );

      nixosConfigurations = {
        nixia = mkSystem { extraModules = [ ./nix/hosts/nixia kelvinNixosModules.nixia ]; };
        # kazuma = mkSystem { extraModules = [ ./nix/hosts/kazuma kelvinNixosModules.kazuma ]; };
        # stratus = mkSystem { extraModules = [ ./nix/hosts/stratus kelvinNixosModules.stratus ]; };
        ryuko = mkSystem { extraModules = [ ./nix/hosts/ryuko ]; };
      };

      darwinConfigurations = {
        satsuki = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
        };
      };

      homeConfigurations = {
        "kelvin" =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./nix/users/kelvin/hm/common.nix
              ./nix/users/kelvin/hm/linux.nix
              ({ ... }: { home.stateVersion = "23.05"; })
            ];
          };
        mac =
          inputs.home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
            extraSpecialArgs = { inherit inputs; };
            modules = [ ./nix/users/kelvin/hm/mac.nix ];
          };
      };

      # TODO: home / profile configurarions
      checks = forAllPlatforms (system:
        let
          inherit (nixpkgs.lib.attrsets) filterAttrs mapAttrs;
          checkPackages = packages.${system};
          checkHosts = mapAttrs (_name: host: host.config.system.build.toplevel)
            (filterAttrs (_name: host: host.pkgs.hostPlatform == system)
              nixosConfigurations);
          checkUsers = mapAttrs (_name: user: user.activationPackage)
            (filterAttrs (_name: user: user.pkgs.system == system) homeConfigurations);
          # checkDeploys =
          #   deploy-rs.lib.${system}.deployChecks self.deploy;
        in
        { }
        // checkPackages
        // checkHosts
        // checkUsers
        # // checkDeploys
      );

    };
}
