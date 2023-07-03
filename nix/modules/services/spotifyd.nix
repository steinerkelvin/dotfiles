{ lib, config, ... }:

{
  options = with lib; {
    k.modules.services.spotifyd = {
      enable = mkEnableOption "Spotify daemon";
    };
  };

  config = lib.mkIf config.k.modules.services.spotifyd.enable {

    services.spotifyd = {
      enable = true;
      settings = {
        global = {
          device_name = config.k.host.name;
          zeroconf_port = 57621;
          username = "kelvinsteiner";
          # password = "<pass>";
        };
      };
    };

    networking.firewall.allowedTCPPorts = [
      57621
    ];
    networking.firewall.allowedUDPPorts = [
      5353
      57621
    ];

  };
}
