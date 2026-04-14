# Transitional module for the dendritic migration.
#
# Holds the outputs that have not yet been peeled out into dedicated
# auto-loaded module files. Shrinks with each subsequent commit.
#
# The leading `_` in the filename makes vic/import-tree skip it; it's
# imported explicitly from flake.nix.

{ inputs, config, ... }:

{
  perSystem = { system, ... }: {
    checks =
      let
        inherit (inputs.nixpkgs.lib.attrsets) filterAttrs mapAttrs;
      in
      mapAttrs (_name: user: user.activationPackage)
        (filterAttrs (_name: user: user.pkgs.system == system) config.flake.homeConfigurations);
  };
}
