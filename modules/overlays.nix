# Overlays exposed to every other flake-parts module via
# _module.args.overlays. Consume with `{ overlays, ... }:`.

{ inputs, ... }:

{
  _module.args.overlays = {
    # Temporary workaround for Darwin test-fish failures:
    # https://github.com/NixOS/nixpkgs/issues/507531
    darwinDirenv = final: prev: {
      direnv = prev.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    };

    # Pull selected packages from nixpkgs-unstable while the rest of the
    # system stays on the stable channel. Add a package here only when stable
    # lags a version we actually need.
    #   - worktrunk: git worktree manager (not in stable 25.11 yet)
    unstable = final: prev: {
      inherit (inputs.nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system})
        worktrunk;
    };
  };
}
