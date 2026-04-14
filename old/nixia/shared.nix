# Shared port assignments used by the nixia NixOS host.
# Archived alongside the rest of the nixia stack so a future Linux host
# rebuild has the same reference table to start from.
#
# SSH public keys have been moved to nix/users/kelvin/ssh-keys.nix --
# they are user-scoped, not host-scoped.

{
  ports = {
    mosquitto_1 = 1883;
    mosquitto_2 = 9001;
    home-assistant = 8123;
    zigbee2mqtt = 49081;
    smokeping = 49181;
    yggdrasil_tcp = 50000;
  };
}
