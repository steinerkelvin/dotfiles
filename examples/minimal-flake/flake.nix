{
  description = "Minimal example of importing kelvin-dotfiles homeModules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kelvin-dotfiles = {
      url = "github:steinerkelvin/dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, kelvin-dotfiles, ... }: {
    # `nix build .#homeConfigurations.example.activationPackage`
    # `home-manager switch --flake .#example`
    homeConfigurations.example = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [
        # Single-feature import. Swap to `base-dev` for the full baseline:
        #   kelvin-dotfiles.homeModules.base-dev
        kelvin-dotfiles.homeModules.dep-opsec
        ./home.nix
      ];
    };
  };
}
