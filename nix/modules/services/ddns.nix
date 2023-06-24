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

  config = {
    environment.systemPackages = [ 
    ];

    systemd.timers."duckdns-script" = {
      wantedBy = [ "timers.target" ];
      description = "DuckDNS script";
      timerConfig = {
        OnBootSec = "1min";
        OnActiveSec = "5min";
      };
    };

    systemd.services."duckdns-script" = 
      let domains =
        builtins.concatStringsSep "," config.k.services.ddns.domains;
      in
      {
        script = ''
          set -e
          ${scriptPackage}/bin/duckdns-script --ipv4-auto --ipv6-auto \
            -d ${domains}
        '';
      };
  };
}
