# Overlays exposed to every other flake-parts module via
# _module.args.overlays. Consume with `{ overlays, ... }:`.

{ ... }:

{
  _module.args.overlays = {
    # Temporary workaround for Darwin test-fish failures:
    # https://github.com/NixOS/nixpkgs/issues/507531
    darwinDirenv = final: prev: {
      direnv = prev.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    };
  };
}
