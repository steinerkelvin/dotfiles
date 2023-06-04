# From https://gitlab.com/ajgrf/dotfiles

{ config, lib, pkgs, ... }:

let
  cfg = config.services.keyd;
in
{
  options.services.keyd = with lib; {
    enable = mkEnableOption "keyd, a key remapping daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.keyd;
      description = "The package to use for keyd.";
    };

    config = mkOption {
      type = with types; attrsOf lines;
      description = "Keyboard configurations.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    environment.etc = lib.mapAttrs'
      (name: value:
        lib.nameValuePair "keyd/${name}.conf" { text = value; })
      cfg.config;

    users.groups.keyd = { };

    systemd.services.keyd = {
      description = "key remapping daemon";
      requires = [ "local-fs.target" ];
      after = [ "local-fs.target" ];
      wantedBy = [ "sysinit.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/keyd";
      };
    };
  };
}
