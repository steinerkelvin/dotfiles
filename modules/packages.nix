{ inputs, lib, ... }:

{
  perSystem = { system, ... }:
    lib.optionalAttrs (lib.hasSuffix "-darwin" system) {
      packages.darwin-rebuild = inputs.nix-darwin.packages.${system}.default;
    };
}
