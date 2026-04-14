# Helper functions

{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) filterAttrs platforms;
  inherit (inputs.nixpkgs.lib.lists) elem;
in
{
  filterSupportedPkgs = system: pkgs:
    /**
      Synopsis: filterSupportedPkgs _system_ _pkgs_

      Filter packages that support _system_ in the attribute set _pkgs_.
      **/
    let
      hasUnsupportedPlatform = attrs:
        (!elem system (attrs.meta.platforms or platforms.all) ||
          elem system (attrs.meta.badPlatforms or [ ]));
    in
    filterAttrs (_name: value: !hasUnsupportedPlatform value) pkgs;
}
