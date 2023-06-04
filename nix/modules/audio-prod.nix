{ config, lib, pkgs, ... }:

let cfg =
  config.k.modules.audio-prod;
in
{

  options.k.modules.audio-prod = {
    enable = lib.mkEnableOption "Enable audio production suite";
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      jack = {
        enable = true;
      };
    };

    environment.systemPackages = with pkgs; [
      pipewire
      qpwgraph
      ardour
    ];
  };

}
