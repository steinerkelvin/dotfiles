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
