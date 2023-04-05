{ config, lib, pkgs, ... }:

let
  cfg = config.modules.services.syncthing;
  user = "kelvin";
  home = config.users.users."${user}".home;
in
{
  options.modules.services.syncthing = with lib; {
    enable = mkEnableOption "syncthing, file syncronization";
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = user;
      dataDir = "${home}/data";
      guiAddress = "0.0.0.0:8384";
      openDefaultPorts = true;
    };
    networking.firewall.allowedTCPPorts = [ 8384 ];
  };
}
