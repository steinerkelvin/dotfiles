{
  description = "k-ai tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        buildInputs = [
          pkgs.bun
        ];
        devPkgs = [
          pkgs.biome
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          packages = devPkgs;
        };
      }
    );
}
