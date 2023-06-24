{ inputs, lib, pkgs, config, ... }:

let
  scriptPackage = inputs.duckdns-script.packages.${pkgs.system}.default;
in
{
  options.k.services.ddns = {
    enable = lib.mkEnableOption "enable duckdns ddns";
    domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "The domains to update";
      default = ["steinerkelvin-${config.k.host.name}.duckdns.org"];
    };
  };

  config = lib.mkIf config.k.services.ddns.enable {
    age.secrets.duckdns-token-kelvin.file =
      ../../../secrets/duckdns-token-kelvin.age;

    systemd.timers."duckdns-script" = {
      wantedBy = [ "timers.target" ];
      description = "DuckDNS script";
      timerConfig = {
        OnBootSec = "1min";
        OnActiveSec = "5min";
      };
    };

    systemd.services."duckdns-script" = 
      let 
        domains =
          builtins.concatStringsSep "," config.k.services.ddns.domains;
          tokenPath = config.age.secrets.duckdns-token-kelvin.path;
      in
      {
        script = ''
          set -e
          TOKEN=$(cat ${tokenPath}) \
            ${scriptPackage}/bin/duckdns-script --ipv4-auto --ipv6-auto \
            -d ${domains}
        '';
      };
  };
}
