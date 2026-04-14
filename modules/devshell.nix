{ inputs, ... }:

{
  perSystem = { system, ... }: {
    devShells.default =
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      pkgs.mkShell {
        packages = [
          pkgs.just
          pkgs.nixd
          pkgs.nixpkgs-fmt
          pkgs.shellcheck
          pkgs.home-manager
          pkgs.act
          pkgs.ruff
        ];
      };
  };
}
