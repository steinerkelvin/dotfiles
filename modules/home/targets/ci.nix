# Build-coverage target. NOT deployable and not meant to be: it exists so CI
# builds the homeModules the real machines actually compose, and nothing else.
#
# Replaces the old `homeConfigurations.linux`, which built profiles/kelvin --
# a second home-manager config for Kelvin's $HOME that no machine deployed
# from, so the check validated code nobody ran. This composes what the
# downstream host configs import instead.
#
# Deliberately NOT covered here, so the next audit doesn't re-litigate:
#   - graphical, wl-kbptr -- Wayland desktop closure, too heavy for CI
#   - git-signing, work-identity -- need host-specific options to evaluate
# All four are uncovered today too; this records the gap rather than widening it.
#
# `modules/checks.nix` picks this up automatically (it maps every
# homeConfigurations entry to its activationPackage, filtered by system), so it
# lands in checks.x86_64-linux with no further wiring.

{
  inputs,
  config,
  overlays,
  ...
}:

{
  flake.homeConfigurations.ci-linux = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      # base-dev -> worktree.nix wants pkgs.worktrunk, which is not in stable yet.
      overlays = [ overlays.unstable ];
    };
    extraSpecialArgs = { inherit inputs; };
    modules = [
      config.flake.homeModules.base-dev
      config.flake.homeModules.identity
      config.flake.homeModules.nixvim
      config.flake.homeModules.kitty
      config.flake.homeModules.email
      config.flake.homeModules.ai-skills
      config.flake.homeModules.claude-hooks
      config.flake.homeModules.homeshick
      (_: {
        home = {
          username = "ci";
          homeDirectory = "/home/ci";
          stateVersion = "25.11";
        };
        programs.claude-code.enable = true;
        programs.ai-skills = {
          enableStructuralSearch = true;
          enableCodeStats = true;
          enableDiagramTools = true;
        };
        programs.claude-hooks.enableCwdDirenv = true;
      })
    ];
  };
}
