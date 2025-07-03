{ inputs, config, lib, pkgs, ... }:

let
  cfg =
    config.k.modules.audio-prod;
in
{

  imports = [
    inputs.musnix.nixosModules.musnix
  ];

  options.k.modules.audio-prod = {
    enable = lib.mkEnableOption "Enable audio production suite";
  };

  config = lib.mkIf cfg.enable {

    musnix.enable = true;
    musnix.soundcardPciId = "0e:00.4";
    musnix.kernel.realtime = true;

    environment.systemPackages = [
      pkgs.pipewire
      pkgs.qpwgraph
      pkgs.ardour
    ];

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      jack = {
        enable = true;
      };
    };

  };

}
