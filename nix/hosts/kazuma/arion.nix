{ k-shared, pkgs, ... }:

let
  ports = k-shared.ports;
in
{
   environment.systemPackages = [
     pkgs.arion
     pkgs.docker-client
     pkgs.docker-compose
   ];

  virtualisation.arion = {
    backend = "docker";

    projects = {

      minecraft = {
        settings.services."minecraft" = {
          # Minecraft
          image.enableRecommendedContents = true;
          service.useHostStore = true;
          service.command = [ "${pkgs.purpur}/bin/minecraft-server" ];
          service.restart = "unless-stopped";
          # service.tty = true;
          # # service.stdin_open = true;
          service.working_dir = "/app";
          service.volumes = [
            "/data/games/minecraft:/app"
          ];
          service.ports = [
            "${toString ports.minecraft}:25565"
          ];
        };
      };

      smokeping = {
        settings.services."smokeping".service = {
          # Smokeping
          image = "lscr.io/linuxserver/smokeping:latest";
          restart = "unless-stopped";
          ports = [
            "${toString ports.smokeping}:80"
          ];
        };
      };

      # sticker-bot = {
      #   settings.services."sticker-bot".service = {
      #     image = "telegram-inline-stickers-bot-app";
      #   };
      # };

      homeassistant = {
        settings.services.homeassistant.service = {
          # Home Assistant
          image = "ghcr.io/home-assistant/home-assistant:stable";
          restart = "unless-stopped";
          privileged = true;
          network_mode = "host";
          environment = {
            TZ = "America/Sao_Paulo";
          };
          volumes = [
            "/data/home-assistant/config:/config"
          ];
        };
        settings.services.mqtt.service = {
          # MQTT
          image = "eclipse-mosquitto:2.0";
          restart = "unless-stopped";
          volumes = [
            "/data/mosquitto/data:/mosquitto"
          ];
          ports = [
            "${toString ports.mosquitto_1}:1883"
            "${toString ports.mosquitto_2}:9001"
          ];
          command = [ "mosquitto" "-c" "/mosquitto-no-auth.conf" ];
        };
        settings.services.zigbee2mqtt.service = {
          # Zigbee2MQTT
          image = "koenkk/zigbee2mqtt";
          restart = "unless-stopped";
          volumes = [
            "/data/zigbee2mqtt/data:/app/data"
            "/run/udev:/run/udev:ro"
          ];
          ports = [
            "${toString ports.zigbee2mqtt}:8080"
          ];
          environment = {
            TZ = "America/Sao_Paulo";
          };
          devices = [
            "/dev/ttyUSB0:/dev/ttyUSB0"
          ];
        };
      };

    };
  };


}
