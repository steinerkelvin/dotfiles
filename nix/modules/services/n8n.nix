# From https://gitlab.com/ajgrf/dotfiles

{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.n8n;
  format_json = pkgs.formats.json;
in
{
  options.modules.services.n8n = with lib; {
    enable = mkEnableOption "n8n, visual workflow automation tool";

    package = mkOption {
      type = types.package;
      default = pkgs.n8n;
      description = "The package to use for n8n.";
    };

    config.settings = mkOption {
      type = format_json.type;
      default = {};
      description = ''
        Configuration for n8n, see <https://docs.n8n.io/reference/configuration.html>
        for supported values.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    services.n8n = {
      enable = true;
      openFirewall = true;
      settings = cfg.config.settings;
    };
  };
}
