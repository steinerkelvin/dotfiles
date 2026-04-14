{ inputs, config, ... }:

{
  flake.homeConfigurations.dev =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      modules = [
        config.flake.homeModules.base-dev
        config.flake.homeModules.ai-skills
        ({ ... }: {
          home.username = "dev";
          home.homeDirectory = "/home/dev";
          home.stateVersion = "25.05";
          programs.claude-code = {
            enable = true;
            enableStructuralSearch = true;
            enableCodeStats = true;
          };
        })
      ];
    };
}
