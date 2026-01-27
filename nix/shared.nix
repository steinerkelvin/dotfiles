# Shared configuration values across the flake
# Ports, SSH keys, and other constants

rec {
  ports = {
    mosquitto_1 = 1883;
    mosquitto_2 = 9001;
    home-assistant = 8123;
    headscale = 49001;
    zigbee2mqtt = 49081;
    smokeping = 49181;
    alfred = 49281;
    minecraft = 25565;
    yggdrasil_tcp = 50000;
  };

  # SSH public keys for authorized_keys
  # NOTE: secrets/secrets.nix has keys for agenix encryption (different purpose)
  keys = {
    users.kelvin = {
      satsuki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/p/ZbOkA/Wv4dTYbT/CJ+vndMS7xN/8J8SAnVroK0T kelvin@satsuki.local";
      mako = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYf1GTjqmCH89LG0v1zMWL6detrFjYCaL9+A5qmIqNM kelvin@mako-wsl";
    };

    # All kelvin's keys - use for authorized_keys
    kelvinAll = builtins.attrValues keys.users.kelvin;
  };
}
