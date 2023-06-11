{ lib, config, pkgs, ... }:

{
  options = with lib; {
    modules.services.spotifyd = {
      enable = mkEnableOption "Spotify daemon";
    };
  };

  config = {

    networking.firewall.allowedTCPPorts = [
      57621
    ];
    networking.firewall.allowedUDPPorts = [
      5353
      57621
    ];

  };
}
