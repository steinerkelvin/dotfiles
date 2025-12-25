# Helper functions

{ inputs, ... }:

let
  inherit (inputs.nixpkgs.lib) filterAttrs platforms versionOlder;
  inherit (inputs.nixpkgs.lib.lists) elem;
  shared = import ../shared.nix;
in
{
  # Create standard user + home-manager config for kelvin
  # Usage in host user.nix: { lib, ... }: lib.k.mkKelvinUser { graphical = true; }
  mkKelvinUser =
    { graphical ? false
    , extraGroups ? [ ]
    , hmModules ? [ ]
    , stateVersion ? "25.05"
    , sshKeys ? shared.keys.kelvinAll
    }:
    {
      users.users.kelvin = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ] ++ extraGroups;
        openssh.authorizedKeys.keys = sshKeys;
      };

      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.kelvin = {
        imports =
          [ ../../users/kelvin/hm/common.nix ../../users/kelvin/hm/linux.nix ]
          ++ (if graphical then [ ../../users/kelvin/hm/graphical.nix ] else [ ])
          ++ hmModules;
        home.stateVersion = stateVersion;
      };
    };

  newerPkg = pkgA: pkgB:
    /**
      Synopsis: newerPkg _pkgA_ _pkgB_

      Given two packages, return the newer one, preferring the first package
      in case they're equal.

      Meant for deciding whether to install a package from the stable or
      unstable channel, since the stable channel should be preferred to
      minimize closure size. Also, sometimes backports can make it into
      the stable channel before unstable is updated.

      **/
    if versionOlder pkgA.version pkgB.version then
      pkgB
    else
      pkgA;

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
