{ config, lib, pkgs, ... }:

let cfg =
  config.k.modules.audio-prod;
in
{

  options.k.modules.audio-prod = {
    enable = lib.mkEnableOption "Enable audio production suite";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      pipewire
      qpwgraph
      ardour
    ];

    services.pipewire = {
      enable = true;
      wireplumber.enable = true;
      jack = {
        enable = true;
      };
    };

    # TODO: memlock limit not working
    security.pam.loginLimits = [
      {
        domain = "@audio";
        item = "memlock";
        type = "soft";
        value = "65536";
      }
    ];

  };

}
