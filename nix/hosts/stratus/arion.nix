{ ... }:

{
  environment.etc = {
    "frp/frps.ini".text = ''
      [common]
      bind_port = 7000
    '';
  };

  virtualisation.arion = {
    backend = "docker";

    projects = {

      # frps = {
      #   image.enableRecommendedContents = true;
      #   service.userHostStore = true;
      #   service.command = [ "${pkgs.frp}/bin/frps" ];
      #   service.network_mode = "host";
      #   service.ports = [
      #     "7000:7000"
      #   ];
      #   service.stop_signal = "SIGINT";

      #   service.volumes = [
      #     "/etc/frp/frps.ini:/srv/frp/frps.ini"
      #   ];
      # };

    };
  };
}
