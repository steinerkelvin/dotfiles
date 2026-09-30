{ inputs, ... }:

{
  perSystem = { system, ... }: {
    formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
  };
}
